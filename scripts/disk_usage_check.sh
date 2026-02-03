#!/usr/bin/env bash
set -euo pipefail

MOUNT="${1:-/}"
THRESHOLD="${THRESHOLD:-80}"

usage_pct=$(df -P "$MOUNT" | awk 'NR==2 {gsub("%","",$5); print $5}')
echo "[disk_usage_check] mount=$MOUNT usage=${usage_pct}% threshold=${THRESHOLD}%"

if (( usage_pct >= THRESHOLD )); then
  echo "[disk_usage_check] ALERTA: uso de disco acima do limite"
  exit 1
fi
exit 0
