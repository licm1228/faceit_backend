#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_DIR="$ROOT_DIR/scripts/pids"

service_pattern() {
  case "$1" in
    frontend) echo "node_modules/.bin/vite --host 0.0.0.0|vite --host 0.0.0.0" ;;
    mcp-server) echo "mvn -pl mcp-server spring-boot:run|MCPServerApplication" ;;
    backend) echo "mvn -pl bootstrap spring-boot:run|FaceItApplication" ;;
    *) return 1 ;;
  esac
}

stop_process() {
  local name="$1"
  local pid_file="$PID_DIR/$name.pid"
  local pattern

  pattern="$(service_pattern "$name")"

  if pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "Stopping $name..."
    pkill -f "$pattern" || true
    sleep 1
  else
    echo "$name is not running"
  fi

  rm -f "$pid_file"
}

stop_process "backend"
stop_process "mcp-server"
stop_process "frontend"
