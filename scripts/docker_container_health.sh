#!/usr/bin/env bash
set -euo pipefail

echo "[docker_container_health] Containers em execução:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

echo
echo "[docker_container_health] Containers parados (se houver):"
docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
