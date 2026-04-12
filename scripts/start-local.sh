#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/scripts/logs"
PID_DIR="$ROOT_DIR/scripts/pids"

mkdir -p "$LOG_DIR" "$PID_DIR"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

is_pid_running() {
  local pid="$1"
  kill -0 "$pid" >/dev/null 2>&1
}

service_pattern() {
  case "$1" in
    frontend) echo "node_modules/.bin/vite --host 0.0.0.0|vite --host 0.0.0.0" ;;
    mcp-server) echo "mvn -pl mcp-server spring-boot:run|MCPServerApplication" ;;
    backend) echo "mvn -pl bootstrap spring-boot:run|FaceItApplication" ;;
    *) return 1 ;;
  esac
}

service_running() {
  local name="$1"
  local pattern

  pattern="$(service_pattern "$name")"
  pgrep -f "$pattern" >/dev/null 2>&1
}

start_process() {
  local name="$1"
  local workdir="$2"
  local command="$3"
  local pid_file="$PID_DIR/$name.pid"
  local log_file="$LOG_DIR/$name.log"

  if service_running "$name"; then
    echo "$name already running"
    return 0
  fi

  rm -f "$pid_file"
  echo "Starting $name..."
  cd "$workdir"
  setsid bash -lc "$command" </dev/null >"$log_file" 2>&1 &
  echo $! >"$pid_file"
}

wait_for_http() {
  local name="$1"
  local url="$2"
  local attempts="${3:-60}"

  for ((i = 1; i <= attempts; i++)); do
    if curl -sS --max-time 2 -o /dev/null "$url" >/dev/null 2>&1; then
      echo "$name is ready: $url"
      return 0
    fi
    sleep 1
  done

  echo "$name failed to become ready: $url" >&2
  return 1
}

require_cmd npm
require_cmd mvn
require_cmd psql
require_cmd redis-cli
require_cmd curl

if ! psql "postgresql://postgres:furina@127.0.0.1:5432/faceit" -c "select 1;" >/dev/null 2>&1; then
  echo "PostgreSQL is not ready at 127.0.0.1:5432/faceit" >&2
  exit 1
fi

if ! redis-cli -a furina ping >/dev/null 2>&1; then
  echo "Redis is not ready at 127.0.0.1:6379" >&2
  exit 1
fi

if ! psql "postgresql://postgres:furina@127.0.0.1:5432/faceit" -tAc "select 1 from pg_extension where extname = 'vector';" | grep -q 1; then
  echo "Warning: pgvector extension is not installed. Vector retrieval features may be incomplete."
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Warning: docker is not installed. RustFS/Milvus stack is not available on this machine."
fi

start_process "frontend" "$ROOT_DIR/frontend" "./node_modules/.bin/vite --host 0.0.0.0"
start_process "mcp-server" "$ROOT_DIR" "mvn -pl mcp-server spring-boot:run"
start_process "backend" "$ROOT_DIR" "BAILIAN_API_KEY='' SILICONFLOW_API_KEY='' IFLYTEK_APP_ID='' IFLYTEK_API_KEY='' IFLYTEK_API_SECRET='' mvn -pl bootstrap spring-boot:run"

wait_for_http "frontend" "http://127.0.0.1:5173" 30
wait_for_http "mcp-server" "http://127.0.0.1:9099" 60
wait_for_http "backend" "http://127.0.0.1:9090/api/faceit" 60

echo
echo "Started services:"
echo "  frontend : http://localhost:5173"
echo "  backend  : http://localhost:9090/api/faceit"
echo "  mcp      : http://localhost:9099"
echo "  login    : admin / admin"
echo
echo "Logs:"
echo "  $LOG_DIR/frontend.log"
echo "  $LOG_DIR/mcp-server.log"
echo "  $LOG_DIR/backend.log"
