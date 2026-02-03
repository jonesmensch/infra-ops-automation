=======
# Infra Ops Automation

Exemplos de automação operacional em **Linux** e **Docker**, focados em estabilidade e prevenção de incidentes:
- limpeza de backups antigos
- controle de uso de disco
- rotação de logs (logrotate)
- healthcheck e limites de recursos via docker compose

## Estrutura
- `scripts/` – automações em Bash
- `cron/` – exemplos de agendamento
- `logrotate/` – políticas de rotação de logs
- `docker/` – compose com limites e healthcheck
- `install.sh` – instalação system-wide (opcional)

## Como usar

### Limpeza de backups (dry-run)
```bash
RETENTION_DAYS=14 DRY_RUN=true ./scripts/cleanup_backups.sh /var/backups/myapp
```
>>>>>>> 626ff20 (Initial commit - infra ops automation toolkit)
