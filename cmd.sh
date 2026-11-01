#!/usr/bin/env bash
# Отправить команду в консоль сервера без открытия screen:
#   ./cmd.sh "op ТвойНик"
#   ./cmd.sh "whitelist add НикДруза"
#   ./cmd.sh "say Всем привет!"
set -euo pipefail
[ $# -ge 1 ] || { echo "Использование: $0 \"команда\""; exit 1; }
if ! screen -ls 2>/dev/null | grep -q '\.tfg[[:space:]]'; then
    echo "Сессия screen 'tfg' не найдена — сервер не запущен? (systemctl status tfg-server)" >&2
    exit 1
fi
screen -S tfg -p 0 -X stuff "$(printf '%s\r' "$*")"
echo "Отправлено: $*"
