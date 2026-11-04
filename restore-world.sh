#!/usr/bin/env bash
# Восстановление мира TFG-сервера: из своего бэкапа ИЛИ из архива с чужого ПК
# (например, мир, который хостил друг на своём компьютере).
#
#   bash restore-world.sh                          — показать список бэкапов и архивов
#   bash restore-world.sh latest                   — восстановить самый свежий бэкап (tfg-*.tar.gz)
#   bash restore-world.sh /путь/к/архиву         — развернуть мир из zip / tar.gz / tar / rar
#                                                    (например: /opt/tfg-backups/mir.zip или mir.rar)
#
# Как работает:
#   • архив СНАЧАЛА распаковывается и проверяется (level.dat + region/*.mca), и только потом
#     останавливается сервер — битый архив не оставит сервер в простое;
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
        ls -lht "${BACKUP_DIR}" 2>/dev/null | awk 'NR>1 && $NF !~ /^tfg-/ && $NF ~ /\.(zip|tar|tar\.gz|tgz|rar)$/' | head -n 15 || true
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

MODE="own"
TMP=""
WORLD_SRC=""
case "$(basename "${FILE}")" in
    tfg-*.tar.gz|tfg-*.tgz)
        MODE="own"   # распаковка ниже, сервер трогаем только после подтверждения
        ;;
    *)
        # Чужой архив (мир от друга): СНАЧАЛА распаковываем и проверяем — сервер не трогаем.
        # Так битый/недокачанный архив не оставит сервер в простое.
        MODE="friend"
        echo "==> Распаковываю и проверяю архив (сервер продолжает работать)..."
        mkdir -p "${TMP_ROOT}"
        TMP="$(mktemp -d "${TMP_ROOT}/restore-XXXXXX")"
        LOWCASE="$(basename "${FILE}")"
        LOWCASE="${LOWCASE,,}"
        case "${LOWCASE}" in
            *.zip)          unzip -qo "${FILE}" -d "${TMP}" ;;
            *.tar.gz|*.tgz) tar -xzf "${FILE}" -C "${TMP}" ;;
            *.tar)          tar -xf  "${FILE}" -C "${TMP}" ;;
            *.rar)
                if ! command -v unar >/dev/null 2>&1; then
                    echo "==> Ставлю unar (поддержка rar)..."
                    apt-get update -qq >/dev/null 2>&1 || true
                    apt-get install -y -qq unar >/dev/null 2>&1 || { echo "Не удалось поставить unar. Попроси друга прислать zip."; rm -rf "${TMP}"; exit 1; }
                fi
                if ! unar -q -f -o "${TMP}" "${FILE}"; then
                    echo ""
                    echo "ОШИБКА: архив повреждён (недокачан при передаче). Сервер НЕ тронут."
                    echo "Попроси прислать архив заново (лучше ZIP) и сравни размер в байтах с оригиналом."
                    rm -rf "${TMP}"
                    exit 1
                fi
                ;;
            *) echo "Не знаю такой формат. Поддерживаются: .zip, .tar.gz, .tgz, .tar, .rar"; rm -rf "${TMP}"; exit 1 ;;
        esac
        mapfile -t CANDIDATES < <(find "${TMP}" -type f -name 'level.dat' -printf '%h\n' | sort -u)
        if [ "${#CANDIDATES[@]}" -eq 0 ]; then
            echo "ОШИБКА: в архиве нет файла level.dat — значит, заархивирована НЕ папка мира."
            echo "Нужна папка, внутри которой лежат level.dat и region/. Содержимое архива:"
            find "${TMP}" -maxdepth 3 | head -n 20
            rm -rf "${TMP}"
            exit 1
        fi
        for d in "${CANDIDATES[@]}"; do
            if [ "$(basename "${d}")" = "world" ]; then WORLD_SRC="${d}"; break; fi
        done
        [ -n "${WORLD_SRC}" ] || WORLD_SRC="$(printf '%s\n' "${CANDIDATES[@]}" | awk '{print length"\t"$0}' | sort -n | head -n 1 | cut -f2-)"
        NREG="$(find "${WORLD_SRC}/region" -name '*.mca' 2>/dev/null | wc -l)"
        [ "${NREG}" -gt 0 ] || { echo "ОШИБКА: в папке мира нет region/*.mca — мир пустой или битый. Сервер НЕ тронут."; rm -rf "${TMP}"; exit 1; }
        echo "    Папка мира: ${WORLD_SRC} ($(du -sh "${WORLD_SRC}" | cut -f1), region-файлов: ${NREG})"
        ;;
esac

read -r -p "Текущий мир будет ЗАМЕНЁН. Продолжить? (y/N) " ans
[ "${ans}" = "y" ] || [ "${ans}" = "Y" ] || { echo "Отмена."; [ -z "${TMP}" ] || rm -rf "${TMP}"; exit 1; }

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

if [ "${MODE}" = "own" ]; then
    echo "==> Это наш бэкап — распаковываю целиком (мир + конфиги)..."
    tar -xzf "${FILE}" -C "${SERVER_DIR}"
else
    echo "==> Подменяю только world (конфиги сервера не трогаю)..."
    rm -rf "${SERVER_DIR}/world"
    cp -a "${WORLD_SRC}" "${SERVER_DIR}/world"
    chown -R "${RUN_USER}:${RUN_USER}" "${SERVER_DIR}/world"
    rm -rf "${TMP}"
fi
chown -R "${RUN_USER}:${RUN_USER}" "${SERVER_DIR}" 2>/dev/null || true

echo "==> Запускаю сервер..."
systemctl start tfg-server
echo "Готово. Прогресс игрока привязан к нику — если ники те же, что были у друга, всё приедет с собой."
echo "Лог запуска (мир большой — ждём 3–10 минут до строки Done): journalctl -u tfg-server -f"
