# TerraFirmaGreg Modern 0.13.17 — сервер для игры с друзьями (любой VPS с почасовой оплатой)

Готовый комплект для поднятия сервера [TerraFirmaGreg Modern 0.13.17](https://github.com/TerraFirmaGreg-Team/Modpack-Modern) (Minecraft 1.20.1, Forge 47.4.13, 217 модов) на любом KVM-VPS — рассчитан на компанию до 5–10 человек.

**Состав репозитория:**

| Файл | Назначение |
|---|---|
| `install.sh` | Автоустановка сервера в один запуск (Java 17, Forge, systemd, фаервол, swap, крон бэкапов и ночного рестарта) |
| `start.sh` | Запуск сервера с флагами Aikar (память задаётся переменной `RAM`) |
| `backup.sh` | Бэкап мира и конфигов в `/opt/tfg-backups`, хранит 7 копий |
| `cmd.sh` | Отправка команд в консоль сервера без открытия screen |
| `update.sh` | Обновление сборки на новую версию (мир не трогается) |
| `night-restart.sh` | Ночной авто-рестарт: предупреждает игроков, бэкапит, перезапускает (крон в 05:00) |
| `restore-world.sh` | Восстановление мира из бэкапа одной командой |
| `ШПАРГАЛКА_АДМИНА.md` | Быстрые команды на каждый день (управление, рестарты, бэкапы, вайтлист) |
| `tfg-server.service` | Systemd-сервис: автозапуск после перезагрузки VPS |
| `docker-compose.yml` | Вариант Б — запуск через Docker |

**Друзьям (игрокам):** играем через TLauncher. Готовый клиент — архив [`TFG-Modern-0.13.17-TLauncher.zip`](https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/download/client-0.13.17/TFG-Modern-0.13.17-TLauncher.zip) из [релиза client-0.13.17](https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/tag/client-0.13.17): установил Forge 1.20.1-47.4.13 в TLauncher, распаковал архив в `%appdata%` — и играешь. Сверху поставь русский патч [`TFG-RU-v2.2-Patch.zip`](https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/download/client-0.13.17/TFG-RU-v2.2-Patch.zip) (распаковать в ту же папку с заменой): полный русский перевод Полевого руководства, исправление «Ошибка загрузки!» в книге и раскладка клавиш без конфликтов. Полный разбор — в ветке [`client`](https://github.com/Illusivecup/terrafirmagreg_modern_ru/tree/client). Шейдеры, ресурспаки и русский язык уже встроены.

**Java на VPS:** нужна строго **Java 17** для MC 1.20.1 — `install.sh` ставит её сам (OpenJDK 17 из репозиториев Ubuntu). В варианте с Docker отдельная Java не нужна вообще (внутри образа itzg своя). Docker для этого не нужен и отдельным требованием не является: Ubuntu + `install.sh` — основной путь, Docker — альтернатива.

**Игра через TLauncher:** сервер по умолчанию ставится в **offline-режиме** (`MODE=offline`) — пускает TLauncher и оффлайн-ники (`online-mode=false`, `enforce-secure-profile=false`). Плата за это — обязательный вайтлист, который включается принудительно: добавь ник каждого друга (`./cmd.sh "whitelist add Ник"`), иначе на сервер никто не зайдёт, а если вайтлист выключить — под твой IP сможет войти кто угодно под любым ником. Для игры только по лицензии ставь сервер командой `MODE=licensed RAM=8G bash install.sh`. Полный разбор установки клиента через TLauncher — в ветке [`client`](https://github.com/Illusivecup/terrafirmagreg_modern_ru/tree/client).

---

## 0. Авария Beget (2 ноября 2026) — спасаем мир и переезжаем

Ночью 2.11.2026 инфраструктура Beget легла масштабно (авария признана, дата-центры восстанавливают вручную, сроки не названы). Диски, скорее всего, целы — действуем так:

1. **Как только старый VPS оживёт** — немедленно сделай бэкап и скачай на свой ПК:
   на сервере: `sudo -u minecraft /opt/tfg/backup.sh` → архив появится в `/opt/tfg-backups/`;
   на ПК (PowerShell): `scp root@СТАРЫЙ_IP:/opt/tfg-backups/tfg-*.tar.gz D:\tfg-backups\`.
2. **Не удаляй старый VPS**, пока архив мира не оказался у тебя на руках.
3. Новый сервер подними по разделам 1–2 ниже, затем верни мир: залей архив на новый сервер (`scp D:\tfg-backups\tfg-*.tar.gz root@НОВЫЙ_IP:/opt/tfg-backups/`) и выполни `sudo bash /opt/tfg/restore-world.sh latest`.
4. Пиши в поддержку Beget (одна линия общения!) и проси выгрузку/снапшот диска VPS, если панель так и не поднялась.

Быстрые команды на каждый день — в [ШПАРГАЛКА_АДМИНА.md](ШПАРГАЛКА_АДМИНА.md).

## 1. Куда переезжать: VPS с почасовой оплатой

Важно: **обычный виртуальный хостинг (для сайтов) не подойдёт** — там нет Java и долгих процессов. Нужен **облачный сервер / VPS** (KVM, Ubuntu 22.04/24.04).

TerraFirmaGreg — тяжёлая сборка (TFC + GregTech CEu Modern + Create): минимум **12 ГБ RAM** (серверу отдать `RAM=8G`), комфорт — **16 ГБ** (`RAM=12G`), диск от 60 ГБ, локация Москва/СПб.

| Хостинг | Конфигурация | Цена 24/7 (≈, ноябрь 2026) | Комментарий |
|---|---|---|---|
| **Timeweb Cloud** | 8 vCPU 3.3 ГГц / 16 ГБ / 160 ГБ NVMe | ~4 200 ₽/мес ≈ 6 ₽/час | Почасовой биллинг от 1 часа, простая панель, безлимитный трафик. **Рекомендую как прямую замену Beget** |
| **Aeza** | до 5 vCPU / 16 ГБ / NVMe | ~3 200–4 000 ₽/мес | Почасовая оплата, дешевле, игровые серверы — профильное направление |
| **Selectel** | 4 vCPU / 16 ГБ | ~7 700 ₽/мес | Надёжно, почасовая оплата, но дороже |
| **Yandex Cloud** | 8 vCPU 100% / 16 ГБ | ~17 ₽/час compute | **Остановленная ВМ не тарифицируется** (только диск ~1–2 ₽/час). Выгодно, если играете 1–2 вечера в неделю; панель сложнее |

Цены примерные — проверяй в калькуляторе хостинга. Если играете почти каждый день — бери Timeweb Cloud или Aeza и держи 24/7; если 1–2 раза в неделю — Yandex Cloud с остановкой ВМ через панель после игры.

**При заказе выбери ОС Ubuntu 24.04 (или 22.04).** После заказа в панели появятся IP-адрес и root-пароль (или SSH-ключ).

## 2. Установка — 10 минут

### Шаг 1. Подключись к VPS

С локального компьютера:

```bash
ssh root@IP_ТВОЕГО_VPS
```

### Шаг 2. Скачай этот репозиторий и запусти установку

Если репозиторий публичный:

```bash
apt update && apt install -y git
git clone https://github.com/Illusivecup/terrafirmagreg_modern_ru.git /opt/tfg-install
cd /opt/tfg-install
RAM=8G bash install.sh
```

Если репозиторий приватный — git попросит логин и пароль: **в качестве пароля используй свой GitHub-токен** (или сделай репозиторий публичным: Settings → Danger Zone → Change visibility). Токен с правом чтения кода подходит, ничего больше давать не нужно.

Скрипт сам: поставит Java 17, скачает server pack 0.13.17 (~511 МБ), установит Forge 47.4.13, примет EULA, подстроит `server.properties` (10 слотов, simulation-distance 6), создаст systemd-сервис с автозапуском, настроит фаервол (порт 25565 + голосовой чат 24454/udp) и ежедневный бэкап в 04:00.

> Скачивая и запуская сервер, ты соглашаешься с [EULA Minecraft](https://aka.ms/MinecraftEULA) (файл `eula.txt` проставляется автоматически).

### Шаг 3. Дождись первого запуска

Первый старт долгий — генерируется мир TFC (5–15 минут). Следи за прогрессом:

```bash
journalctl -u tfg-server -f
```

Когда в логе появится `Done (...)! For help, type "help"` — сервер готов.

### Шаг 4. Выдай себе админку и позови друзей

```bash
cd /opt/tfg
./cmd.sh "op ТвойНик"                 # админка
./cmd.sh "whitelist add НикДруга"     # если включишь вайтлист
```

Друзья подключаются на **`IP_ТВОЕГО_VPS:25565`** (версия клиента — обязательно **0.13.17**, как и сервер).

## 3. Управление сервером

```bash
systemctl status tfg-server      # статус
systemctl stop tfg-server        # остановить (корректно, с сохранением мира)
systemctl start tfg-server       # запустить
systemctl restart tfg-server     # перезапустить
screen -r tfg                    # открыть консоль сервера (выход: Ctrl+A, потом D)
./cmd.sh "say Перезагрузка через 5 минут"
tail -f /opt/tfg/logs/latest.log # живой лог
bash /opt/tfg/night-restart.sh   # ночной рестарт вручную (авто — ежедневно в 05:00)
sudo bash /opt/tfg/restore-world.sh latest   # откатить мир на последний бэкап
```

**Сменить память серверу:** отредактируй `Environment=RAM=...` в `/etc/systemd/system/tfg-server.service`, затем `systemctl daemon-reload && systemctl restart tfg-server`. Ориентир: отдавать серверу на 2 ГБ меньше, чем всего на VPS.

**Включить вайтлист (только свои):**

```bash
sed -i 's/^white-list=.*/white-list=true/' /opt/tfg/server.properties
systemctl restart tfg-server
```

**Текущее состояние сервера — TFG RU v2 (02.11.2026):**

- `keepInventory=true` — вещи после смерти сохраняются;
- телепорты включены (мод FTB Essentials 2001.2.4 уже в сборке): `/sethome` `/home` `/back` `/tpa` `/rtp` `/spawn` `/warp` — доступны всем игрокам без настройки;
- MOTD: `[TFG RU v2] TerraFirmaGreg Modern 0.13.17`;
- маркер версии: `/opt/tfg/TFG-RU-VERSION.txt`;
- глава квестов «IV — Безумное напряжение» и ~250 строк интерфейса переведены (см. папку `translation-fix/` в ветке `client`); бэкап английской IV-главы: `iv__insane_voltage.snbt.bak-en`;
- swap 6 ГБ добавлен как защита от OOM (`/swapfile`, swappiness=10).

## 4. Бэкапы и восстановление

- **Автоматически:** каждый день в 04:00 `backup.sh` складывает мир + конфиги в `/opt/tfg-backups` (хранит 7 копий).
- **Вручную:** `sudo -u minecraft /opt/tfg/backup.sh`.
- **Восстановление:** `sudo bash /opt/tfg/restore-world.sh latest` (список бэкапов — команда без аргументов; текущий мир перед заменой сохраняется в `tfg-pre-restore-*.tar.gz`).
- **Скачивай бэкапы на свой ПК** (`scp root@IP:/opt/tfg-backups/tfg-*.tar.gz D:\tfg-backups\`) — это единственная защита от гибели хостинга (см. раздел 0).
- Плюс встроенный мод `ftbbackups2` делает свои бэкапы (частота — `config/ftbbackups2.json`, по умолчанию каждое утро 10:15; для почасовых поставь `"backup_cron": "0 0 0/1 1/1 * ? *"`).
- Снапшот всего VPS делается в панели хостинга — удобно перед обновлением.

## 5. Обновление сборки

```bash
cd /opt/tfg-install          # или туда, где лежит update.sh
VERSION=0.13.18 bash update.sh
```

Скрипт остановит сервер, сделает бэкап, накатит новую версию поверх (мир не затрагивается). **Если в новой версии изменился Forge** — переустанови его:

```bash
cd /opt/tfg
sudo -u minecraft java -jar forge-1.20.1-<НОВАЯ_ВЕРСИЯ>-installer.jar --installServer
systemctl restart tfg-server
```

## 6. Вариант Б: Docker

Вместо systemd можно запустить всё в Docker (официальный способ сборки):

```bash
curl -fsSL https://get.docker.com | sh
git clone https://github.com/Illusivecup/terrafirmagreg_modern_ru.git /opt/tfg-docker
cd /opt/tfg-docker && docker compose up -d
docker compose logs -f
```

Данные будут в `./data`, бэкапы — в `./backups`.

## 7. Настройки, которые стоит знать (из README самой сборки)

- `defaultconfigs/tfc-server.toml` — скорость выгорания факелов/свечей (`torchTicks`, `candleTicks`) и порчи еды (`foodDecayModifier`: для компании с общей базой рекомендуют `1.0`, для сервера с игроками в разных часовых поясах — `0.25`).
- `config/ftbranks/ranks.snbt` — лимит форс-загруженных чанков на игрока (для слабого VPS уменьши).
- `config/ftbbackups2.json` — частота встроенных бэкапов.

## 8. FAQ

- **Обычный хостинг (для сайтов) подойдёт?** Нет, только VPS/облачный сервер (нужен root, Java и открытый порт).
- **Порт закрыт / не подключиться?** Проверь `ufw status` (должен быть `25565/tcp ALLOW`), а также что клиент 0.13.17 и сервер запущен (`Done` в логе).
- **Голосовой чат?** В сборке есть Simple Voice Chat — UDP-порт 24454 уже открыт скриптом.
- **Играем только через TLauncher — так можно?** Да: `install.sh` по умолчанию ставит offline-режим (`online-mode=false`, `enforce-secure-profile=false`) и принудительно включает вайтлист. Сразу после старта добавь ники всех друзей: `./cmd.sh "whitelist add Ник"`. Держи IP в секрете и никому, кроме своих, не давай — в offline-режиме любой знающий адрес может попытаться войти под чужим ником. Скины игрокам TLauncher подставит своей системой. Если сервер уже стоит в лицензионном режиме, включи offline вручную: `sed -i 's/^online-mode=.*/online-mode=false/' /opt/tfg/server.properties && sed -i 's/^enforce-secure-profile=.*/enforce-secure-profile=false/' /opt/tfg/server.properties && sed -i 's/^white-list=.*/white-list=true/' /opt/tfg/server.properties && systemctl restart tfg-server`. Учти: прогресс игроков привязан к нику (offline-UUID), при будущем переходе на лицензию инвентарь и права по UUID сбросятся.
- **Вернуть только лицензию?** Переустанови с `MODE=licensed bash install.sh` или вручную: `online-mode=true`, `enforce-secure-profile=true`, `white-list=false` в `/opt/tfg/server.properties`, затем `systemctl restart tfg-server`.
- **Хочу домен вместо IP?** Заведи домен, добавь A-запись на IP VPS, либо SRV-запись `_minecraft._tcp` с портом 25565.
- **Сервер жрёт всё и лагает?** Проверь, что `RAM` не больше памяти VPS минус 2 ГБ; снизь `view-distance` до 6 в `server.properties`; посмотри `screen -r tfg` на предмет TPS (`/forge tps` из консоли).
