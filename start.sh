#!/usr/bin/env bash
# Запуск сервера TerraFirmaGreg Modern.
# Память берётся из переменной окружения RAM (по умолчанию 8G).
# Менять флаги вручную не нужно: под капотом флаги Aikar + unix_args Forge.
set -euo pipefail
cd "$(dirname "$0")"

RAM="${RAM:-8G}"
RAM_MB="$(numfmt --from=iec --to-unit=Mi "${RAM}" 2>/dev/null || echo 8192)"

FORGE_ARGS="$(find libraries -name unix_args.txt | sort | tail -n 1)"
if [ -z "${FORGE_ARGS}" ]; then
    echo "Forge не найден. Сначала запусти install.sh (он ставит Forge ${MC_VERSION:-1.20.1}-47.4.13)." >&2
    exit 1
fi

# Флаги Aikar; для кучи >= 12 ГБ — увеличенные зоны G1
if [ "${RAM_MB}" -ge 12288 ]; then
    G1="-XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15"
else
    G1="-XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20"
fi

exec java -Xms"${RAM}" -Xmx"${RAM}" \
    -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
    ${G1} \
    -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
    -Dfile.encoding=UTF-8 \
    "@${FORGE_ARGS}" nogui
