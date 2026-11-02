#!/usr/bin/env bash
# Восстановление мира и конфигов TFG-сервера из бэкапа одной командой.
#
#   bash restore-world.sh                 — показать список доступных бэкапов
#   bash restore-world.sh latest          — восстановить самый свежий
#   bash restore-world.sh /путь/к/tfg-2026-11-02_04-00.tar.gz
#
# Текущий мир перед восстановлением сохраняется в tfg-pre-restore-*.tar.gz,
# так что откат назад всегда возможен.
set -euo pipefail
SERVER_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${BACKUP_DIR:-/opt/tfg-backups}"
RUN_USER="${RUN_USER:-minecraft}"

[ "$(id -u)" -eq 0 ] || { echo "Запусти от root: sudo bash restore-world.sh"; exit 1; }

case "${1:-}" in
    ""|list|--list)
        echo "Доступные бэкапы (${BACKUP_DIR}):"
        ls -lht "${BACKUP_DIR}"/tfg-*.tar.gz 2>/dev/null | head -n 15 || echo "  (пусто)"
        echo
        echo "Использование: bash $0 latest  |  bash $0 /путь/к/бэкапу.tar.gz"
        exit 0 ;;
    latest)
        FILE="$(ls -1t "${BACKUP_DIR}"/tfg-*.tar.gz 2>/dev/null | head -n 1 || true)"
        [ -n "${FILE}" ] || { echo "Бэкапов не найдено в ${BACKUP_DIR}"; exit 1; } ;;
    *)
        FILE="${1:-}" ;;
esac
[ -f "${FILE}" ] || { echo "Файл не найден: ${FILE}"; exit 1; }

echo "Восстанавливаю из: ${FILE}"
read -r -p "Текущий мир будет ЗАМЕНЁН. Продолжить? (y/N) " ans
[ "${ans}" = "y" ] || [ "${ans}" = "Y" ] || { echo "Отмена."; exit 1; }

echo "==> Останавливаю сервер..."
systemctl stop tfg-server || true
sleep 3

echo "==> Сохраняю текущий мир на всякий случай (tfg-pre-restore-*.tar.gz)..."
ARGS=(world server.properties)
for d in config defaultconfigs kubejs tacz; do
    [ -e "${SERVER_DIR}/${d}" ] && ARGS+=("${d}") || true
done
tar -czf "${BACKUP_DIR}/tfg-pre-restore-$(date +%Y-%m-%d_%H-%M).tar.gz" \
    -C "${SERVER_DIR}" "${ARGS[@]}" 2>/dev/null || true

echo "==> Распаковываю бэкап..."
tar -xzf "${FILE}" -C "${SERVER_DIR}"
chown -R "${RUN_USER}:${RUN_USER}" "${SERVER_DIR}"

echo "==> Запускаю сервер..."
systemctl start tfg-server
echo "Готово. Лог запуска: journalctl -u tfg-server -f"
