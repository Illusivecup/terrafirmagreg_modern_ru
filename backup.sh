#!/usr/bin/env bash
# Бэкап мира и конфигов TFG-сервера. Хранит последние 7 копий в /opt/tfg-backups.
# Запуск: sudo -u minecraft /opt/tfg/backup.sh   (или через cron — уже настроен)
set -euo pipefail
SERVER_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${BACKUP_DIR:-/opt/tfg-backups}"
KEEP_DAYS=7
STAMP="$(date +%Y-%m-%d_%H-%M)"
# Страховка для диска 128 ГБ: если свободного места меньше MIN_FREE_MB,
# старые бэкапы удаляются, пока не освободится TARGET_FREE_MB.
MIN_FREE_MB="${MIN_FREE_MB:-15360}"
TARGET_FREE_MB="${TARGET_FREE_MB:-25600}"

mkdir -p "${BACKUP_DIR}"

free_mb() { df -Pm "${BACKUP_DIR}" | awk 'NR==2 {print $4}'; }
prune_for_space() {
    [ "$(free_mb)" -lt "${MIN_FREE_MB}" ] || return 0
    echo "Свободно всего $(free_mb) МБ (< ${MIN_FREE_MB}) — подчищаю старые бэкапы..."
    while [ "$(free_mb)" -lt "${TARGET_FREE_MB}" ]; do
        OLDEST="$(ls -1t "${BACKUP_DIR}"/tfg-*.tar.gz 2>/dev/null | tail -n 1 || true)"
        [ -n "${OLDEST}" ] || { echo "ВНИМАНИЕ: места мало, а удалять больше нечего! Проверь диск: df -h"; break; }
        rm -f -- "${OLDEST}"
        echo "Удалён старый бэкап: $(basename "${OLDEST}")"
    done
}
prune_for_space

# Если сервер жив — приостанавливаем запись, чтобы мир был консистентным
SERVER_UP=0
if screen -ls 2>/dev/null | grep -q '\.tfg[[:space:]]'; then
    SERVER_UP=1
    screen -S tfg -p 0 -X stuff "$(printf 'save-off\r')"
    screen -S tfg -p 0 -X stuff "$(printf 'save-all flush\r')"
    sleep 5
fi

ARGS=(world server.properties)
for d in config defaultconfigs kubejs tacz; do
    [ -e "${SERVER_DIR}/${d}" ] && ARGS+=("${d}")
done

tar -czf "${BACKUP_DIR}/tfg-${STAMP}.tar.gz" -C "${SERVER_DIR}" "${ARGS[@]}"

if [ "${SERVER_UP}" -eq 1 ]; then
    screen -S tfg -p 0 -X stuff "$(printf 'save-on\r')"
fi

find "${BACKUP_DIR}" -name 'tfg-*.tar.gz' -type f -mtime +"${KEEP_DAYS}" -delete
prune_for_space
echo "Готово: ${BACKUP_DIR}/tfg-${STAMP}.tar.gz ($(du -h "${BACKUP_DIR}/tfg-${STAMP}.tar.gz" | cut -f1)); свободно на диске: $(free_mb) МБ"
