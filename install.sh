#!/usr/bin/env bash
###############################################################################
# TerraFirmaGreg Modern 0.13.17 — автоустановка сервера на чистый Ubuntu VPS
# Подходит для Beget VPS и любого другого KVM-VPS (Ubuntu 22.04 / 24.04).
#
# Запуск от root (находясь в каталоге с этим скриптом):
#   RAM=8G bash install.sh
#
# Что делает:
#   1. Ставит Java 17 и вспомогательные пакеты
#   2. Создаёт пользователя minecraft и каталог /opt/tfg
#   3. Скачивает server pack 0.13.17 (~511 МБ) и распаковывает
#   4. Устанавливает Forge 1.20.1-47.4.13
#   5. Принимает EULA, подстраивает server.properties
#   6. Ставит systemd-сервис tfg-server (автозапуск + screen-консоль)
#   7. Настраивает фаервол и ежедневный бэкап в 04:00
#
# Переменные (необязательные):
#   RAM=8G            сколько памяти отдать серверу (см. таблицу в README)
#   MODE=offline      режим входа: offline (TLauncher/оффлайн-ники, по умолчанию)
#                     или licensed (только лицензионные аккаунты Microsoft)
#   INSTALL_DIR=/opt/tfg   каталог сервера
#   RUN_USER=minecraft     системный пользователь
###############################################################################
set -euo pipefail

VERSION="0.13.17"
MC_VERSION="1.20.1"
FORGE_VERSION="47.4.13"
INSTALL_DIR="${INSTALL_DIR:-/opt/tfg}"
RUN_USER="${RUN_USER:-minecraft}"
RAM="${RAM:-8G}"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

# Сначала пробуем свой релиз, при недоступности (приватный репозиторий) — официальный
PACK_URL_OURS="https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/download/server-${VERSION}/TerraFirmaGreg-Modern-${VERSION}-serverpack.zip"
PACK_URL_UPSTREAM="https://github.com/TerraFirmaGreg-Team/Modpack-Modern/releases/download/${VERSION}/TerraFirmaGreg-Modern-${VERSION}-serverpack.zip"

[ "$(id -u)" -eq 0 ] || { echo "Запусти от root: sudo bash install.sh"; exit 1; }

echo "==> [1/7] Обновляю систему и ставлю пакеты (Java 17, screen, unzip, ufw)..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y openjdk-17-jre-headless screen unzip curl tar ufw cron

echo "==> [2/7] Создаю пользователя и каталог ${INSTALL_DIR}..."
id -u "${RUN_USER}" >/dev/null 2>&1 || useradd -r -m -d "${INSTALL_DIR}" -s /bin/bash "${RUN_USER}"
mkdir -p "${INSTALL_DIR}"

echo "==> [3/7] Скачиваю server pack ${VERSION} (~511 МБ)..."
PACK_TMP="/tmp/tfg-serverpack-${VERSION}.zip"
rm -f "${PACK_TMP}"
if ! curl -fL --retry 3 -o "${PACK_TMP}" "${PACK_URL_OURS}"; then
    echo "    Свой релиз недоступен (репозиторий приватный?) — беру официальный архив TerraFirmaGreg..."
    curl -fL --retry 3 -o "${PACK_TMP}" "${PACK_URL_UPSTREAM}"
fi
echo "    Распаковываю в ${INSTALL_DIR}..."
unzip -qo "${PACK_TMP}" -d "${INSTALL_DIR}"
rm -f "${PACK_TMP}"

echo "==> [4/7] Устанавливаю Forge ${MC_VERSION}-${FORGE_VERSION} (2-4 минуты)..."
chown -R "${RUN_USER}:${RUN_USER}" "${INSTALL_DIR}"
su -s /bin/bash "${RUN_USER}" -c "cd '${INSTALL_DIR}' && \
    curl -fL -o forge-installer.jar 'https://maven.minecraftforge.net/net/minecraftforge/forge/${MC_VERSION}-${FORGE_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar' && \
    java -jar forge-installer.jar --installServer && rm -f forge-installer.jar"

echo "==> [5/7] EULA, server.properties, режим входа..."
cat > "${INSTALL_DIR}/eula.txt" <<'EOF'
# Принимая это, владелец сервера соглашается с EULA Minecraft (https://aka.ms/MinecraftEULA)
eula=true
EOF
# Подстройка под компанию из 5 человек
sed -i 's/^max-players=.*/max-players=10/'        "${INSTALL_DIR}/server.properties" || true
sed -i 's/^simulation-distance=.*/simulation-distance=6/' "${INSTALL_DIR}/server.properties" || true

