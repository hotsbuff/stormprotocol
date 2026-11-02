# Storm Protocol

[English version](README.md)

Независимые от языка программирования описания форматов реплеев Heroes of the Storm.

Репозиторий содержит только схемы и инструменты их генерации.

## Содержимое

```text
formats/
├── mpq.ksy
├── storm_value.ksy
└── attributes_events.ksy
protocol/
└── builds/
    ├── 96477.yaml
    └── 98348.yaml
tools/
└── export_protocol.py
```

## Kaitai Struct

Файлы `.ksy` можно компилировать в парсеры для Go, Python, Java, C++, C#, Rust и других поддерживаемых языков.

- `mpq.ksy` описывает user data, заголовки MPQ и записи таблиц. Хеширование, расшифровка и распаковка выполняются использующей схему библиотекой.
- `storm_value.ksy` описывает самодостаточные versioned-значения Blizzard: массивы, структуры, варианты, optional, blob, целые и числа с плавающей точкой.
- `attributes_events.ksy` описывает `replay.attributes.events`.

Пример генерации Go-кода:

```bash
kaitai-struct-compiler \
  -t go \
  --go-package formats \
  --outdir generated \
  formats/mpq.ksy formats/storm_value.ksy formats/attributes_events.ksy
```

## YAML-схемы сборок

Файлы `protocol/builds/<build>.yaml` содержат:

- каталог `typeinfos` с границами целых, полями и числовыми тегами;
- корневые типы `header`, `details` и `initData`;
- типы дельты игрового времени и ID пользователя;
- таблицы игровых событий, сообщений и событий трекера.

YAML выполняет две задачи:

1. Привязывает числовые теги versioned-структур к именам полей.
2. Задаёт статическую схему bit-packed данных, которые не содержат собственных типов и имён полей.

Это позволяет использовать одни и те же описания в реализациях на разных языках.

Схема может наследовать другую сборку через `extends`. Например, `98348.yaml` наследует `96477` и содержит `exact: false`: это проверенный совместимый вариант, а не официальное определение протокола. Полные схемы, сгенерированные из официальных источников, содержат `exact: true`.

## Добавление сборки

Официальные определения публикуются в [Blizzard/heroprotocol](https://github.com/Blizzard/heroprotocol) как `protocol<build>.py`.

Для генерации YAML нужен Python 3 без сторонних пакетов:

```bash
python3 tools/export_protocol.py \
  https://raw.githubusercontent.com/Blizzard/heroprotocol/master/heroprotocol/versions/protocol96477.py \
  protocol/builds/96477.yaml
```

Можно также передать путь к уже загруженному `protocol<build>.py`:

```bash
python3 tools/export_protocol.py protocol96477.py protocol/builds/96477.yaml
```

Сгенерированные YAML-файлы предназначены для хранения в репозитории: потребителям схем Python не нужен.

## Форматы файлов реплея

| Файл | Кодировка |
| --- | --- |
| `replay.header` | Versioned binary |
| `replay.details` | Versioned binary |
| `replay.initData` | Bit-packed binary |
| `replay.game.events` | Поток bit-packed событий |
| `replay.message.events` | Поток bit-packed событий |
| `replay.tracker.events` | Поток versioned-событий |
| `replay.attributes.events` | Отдельная бинарная структура |

Эти потоки HotS не являются protobuf.
