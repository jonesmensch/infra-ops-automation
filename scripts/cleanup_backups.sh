#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-/var/backups/myapp}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DRY_RUN="${DRY_RUN:-true}"

log() { echo "[cleanup_backups] $*"; }

if [[ ! -d "$TARGET_DIR" ]]; then
  log "ERRO: diretório não existe: $TARGET_DIR"
  exit 2
fi

log "Diretório: $TARGET_DIR"
log "Retenção: ${RETENTION_DAYS} dias"
log "Dry-run: $DRY_RUN"

mapfile -t files < <(find "$TARGET_DIR" -type f -mtime +"$RETENTION_DAYS" -print)

if [[ ${#files[@]} -eq 0 ]]; then
  log "Nada para remover."
  exit 0
fi

log "Arquivos candidatos (${#files[@]}):"
printf '%s\n' "${files[@]}"

if [[ "$DRY_RUN" == "true" ]]; then
  log "Dry-run habilitado. Nenhum arquivo foi removido."
  exit 0
fi

log "Removendo arquivos..."
for f in "${files[@]}"; do
  rm -f -- "$f"
done

log "Concluído."
