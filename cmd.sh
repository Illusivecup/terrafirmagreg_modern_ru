#!/usr/bin/env bash
# Отправить команду в консоль сервера без открытия screen:
#   ./cmd.sh "op ТвойНик"
#   ./cmd.sh "whitelist add НикДруза"
#   ./cmd.sh "say Всем привет!"
# Работает и под root, и под пользователем minecraft:
# systemd запускает сессию screen 'tfg' от пользователя minecraft,
# поэтому под root команда автоматически уходит через sudo.
set -euo pipefail
[ $# -ge 1 ] || { echo "Использование: $0 \"команда\""; exit 1; }
PAYLOAD="$(printf '%s\r' "$*")"

if screen -ls 2>/dev/null | grep -q '\.tfg[[:space:]]'; then
    screen -S tfg -p 0 -X stuff "$PAYLOAD"
elif [ "$(id -u)" -eq 0 ] && sudo -u minecraft screen -ls 2>/dev/null | grep -q '\.tfg[[:space:]]'; then
    sudo -u minecraft screen -S tfg -p 0 -X stuff "$PAYLOAD"
else
    echo "Сессия screen 'tfg' не найдена — сервер не запущен? (systemctl status tfg-server)" >&2
    exit 1
fi
echo "Отправлено: $*"
