# translation-fix v2 — русский перевод сборки (TFG RU v2)

Файлы-патчи перевода TerraFirmaGreg Modern 0.13.17. Уже включены в архив
`TFG-Modern-0.13.17-TLauncher.zip` (Release `client-0.13.17`) — отдельно качать не нужно.
Эта папка — исходник патча для версионирования и для ручного применения.

## Что внутри

| Путь | Что это |
|---|---|
| `kubejs/assets/ali/lang/ru_ru.json` | AdvancedLootInfo — фильтры предметов (47 строк) |
| `kubejs/assets/guideme/lang/ru_ru.json` | Гайд GregTech (GuideME) (36 строк) |
| `kubejs/assets/jei/lang/ru_ru.json` | JEI — рецепты (11 строк) |
| `kubejs/assets/jade/lang/ru_ru.json` | Jade/Jellies — что смотришь (13 строк) |
| `kubejs/assets/voicechat/lang/ru_ru.json` | Simple Voice Chat — настройки (23 строки) |
| `kubejs/assets/ae2/lang/ru_ru.json` | Applied Energistics 2 — терминалы (35 строк) |
| `kubejs/assets/greate/lang/ru_ru.json` | Create x GregTech — машины (72 строки) |
| `kubejs/assets/tfg/lang/*/quests/extreme_voltage.json` | мёртвый ключ `higgs_emitter.title` (en+ru) |
| `kubejs/assets/tfg/lang/*/quests/tfg_tips.json` | мёртвые ключи `create_concrete_support.task`, `filters.task` (en+ru) |
| `config/ftbquests/quests/chapters/iv__insane_voltage.snbt` | глава «IV — Безумное напряжение» — реплики на русском |

Терминология согласована с официальным русским переводом GregTech CEu Modern
(«Сплав наквада», «Палладий с родиевым покрытием», «Жёрнов», «Кулисный механизм» и т.д.).

## Как применить вручную

Скопировать содержимое `kubejs/` и `config/` в `.minecraft` (клиент)
и/или в каталог сервера (`config/` — сервер, `kubejs/` — только клиенту не мешает),
с заменой файлов. Затем перезапустить игру/сервер.

## Не переведено (техническое)

~3.5 тыс. строк внутри jar-модов: tfcastikorcarts (787), matter_manipulator (426),
craftpresence (Discord RPC, 279), fluidlogistics (168), inventoryprofilesnext (166),
everycomp (165) и др. — это в основном тултипы редких экранов и конфиги,
они переводятся в самих модах. У `xaerominimap` (77) и `nochatreports` (86)
переведены основные части, длинные описания настроек остались на английском.
