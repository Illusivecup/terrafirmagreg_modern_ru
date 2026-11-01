# TerraFirmaGreg Modern 0.13.17 — сервер для игры с друзьями (Beget VPS)

Готовый комплект для поднятия сервера [TerraFirmaGreg Modern 0.13.17](https://github.com/TerraFirmaGreg-Team/Modpack-Modern) (Minecraft 1.20.1, Forge 47.4.13, 217 модов) на VPS-хостинге Beget — рассчитан на компанию до 5–10 человек.

**Состав репозитория:**

| Файл | Назначение |
|---|---|
| `install.sh` | Автоустановка сервера в один запуск (Java 17, Forge, systemd, фаервол, крон бэкапов) |
| `start.sh` | Запуск сервера с флагами Aikar (память задаётся переменной `RAM`) |
| `backup.sh` | Бэкап мира и конфигов в `/opt/tfg-backups`, хранит 7 копий |
| `cmd.sh` | Отправка команд в консоль сервера без открытия screen |
| `update.sh` | Обновление сборки на новую версию (мир не трогается) |
| `tfg-server.service` | Systemd-сервис: автозапуск после перезагрузки VPS |
| `docker-compose.yml` | Вариант Б — запуск через Docker |

**Друзьям (игрокам):** инструкция по установке клиента — в ветке [`client`](https://github.com/Illusivecup/terrafirmagreg_modern_ru/tree/client), сами клиентские архивы — в [релизе client-0.13.17](https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/tag/client-0.13.17). Шейдеры в клиент уже встроены.

**Java на VPS:** нужна строго **Java 17** для MC 1.20.1 — `install.sh` ставит её сам (OpenJDK 17 из репозиториев Ubuntu). В варианте с Docker отдельная Java не нужна вообще (внутри образа itzg своя). Docker для этого не нужен и отдельным требованием не является: Ubuntu + `install.sh` — основной путь, Docker — альтернатива.

**Игра через TLauncher:** сервер по умолчанию ставится в **offline-режиме** (`MODE=offline`) — пускает TLauncher и оффлайн-ники (`online-mode=false`, `enforce-secure-profile=false`). Плата за это — обязательный вайтлист, который включается принудительно: добавь ник каждого друга (`./cmd.sh "whitelist add Ник"`), иначе на сервер никто не зайдёт, а если вайтлист выключить — под твой IP сможет войти кто угодно под любым ником. Для игры только по лицензии ставь сервер командой `MODE=licensed RAM=8G bash install.sh`. Инструкция клиенту TLauncher — в ветке [`client`](https://github.com/Illusivecup/terrafirmagreg_modern_ru/tree/client), раздел «Способ 4 — TLauncher».

---

## 1. Какой тариф Beget нужен

Важно: **обычный виртуальный хостинг Beget (для сайтов) не подойдёт** — там нет Java и долгих процессов. Нужен именно **VPS** (раздел «VPS» в панели beget.com, виртуализация KVM).

TerraFirmaGreg — тяжёлая сборка (TFC + GregTech CEu Modern + Create), официально рекомендуется 8 ГБ памяти серверу.

| Тариф Beget VPS | CPU | RAM | Диск | Цена (≈) | Итог |
|---|---|---|---|---|---|
| 4 GB | 2×3.3 ГГц | 4 ГБ | 40 ГБ | 990 ₽/мес | Не хватит |
| 6 GB | 4×3.3 ГГц | 6 ГБ | 80 ГБ | 2 040 ₽/мес | Минимум (`RAM=5G`, возможны лаги) |
| **12 GB** | **6×3.3 ГГц** | **12 ГБ** | **150 ГБ** | **3 600 ₽/мес** | **Рекомендуется (`RAM=8G`)** |
| 16 GB | 8×3.3 ГГц | 16 ГБ | 220 ГБ | 5 490 ₽/мес | Запас на 10+ игроков |

Цены примерные и могут меняться — актуальные смотри в панели Beget. Для Minecraft важна частота CPU: если бюджет позволяет, есть тарифы High-Freq 4.5 ГГц. Трафик у Beget VPS безлимитный, локация — Россия (СПб), пинг для РФ отличный.

**При заказе VPS выбери ОС Ubuntu 24.04 (или 22.04), включи бэкапы/снапшоты в панели, если они платные — решай сам.** После заказа в панели появятся IP-адрес и root-пароль (или SSH-ключ).

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
```

**Сменить память серверу:** отредактируй `Environment=RAM=...` в `/etc/systemd/system/tfg-server.service`, затем `systemctl daemon-reload && systemctl restart tfg-server`. Ориентир: отдавать серверу на 2 ГБ меньше, чем всего на VPS.

**Включить вайтлист (только свои):**

```bash
sed -i 's/^white-list=.*/white-list=true/' /opt/tfg/server.properties
systemctl restart tfg-server
```

## 4. Бэкапы и восстановление

- **Автоматически:** каждый день в 04:00 `backup.sh` складывает мир + конфиги в `/opt/tfg-backups` (хранит 7 копий).
- **Вручную:** `sudo -u minecraft /opt/tfg/backup.sh`.
- **Восстановление:** остановить сервер, распаковать архив в `/opt/tfg` с заменой, запустить.
- Плюс встроенный мод `ftbbackups2` делает свои бэкапы (частота — `config/ftbbackups2.json`, по умолчанию каждое утро 10:15; для почасовых поставь `"backup_cron": "0 0 0/1 1/1 * ? *"`).
- Снапшот всего VPS делается в панели Beget — удобно перед обновлением.

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

- **Обычный хостинг Beget подойдёт?** Нет, только VPS (нужен root, Java и открытый порт).
- **Порт закрыт / не подключиться?** Проверь `ufw status` (должен быть `25565/tcp ALLOW`), а также что клиент 0.13.17 и сервер запущен (`Done` в логе).
- **Голосовой чат?** В сборке есть Simple Voice Chat — UDP-порт 24454 уже открыт скриптом.
- **Играем только через TLauncher — так можно?** Да: `install.sh` по умолчанию ставит offline-режим (`online-mode=false`, `enforce-secure-profile=false`) и принудительно включает вайтлист. Сразу после старта добавь ники всех друзей: `./cmd.sh "whitelist add Ник"`. Держи IP в секрете и никому, кроме своих, не давай — в offline-режиме любой знающий адрес может попытаться войти под чужим ником. Скины игрокам TLauncher подставит своей системой. Если сервер уже стоит в лицензионном режиме, включи offline вручную: `sed -i 's/^online-mode=.*/online-mode=false/' /opt/tfg/server.properties && sed -i 's/^enforce-secure-profile=.*/enforce-secure-profile=false/' /opt/tfg/server.properties && sed -i 's/^white-list=.*/white-list=true/' /opt/tfg/server.properties && systemctl restart tfg-server`. Учти: прогресс игроков привязан к нику (offline-UUID), при будущем переходе на лицензию инвентарь и права по UUID сбросятся.
- **Вернуть только лицензию?** Переустанови с `MODE=licensed bash install.sh` или вручную: `online-mode=true`, `enforce-secure-profile=true`, `white-list=false` в `/opt/tfg/server.properties`, затем `systemctl restart tfg-server`.
- **Хочу домен вместо IP?** Заведи домен, добавь A-запись на IP VPS, либо SRV-запись `_minecraft._tcp` с портом 25565.
- **Сервер жрёт всё и лагает?** Проверь, что `RAM` не больше памяти VPS минус 2 ГБ; снизь `view-distance` до 6 в `server.properties`; посмотри `screen -r tfg` на предмет TPS (`/forge tps` из консоли).
