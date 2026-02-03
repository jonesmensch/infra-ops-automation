#!/usr/bin/env bash
set -euo pipefail

APP_NAME="infra-ops-automation"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEPLOY_DIR="/opt/${APP_NAME}"
BIN_DIR="/usr/local/bin"
LOG_DIR="/var/log/${APP_NAME}"
CRON_FILE="/etc/cron.d/${APP_NAME}"
LOGROTATE_FILE="/etc/logrotate.d/${APP_NAME}"

echo "[install] Deploying ${APP_NAME}"
echo "[install] Source: ${SRC_DIR}"
echo "[install] Deploy: ${DEPLOY_DIR}"

# 1) Directories
sudo mkdir -p "${DEPLOY_DIR}" "${LOG_DIR}"
sudo mkdir -p /var/backups/myapp

# 2) Deploy repo to /opt (read-only-ish)
sudo rsync -a --delete "${SRC_DIR}/" "${DEPLOY_DIR}/"
sudo chown -R root:root "${DEPLOY_DIR}"

# 3) Install scripts to /usr/local/bin
sudo install -m 0755 "${DEPLOY_DIR}/scripts/cleanup_backups.sh" "${BIN_DIR}/cleanup_backups"
sudo install -m 0755 "${DEPLOY_DIR}/scripts/disk_usage_check.sh" "${BIN_DIR}/disk_usage_check"
sudo install -m 0755 "${DEPLOY_DIR}/scripts/docker_container_health.sh" "${BIN_DIR}/docker_container_health"

# 4) Cron (system-wide)
sudo tee "${CRON_FILE}" >/dev/null <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

30 3 * * * root RETENTION_DAYS=14 DRY_RUN=false cleanup_backups /var/backups/myapp >> ${LOG_DIR}/cleanup_backups.log 2>&1
*/10 * * * * root THRESHOLD=80 disk_usage_check / >> ${LOG_DIR}/disk_usage_check.log 2>&1
EOF
sudo chmod 0644 "${CRON_FILE}"

# 5) Logrotate for project logs
sudo tee "${LOGROTATE_FILE}" >/dev/null <<'EOF'
/var/log/infra-ops-automation/*.log {
  daily
  rotate 14
  compress
  missingok
  notifempty
  copytruncate
}
EOF
sudo chmod 0644 "${LOGROTATE_FILE}"

# 6) Reload cron
sudo systemctl restart cron >/dev/null 2>&1 || true

echo "[install] Done."
echo "[install] Binaries: ${BIN_DIR}/{cleanup_backups,disk_usage_check,docker_container_health}"
echo "[install] Cron: ${CRON_FILE}"
echo "[install] Logs: ${LOG_DIR}"
