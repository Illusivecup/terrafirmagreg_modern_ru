# Как другу установить TerraFirmaGreg Modern и зайти на сервер

**Версии (все должны совпадать точь-в-точь):**

| Что | Версия |
|---|---|
| Сборка | **TerraFirmaGreg Modern 0.13.17** |
| Minecraft | **1.20.1** |
| Forge | **47.4.13** |
| Java | **17** (не 21!) |
| Память на клиент | **6–8 ГБ** |

---

## 1. Скачивание сборки (выбери один способ)

### Способ 1 — Prism Launcher (рекомендуется)

1. Скачай [Prism Launcher](https://prismlauncher.org) и установи.
2. Скачай файл **`TerraFirmaGreg-Modern-0.13.17-modrinth.mrpack`**:
   - у нас: [релиз client-0.13.17](https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/tag/client-0.13.17)
   - официально: [релиз TerraFirmaGreg 0.13.17](https://github.com/TerraFirmaGreg-Team/Modpack-Modern/releases/tag/0.13.17)
3. В Prism: «Добавить экземпляр» → «Импорт» → выбери скачанный `.mrpack`.
4. Запусти экземпляр. Если лаунчер попросит Java — ставь [Java 17 (Adoptium Temurin)](https://adoptium.net/temurin/releases/?version=17) или разреши Prism скачать её самому.

### Способ 2 — CurseForge App

1. Установи [CurseForge App](https://www.curseforge.com/download/app).
2. Скачай **`TerraFirmaGreg-Modern-0.13.17-curseforge.zip`** из [нашего релиза](https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/tag/client-0.13.17).
3. В CurseForge App: Minecraft → «Import» → выбери zip.

### Способ 3 — готовый архив MultiMC

Из [нашего релиза](https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/tag/client-0.13.17) (или [официального](https://github.com/TerraFirmaGreg-Team/Modpack-Modern/releases/tag/0.13.17)) возьми `TerraFirmaGreg-Modern-0.13.17-multimc.zip` и импортируй в Prism/MultiMC.

### Способ 4 — TLauncher

TLauncher не умеет импорт `.mrpack` и CurseForge-архивов, поэтому сборка ставится вручную — 10–15 минут:

1. Скачай **`TerraFirmaGreg-Modern-0.13.17-multimc.zip`** из [нашего релиза](https://github.com/Illusivecup/terrafirmagreg_modern_ru/releases/tag/client-0.13.17) — внутри уже все моды, конфиги и шейдеры.
2. В TLauncher установи Minecraft **1.20.1 с Forge 47.4.13** (в списке версий — `1.20.1-forge-47.4.13`), запусти один раз до главного меню и закрой игру. Если такой Forge в списке нет — возьми ближайший `1.20.1-forge-47.4.x`.
3. Распакуй zip — внутри папка `.minecraft`. Открой папку игры TLauncher («Папка» в интерфейсе или `%appdata%\.minecraft`) и скопируй туда содержимое распакованной `.minecraft` **с заменой файлов** (папки `mods`, `config`, `defaultconfigs`, `kubejs`, `tacz`, `shaderpacks`, `resourcepacks` и файлы из корня).
4. В настройках TLauncher (Настройки → Дополнительно → Память) выдели игре **6–8 ГБ**.
5. Войди под своим ником (оффлайн-вход). **Ник заранее скажи админу** — он добавит тебя в вайтлист, без этого сервер не пустит.

Важно: в папке `mods` от TLauncher не должно остаться чужих модов — для чистоты ставь сборку в свежую папку версии и ничего дополнительного не доустанавливай.

## 2. Настрой памяти

Экземпляр → «Изменить» → Настройки Java → **Память: минимум 6 ГБ, лучше 8 ГБ** (`-Xmx8G`). На 4 ГБ игра будет фризить на генерации мира.

## 3. Шейдеры — уже встроены!

В клиент добавлен шейдер-движок **Oculus 1.8.0** (+ Embeddium для FPS) и **два готовых пакета**:

| Пакет | Что это |
|---|---|
| **TerraFirmaGreg-Shaders-Complementary 3.1.6** | Фирменная настройка Complementary под TFG — включай её |
| **Complementary Unbound r5.9.3** | Классический Complementary Unbound |

**Включить:** в игре → Настройки → Графика → «Пакеты шейдеров» → выбери пакет → «Применить».

Если хочешь другие (по желанию, не обязательно):

| Шейдер | Версия для 1.20.1 | Скачать |
|---|---|---|
| BSL Shaders | 10.1.8 | [BSL_v10.1.8.zip](https://cdn.modrinth.com/data/Q1vvjJYV/versions/Y68yiql9/BSL_v10.1.8.zip) |
| Rethinking Voxels (тяжёлый!) | r0.1-beta9 | [rethinking-voxels_r0.1-beta9.zip](https://cdn.modrinth.com/data/kmwfVOoi/versions/cpD4esk9/rethinking-voxels_r0.1-beta9.zip) |

Скачанный zip **не распаковывай** — просто положи его в папку `shaderpacks` внутри папки экземпляра (`.minecraft/shaderpacks/`), и он появится в списке в игре. На слабом ПК шейдеры лучше не включать или снизить их качество в настройках пакета.

## 4. Подключение к серверу

1. Адрес сервера узнай у администратора (пример: `123.45.67.89:25565`).
2. В игре: «Сетевая игра» → «Добавить сервер» → вставь адрес → «Готово».
3. **Версия клиента обязана быть 0.13.17** — если сборка другая, сервер не пустит.

**Ник заранее скажи админу** — сервер работает с вайтлистом (offline-режим для TLauncher), и без добавления в список зайти не получится.

## 5. Частые проблемы

- **«Не пускает на сервер»** — сервер работает с вайтлистом: скажи админу свой точный ник (регистр важен) и дождись `whitelist add`.
- **«Out of memory»** — подними память экземпляра до 6–8 ГБ (см. шаг 2).
- **«Java 21 не подходит»** — для MC 1.20.1 нужна **Java 17**.
- **«Mismatched mod list / несовпадение модов»** — клиент установлен не полностью (чаще всего при установке через TLauncher): перепроверь, что скопировал ВСЁ содержимое `.minecraft` из архива, и не добавляй свои моды.
- **Лагает генерация мира** — первые минуты после входа игра прогружает чанки, это нормально; через 5–10 минут станет плавно.
- **Антивирус ругается на Prism** — ложное срабатывание, официальный лаунчер с открытым кодом.

Приятной игры!
