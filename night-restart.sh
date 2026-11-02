#!/usr/bin/env bash
# Ночной авто-рестарт TFG-сервера: предупреждает игроков, делает свежий бэкап
# и перезапускает сервер (снимает накопившиеся утечки памяти и лаги).
# Крон настраивается install.sh (по умолчанию 05:00 по времени сервера — см. /etc/cron.d/tfg-night-restart).
#
# Ручной запуск прямо сейчас:  sudo bash /opt/tfg/night-restart.sh
# Срок предупреждения:         WARN_MIN=10 sudo bash /opt/tfg/night-restart.sh
set -uo pipefail
SERVER_DIR="$(cd "$(dirname "$0")" && pwd)"
WARN_MIN="${WARN_MIN:-5}"

up() { screen -ls 2>/dev/null | grep -q '\.tfg[[:space:]]'; }
say() { "${SERVER_DIR}/cmd.sh" "$1" >/dev/null 2>&1 || true; }

if ! up; then
    echo "Сервер не запущен — ночной рестарт пропущен ($(date '+%F %T'))"
    exit 0
fi

say "say [Авто-рестарт] Сервер перезапустится через ${WARN_MIN} мин — сохраните прогресс!"
sleep $(( WARN_MIN * 60 - 150 ))
up && say "say [Авто-рестарт] Осталось 2 минуты!"
sleep 120
up && say "say [Авто-рестарт] 30 секунд — выходим из игры!"
sleep 30

# Свежий бэкап прямо перед рестартом (внутри мир сохраняется консистентно)
"${SERVER_DIR}/backup.sh" >/dev/null 2>&1 || true

systemctl restart tfg-server
echo "Ночной рестарт выполнен ($(date '+%F %T'))"
