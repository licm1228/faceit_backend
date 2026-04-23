#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import hashlib
from pathlib import Path
from typing import Iterable

import requests


ROOT = Path(__file__).resolve().parents[1]
RAG_ROOT = Path("/home/furina/Code/Face It/rag")
DB_URL = os.environ.get("RAG_DB_URL", "postgresql://postgres:furina@127.0.0.1:5432/ragent")
EMBEDDING_MODEL_ID = "qwen-emb-8b"
EMBEDDING_MODEL_NAME = "Qwen/Qwen3-Embedding-8B"
EMBEDDING_URL = "https://api.siliconflow.cn/v1/embeddings"
DIMENSION = 1536
COLLECTIONS = ("javabackend", "python", "web")


def load_dotenv() -> None:
    dotenv = ROOT / ".env.local"
    if not dotenv.exists():
        return
    for raw_line in dotenv.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip())


def run_psql(sql: str) -> str:
    result = subprocess.run(
        ["psql", DB_URL, "-v", "ON_ERROR_STOP=1", "-tA", "-c", sql],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def get_knowledge_bases() -> dict[str, dict[str, str]]:
    output = run_psql(
        "select id || '|' || name || '|' || embedding_model || '|' || collection_name "
        "from t_knowledge_base where deleted = 0 order by name;"
    )
    result: dict[str, dict[str, str]] = {}
    for line in output.splitlines():
        if not line:
            continue
        kb_id, name, embedding_model, collection_name = line.split("|", 3)
        result[collection_name] = {
            "id": kb_id,
            "name": name,
            "embedding_model": embedding_model,
        }
    return result


def sql_literal(value: str | None) -> str:
    if value is None:
        return "NULL"
    return "'" + value.replace("\\", "\\\\").replace("'", "''") + "'"


def build_id(seed: str) -> str:
    digest = hashlib.sha1(seed.encode("utf-8")).hexdigest()
    return str(int(digest[:18], 16) % (10 ** 19)).zfill(19)


def slugify(name: str) -> str:
    return re.sub(r"[^0-9A-Za-z\u4e00-\u9fa5_-]+", "-", name).strip("-").lower()


def split_chunks(content: str) -> list[str]:
    text = content.strip()
    if not text:
        return []
    sections = re.split(r"\n(?=###\s+问题\d+)", text)
    if len(sections) > 1:
        header = sections[0].strip()
        chunks: list[str] = []
        for section in sections[1:]:
            part = (header + "\n\n" + section.strip()).strip()
            if part:
                chunks.append(part)
        return chunks
    fallback = re.split(r"\n(?=##\s+)", text)
    return [part.strip() for part in fallback if part.strip()]


def list_documents() -> list[dict[str, str]]:
    docs: list[dict[str, str]] = []
    for collection in COLLECTIONS:
        directory = RAG_ROOT / collection
        for path in sorted(directory.glob("*.md")):
            docs.append(
                {
                    "collection": collection,
                    "path": str(path),
                    "name": path.name,
                    "content": path.read_text(encoding="utf-8"),
                }
            )
    return docs


def embed_batch(texts: list[str], api_key: str) -> list[list[float]]:
    response = requests.post(
        EMBEDDING_URL,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json={
            "model": EMBEDDING_MODEL_NAME,
            "input": texts,
            "dimensions": DIMENSION,
            "encoding_format": "float",
        },
        timeout=120,
    )
    response.raise_for_status()
    payload = response.json()
    return [item["embedding"] for item in payload["data"]]


def batch(iterable: list[str], size: int) -> Iterable[list[str]]:
    for index in range(0, len(iterable), size):
        yield iterable[index:index + size]


def build_sql(
    knowledge_bases: dict[str, dict[str, str]],
    documents: list[dict[str, str]],
    chunk_rows: list[dict[str, object]],
) -> str:
    kb_ids = [knowledge_bases[collection]["id"] for collection in COLLECTIONS]
    sql_lines = [
        "BEGIN;",
        "DELETE FROM t_knowledge_vector WHERE metadata->>'collection_name' IN ('javabackend','python','web');",
        "DELETE FROM t_knowledge_chunk WHERE kb_id IN (" + ",".join(sql_literal(kb_id) for kb_id in kb_ids) + ");",
        "DELETE FROM t_knowledge_document_chunk_log WHERE doc_id IN (SELECT id FROM t_knowledge_document WHERE kb_id IN ("
        + ",".join(sql_literal(kb_id) for kb_id in kb_ids) + "));",
        "DELETE FROM t_knowledge_document WHERE kb_id IN (" + ",".join(sql_literal(kb_id) for kb_id in kb_ids) + ");",
    ]
    for doc in documents:
        sql_lines.append(
            "INSERT INTO t_knowledge_document "
            "(id, kb_id, doc_name, enabled, chunk_count, file_url, file_type, file_size, process_mode, status, source_type, source_location, created_by, updated_by, deleted) VALUES "
            f"({sql_literal(doc['id'])}, {sql_literal(doc['kb_id'])}, {sql_literal(doc['name'])}, 1, {doc['chunk_count']}, "
            f"{sql_literal(doc['path'])}, 'md', {doc['file_size']}, 'chunk', 'success', 'file', {sql_literal(doc['path'])}, 'codex', 'codex', 0);"
        )
    for row in chunk_rows:
        sql_lines.append(
            "INSERT INTO t_knowledge_chunk "
            "(id, kb_id, doc_id, chunk_index, content, content_hash, char_count, token_count, enabled, created_by, updated_by, deleted) VALUES "
            f"({sql_literal(row['chunk_id'])}, {sql_literal(row['kb_id'])}, {sql_literal(row['doc_id'])}, {row['chunk_index']}, "
            f"{sql_literal(row['content'])}, {sql_literal(row['content_hash'])}, {row['char_count']}, {row['token_count']}, 1, 'codex', 'codex', 0);"
        )
        sql_lines.append(
            "INSERT INTO t_knowledge_vector (id, content, metadata, embedding) VALUES "
            f"({sql_literal(row['chunk_id'])}, {sql_literal(row['content'])}, {sql_literal(json.dumps(row['metadata'], ensure_ascii=False))}::jsonb, "
            f"{sql_literal(row['vector'])}::vector);"
        )
    sql_lines.append("COMMIT;")
    return "\n".join(sql_lines)


def main() -> int:
    load_dotenv()
    api_key = os.environ.get("SILICONFLOW_API_KEY")
    if not api_key:
        raise SystemExit("Missing SILICONFLOW_API_KEY")

    if not RAG_ROOT.exists():
        raise SystemExit(f"RAG root not found: {RAG_ROOT}")

    knowledge_bases = get_knowledge_bases()
    missing = [collection for collection in COLLECTIONS if collection not in knowledge_bases]
    if missing:
        raise SystemExit(f"Missing knowledge base collections: {', '.join(missing)}")

    documents = list_documents()
    chunk_rows: list[dict[str, object]] = []
    texts: list[str] = []

    for doc in documents:
        collection = doc["collection"]
        kb = knowledge_bases[collection]
        doc_seed = f"{collection}-{slugify(doc['name'])}"
        doc_id = build_id(doc_seed)
        chunks = split_chunks(doc["content"])
        doc["id"] = doc_id
        doc["kb_id"] = kb["id"]
        doc["chunk_count"] = len(chunks)
        doc["file_size"] = len(doc["content"].encode("utf-8"))
        for index, chunk in enumerate(chunks):
            chunk_id = build_id(f"{doc_seed}-{index}")
            metadata = {
                "collection_name": collection,
                "doc_id": doc_id,
                "chunk_index": index,
                "doc_name": doc["name"],
                "source_path": doc["path"],
            }
            chunk_row = {
                "chunk_id": chunk_id,
                "kb_id": kb["id"],
                "doc_id": doc_id,
                "chunk_index": index,
                "content": chunk,
                "content_hash": hashlib.sha256(chunk.encode("utf-8")).hexdigest(),
                "char_count": len(chunk),
                "token_count": max(1, len(chunk) // 3),
                "metadata": metadata,
            }
            chunk_rows.append(chunk_row)
            texts.append(chunk)

    vectors: list[list[float]] = []
    for payload in batch(texts, 32):
        vectors.extend(embed_batch(payload, api_key))

    if len(vectors) != len(chunk_rows):
        raise SystemExit(f"Embedding count mismatch: {len(vectors)} != {len(chunk_rows)}")

    for row, vector in zip(chunk_rows, vectors, strict=True):
        row["vector"] = "[" + ",".join(f"{value:.8f}" for value in vector) + "]"

    sql = build_sql(knowledge_bases, documents, chunk_rows)
    with tempfile.NamedTemporaryFile("w", suffix=".sql", delete=False, encoding="utf-8") as handle:
        handle.write(sql)
        temp_sql = handle.name

    try:
        subprocess.run(["psql", DB_URL, "-v", "ON_ERROR_STOP=1", "-f", temp_sql], check=True)
    finally:
        os.unlink(temp_sql)

    print(f"Imported documents={len(documents)}, chunks={len(chunk_rows)}, vectors={len(chunk_rows)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