# Режим входа: MODE=offline (по умолчанию — TLauncher и оффлайн-ники)
# или MODE=licensed (только лицензия). В offline вайтлист включается принудительно!
if [ "${MODE:-offline}" = "licensed" ]; then
    echo "    Режим входа: LICENSED (online-mode=true) — только лицензионные аккаунты."
else
    sed -i 's/^online-mode=.*/online-mode=false/'             "${INSTALL_DIR}/server.properties" || true
    sed -i 's/^enforce-secure-profile=.*/enforce-secure-profile=false/' "${INSTALL_DIR}/server.properties" || true
    sed -i 's/^white-list=.*/white-list=true/'                "${INSTALL_DIR}/server.properties" || true
    echo "    Режим входа: OFFLINE (TLauncher). Вайтлист ВКЛЮЧЁН принудительно:"
    echo "      добавь ник каждого друга:  cd ${INSTALL_DIR} && ./cmd.sh 'whitelist add Ник'"
    echo "      без добавления в вайтлист на сервер зайти НЕ сможет никто."
fi

echo "==> [6/7] Скрипты управления..."
install -m 0755 "${SRC_DIR}/start.sh"  "${INSTALL_DIR}/start.sh"
install -m 0755 "${SRC_DIR}/backup.sh" "${INSTALL_DIR}/backup.sh"
install -m 0755 "${SRC_DIR}/cmd.sh"    "${INSTALL_DIR}/cmd.sh"

echo "==> [7/7] Systemd-сервис, бэкап-крон, фаервол..."
sed -e "s|__INSTALL_DIR__|${INSTALL_DIR}|g" \
    -e "s|__RUN_USER__|${RUN_USER}|g" \
    -e "s|__RAM__|${RAM}|g" \
    "${SRC_DIR}/tfg-server.service" > /etc/systemd/system/tfg-server.service
systemctl daemon-reload
systemctl enable tfg-server

# Ежедневный бэкап в 04:00
mkdir -p /opt/tfg-backups
chown "${RUN_USER}:${RUN_USER}" /opt/tfg-backups
cat > /etc/cron.d/tfg-backup <<EOF
# Ежедневный бэкап TFG-сервера (мир + конфиги), хранить 7 копий
0 4 * * * ${RUN_USER} ${INSTALL_DIR}/backup.sh >> /opt/tfg-backups/cron.log 2>&1
EOF

if command -v ufw >/dev/null 2>&1; then
    ufw allow OpenSSH   >/dev/null 2>&1 || true
    ufw allow 25565/tcp >/dev/null 2>&1 || true
    ufw allow 24454/udp >/dev/null 2>&1 || true   # Simple Voice Chat
    yes | ufw enable >/dev/null 2>&1 || true
fi

chown -R "${RUN_USER}:${RUN_USER}" "${INSTALL_DIR}"
systemctl start tfg-server

IP=$(curl -s --max-time 5 https://api.ipify.org || hostname -I | awk '{print $1}')
echo
echo "================================ Готово ================================"
echo " Сервер запускается. Первый старт (генерация мира TFC): 5-15 минут."
echo " Прогресс:              journalctl -u tfg-server -f"
echo " Консоль сервера:       screen -r tfg   (выйти: Ctrl+A, потом D)"
echo
echo " Адрес для друзей:      ${IP}:25565"
echo
echo " Выдать админку:        ./cmd.sh 'op ТвойНик'"
echo " Добавить в вайтлист:   ./cmd.sh 'whitelist add Ник'"
echo " Включить вайтлист:     sed -i 's/^white-list=.*/white-list=true/' ${INSTALL_DIR}/server.properties && systemctl restart tfg-server"
echo
echo " Остановить:            systemctl stop tfg-server"
echo " Перезапустить:         systemctl restart tfg-server"
echo " Сменить память:        правь Environment=RAM=... в /etc/systemd/system/tfg-server.service, затем systemctl daemon-reload && systemctl restart tfg-server"
echo " Бэкап вручную:         sudo -u ${RUN_USER} ${INSTALL_DIR}/backup.sh"
echo "========================================================================"
