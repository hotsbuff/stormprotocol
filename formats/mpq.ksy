meta:
  id: mpq
  endian: le
seq:
  - id: user_data_header
    type: user_data_header
instances:
  archive_header:
    pos: user_data_header.archive_header_offset
    type: archive_header
types:
  user_data_header:
    seq:
      - id: magic
        contents: MPQ
      - id: version
        type: u1
      - id: user_data_size
        type: u4
      - id: archive_header_offset
        type: u4
      - id: user_data_header_size
        type: u2
      - id: format_version
        type: u2
      - id: content
        size: user_data_size
  archive_header:
    seq:
      - id: magic
        contents: MPQ
      - id: version
        type: u1
      - id: header_size
        type: u4
      - id: archive_size
        type: u4
      - id: format_version
        type: u2
      - id: sector_size_shift
        type: u2
      - id: hash_table_offset
        type: u4
      - id: block_table_offset
        type: u4
      - id: hash_table_entries
        type: u4
      - id: block_table_entries
        type: u4
      - id: hi_block_table_offset
        type: u8
        if: format_version >= 1
      - id: hash_table_offset_high
        type: u2
        if: format_version >= 1
      - id: block_table_offset_high
        type: u2
        if: format_version >= 1
      - id: archive_size_64
        type: u8
        if: format_version >= 2
      - id: bet_table_offset
        type: u8
        if: format_version >= 2
      - id: het_table_offset
        type: u8
        if: format_version >= 2
      - id: hash_table_size_64
        type: u8
        if: format_version >= 3
      - id: block_table_size_64
        type: u8
        if: format_version >= 3
      - id: hi_block_table_size_64
        type: u8
        if: format_version >= 3
      - id: het_table_size_64
        type: u8
        if: format_version >= 3
      - id: bet_table_size_64
        type: u8
        if: format_version >= 3
      - id: raw_chunk_size
        type: u4
        if: format_version >= 4
      - id: table_checksums
        size: 96
        if: format_version >= 4
    instances:
      sector_size:
        value: 512 << sector_size_shift
  hash_table_entry:
    seq:
      - id: name_hash_a
        type: u4
      - id: name_hash_b
        type: u4
      - id: locale
        type: u2
      - id: platform
        type: u2
      - id: block_index
        type: u4
  block_table_entry:
    seq:
      - id: offset
        type: u4
      - id: compressed_size
        type: u4
      - id: uncompressed_size
        type: u4
      - id: flags
        type: u4
