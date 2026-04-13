#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/resources/docker/lightweight/milvus-stack-2.6.6.compose.yaml"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed" >&2
  exit 1
fi

if ! sudo docker version >/dev/null 2>&1; then
  echo "docker daemon is not available" >&2
  exit 1
fi

sudo docker compose -f "$COMPOSE_FILE" up -d

echo
echo "Infra stack requested:"
echo "  RustFS : http://localhost:9000"
echo "  RustFS console : http://localhost:9001"
echo "  Milvus : http://localhost:19530"
echo "  Attu : http://localhost:8000"
