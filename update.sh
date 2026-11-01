#!/usr/bin/env bash
# Обновление server pack до другой версии сборки.
# Мир (world) НЕ трогается — обновляются mods/config/kubejs.
#
# Использование от root:
#   VERSION=0.13.18 bash update.sh
#   или со своей ссылкой:
#   URL=https://.../TerraFirmaGreg-Modern-0.13.18-serverpack.zip bash update.sh
#
# ВНИМАНИЕ: если в новой версии сборки изменилась версия Forge — переустанови
# Forge вручную (см. README, раздел «Обновление»).
set -euo pipefail
SERVER_DIR="$(cd "$(dirname "$0")" && pwd)"
RUN_USER="${RUN_USER:-minecraft}"
VERSION="${VERSION:-0.13.17}"
URL="${URL:-https://github.com/TerraFirmaGreg-Team/Modpack-Modern/releases/download/${VERSION}/TerraFirmaGreg-Modern-${VERSION}-serverpack.zip}"

[ "$(id -u)" -eq 0 ] || { echo "Запусти от root: sudo bash update.sh"; exit 1; }

echo "==> Останавливаю сервер..."
systemctl stop tfg-server || true
sleep 3

echo "==> Бэкап перед обновлением..."
"${SERVER_DIR}/backup.sh" || true

echo "==> Скачиваю и распаковываю ${VERSION} поверх текущих файлов..."
TMP=/tmp/tfg-update-${VERSION}.zip
curl -fL --retry 3 -o "${TMP}" "${URL}"
unzip -qo "${TMP}" -d "${SERVER_DIR}"
rm -f "${TMP}"
chown -R "${RUN_USER}:${RUN_USER}" "${SERVER_DIR}"

echo "==> Запускаю сервер..."
systemctl start tfg-server
echo "Готово. Логи: journalctl -u tfg-server -f"
