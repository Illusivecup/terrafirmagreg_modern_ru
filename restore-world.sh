#!/usr/bin/env bash
# Восстановление мира TFG-сервера: из своего бэкапа ИЛИ из архива с чужого ПК
# (например, мир, который хостил друг на своём компьютере).
#
#   bash restore-world.sh                          — показать список бэкапов и архивов
#   bash restore-world.sh latest                   — восстановить самый свежий бэкап (tfg-*.tar.gz)
#   bash restore-world.sh /путь/к/архиву.zip       — развернуть мир из zip / tar.gz / tar
#                                                    (например: /opt/tfg-backups/mir-ot-druga.zip)
#
# Как работает:
#   • в архиве автоматически находится папка мира (по файлу level.dat);
#   • подменяется ТОЛЬКО каталог world — конфиги сервера не трогаются;
#   • текущий мир перед заменой сохраняется в tfg-pre-restore-*.tar.gz (откат всегда возможен);
#   • свой бэкап tfg-*.tar.gz разворачивается целиком (мир + конфиги), как раньше.
set -euo pipefail
SERVER_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${BACKUP_DIR:-/opt/tfg-backups}"
RUN_USER="${RUN_USER:-minecraft}"
TMP_ROOT="/opt/tfg-restore-tmp"

[ "$(id -u)" -eq 0 ] || { echo "Запусти от root: sudo bash restore-world.sh"; exit 1; }

case "${1:-}" in
    ""|list|--list)
        echo "Свои бэкапы (${BACKUP_DIR}):"
        ls -lht "${BACKUP_DIR}"/tfg-*.tar.gz 2>/dev/null | head -n 15 || echo "  (пусто)"
        echo
        echo "Другие архивы в ${BACKUP_DIR} (например, мир от друга):"
        ls -lht "${BACKUP_DIR}" 2>/dev/null | awk 'NR>1 && $NF !~ /^tfg-/ && $NF ~ /\.(zip|tar|tar\.gz|tgz)$/' | head -n 15 || true
        echo
        echo "Использование: bash $0 latest  |  bash $0 /путь/к/архиву.zip"
        exit 0 ;;
    latest)
        FILE="$(ls -1t "${BACKUP_DIR}"/tfg-*.tar.gz 2>/dev/null | head -n 1 || true)"
        [ -n "${FILE}" ] || { echo "Бэкапов не найдено в ${BACKUP_DIR}"; exit 1; } ;;
    *)
        FILE="${1:-}" ;;
esac
[ -f "${FILE}" ] || { echo "Файл не найден: ${FILE}"; exit 1; }

echo "Архив: ${FILE} ($(du -h "${FILE}" | cut -f1))"
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
mkdir -p "${BACKUP_DIR}"
tar -czf "${BACKUP_DIR}/tfg-pre-restore-$(date +%Y-%m-%d_%H-%M).tar.gz" \
    -C "${SERVER_DIR}" "${ARGS[@]}" 2>/dev/null || true

case "$(basename "${FILE}")" in
    tfg-*.tar.gz|tfg-*.tgz)
        # Свой бэкап backup.sh — разворачиваем целиком (мир + конфиги), как раньше
        echo "==> Это наш бэкап — распаковываю целиком (мир + конфиги)..."
        tar -xzf "${FILE}" -C "${SERVER_DIR}"
        ;;
    *)
        # Чужой архив (мир от друга) — достаём только папку мира
        echo "==> Ищу папку мира внутри архива (по файлу level.dat)..."
        mkdir -p "${TMP_ROOT}"
        TMP="$(mktemp -d "${TMP_ROOT}/restore-XXXXXX")"
        LOWCASE="$(basename "${FILE}")"
        LOWCASE="${LOWCASE,,}"
        case "${LOWCASE}" in
            *.zip)          unzip -qo "${FILE}" -d "${TMP}" ;;
            *.tar.gz|*.tgz) tar -xzf "${FILE}" -C "${TMP}" ;;
            *.tar)          tar -xf  "${FILE}" -C "${TMP}" ;;
            *) echo "Не знаю такой формат. Поддерживаются: .zip, .tar.gz, .tgz, .tar"; rm -rf "${TMP}"; exit 1 ;;
        esac
        mapfile -t CANDIDATES < <(find "${TMP}" -type f -name 'level.dat' -printf '%h\n' | sort -u)
        if [ "${#CANDIDATES[@]}" -eq 0 ]; then
            echo "ОШИБКА: в архиве нет файла level.dat — значит, заархивирована НЕ папка мира."
            echo "Нужна папка, внутри которой лежат level.dat и region/. Содержимое архива:"
            find "${TMP}" -maxdepth 3 | head -n 20
            rm -rf "${TMP}"
            exit 1
        fi
        WORLD_SRC=""
        for d in "${CANDIDATES[@]}"; do
            if [ "$(basename "${d}")" = "world" ]; then WORLD_SRC="${d}"; break; fi
        done
        [ -n "${WORLD_SRC}" ] || WORLD_SRC="$(printf '%s\n' "${CANDIDATES[@]}" | awk '{print length"\t"$0}' | sort -n | head -n 1 | cut -f2-)"
        echo "    Папка мира: ${WORLD_SRC}"
        echo "==> Подменяю только world (конфиги сервера не трогаю)..."
        rm -rf "${SERVER_DIR}/world"
        cp -a "${WORLD_SRC}" "${SERVER_DIR}/world"
        chown -R "${RUN_USER}:${RUN_USER}" "${SERVER_DIR}/world"
        rm -rf "${TMP}"
        ;;
esac
chown -R "${RUN_USER}:${RUN_USER}" "${SERVER_DIR}" 2>/dev/null || true

echo "==> Запускаю сервер..."
systemctl start tfg-server
echo "Готово. Прогресс игрока привязан к нику — если ники те же, что были у друга, всё приедет с собой."
echo "Лог запуска (мир большой — ждём 3–10 минут до строки Done): journalctl -u tfg-server -f"
