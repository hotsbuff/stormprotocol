# Storm Protocol

[Русская версия](README.ru.md)

Language-independent format definitions for Heroes of the Storm replay files.

This repository contains only schemas and their generation tools.

## Contents

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

The `.ksy` files can be compiled into parsers for Go, Python, Java, C++, C#, Rust, and other supported languages.

- `mpq.ksy` describes MPQ user data, archive headers, and table entries. Hashing, decryption, and decompression are implemented by the consuming library.
- `storm_value.ksy` describes self-contained Blizzard versioned values: arrays, structures, choices, optionals, blobs, integers, and floating-point numbers.
- `attributes_events.ksy` describes `replay.attributes.events`.

Example Go code generation:

```bash
kaitai-struct-compiler \
  -t go \
  --go-package formats \
  --outdir generated \
  formats/mpq.ksy formats/storm_value.ksy formats/attributes_events.ksy
```

## Build YAML Schemas

Files under `protocol/builds/<build>.yaml` contain:

- the `typeinfos` catalog with integer bounds, fields, and numeric tags;
- root types for `header`, `details`, and `initData`;
- game-time delta and user ID types;
- game event, message, and tracker event tables.

YAML schemas serve two purposes:

1. Map numeric versioned-structure tags to field names.
2. Define static schemas for bit-packed data, which contains neither type information nor field names.

This allows the same definitions to be shared by implementations in different languages.

A schema can inherit another build using `extends`. For example, `98348.yaml` inherits `96477` and declares `exact: false`: it is a verified compatibility alias, not an official protocol definition. Full schemas generated from official sources declare `exact: true`.

## Adding a Build

Official definitions are published in [Blizzard/heroprotocol](https://github.com/Blizzard/heroprotocol) as `protocol<build>.py` files.

Generating YAML requires Python 3 with no third-party packages:

```bash
python3 tools/export_protocol.py \
  https://raw.githubusercontent.com/Blizzard/heroprotocol/master/heroprotocol/versions/protocol96477.py \
  protocol/builds/96477.yaml
```

A path to an already downloaded `protocol<build>.py` can also be used:

```bash
python3 tools/export_protocol.py protocol96477.py protocol/builds/96477.yaml
```

Generated YAML files are intended to be committed to the repository: schema consumers do not need Python.

## Replay File Formats

| File | Encoding |
| --- | --- |
| `replay.header` | Versioned binary |
| `replay.details` | Versioned binary |
| `replay.initData` | Bit-packed binary |
| `replay.game.events` | Bit-packed event stream |
| `replay.message.events` | Bit-packed event stream |
| `replay.tracker.events` | Versioned event stream |
| `replay.attributes.events` | Dedicated binary structure |

These HotS streams do not use protobuf.
