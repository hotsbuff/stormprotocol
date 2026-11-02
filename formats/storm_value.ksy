meta:
  id: storm_value
  endian: le
seq:
  - id: kind
    type: u1
  - id: data
    type:
      switch-on: kind
      cases:
        0: array_value
        1: bit_array_value
        2: blob_value
        3: choice_value
        4: optional_value
        5: struct_value
        6: bool_value
        7: bytes4_value
        8: bytes8_value
        9: vint
types:
  vint:
    seq:
      - id: b0
        type: u1
      - id: b1
        type: u1
        if: (b0 & 128) != 0
      - id: b2
        type: u1
        if: (b0 & 128) != 0 and (b1 & 128) != 0
      - id: b3
        type: u1
        if: (b0 & 128) != 0 and (b1 & 128) != 0 and (b2 & 128) != 0
      - id: b4
        type: u1
        if: (b0 & 128) != 0 and (b1 & 128) != 0 and (b2 & 128) != 0 and (b3 & 128) != 0
      - id: b5
        type: u1
        if: (b0 & 128) != 0 and (b1 & 128) != 0 and (b2 & 128) != 0 and (b3 & 128) != 0 and (b4 & 128) != 0
      - id: b6
        type: u1
        if: (b0 & 128) != 0 and (b1 & 128) != 0 and (b2 & 128) != 0 and (b3 & 128) != 0 and (b4 & 128) != 0 and (b5 & 128) != 0
      - id: b7
        type: u1
        if: (b0 & 128) != 0 and (b1 & 128) != 0 and (b2 & 128) != 0 and (b3 & 128) != 0 and (b4 & 128) != 0 and (b5 & 128) != 0 and (b6 & 128) != 0
      - id: b8
        type: u1
        if: (b0 & 128) != 0 and (b1 & 128) != 0 and (b2 & 128) != 0 and (b3 & 128) != 0 and (b4 & 128) != 0 and (b5 & 128) != 0 and (b6 & 128) != 0 and (b7 & 128) != 0
      - id: b9
        type: u1
        if: (b0 & 128) != 0 and (b1 & 128) != 0 and (b2 & 128) != 0 and (b3 & 128) != 0 and (b4 & 128) != 0 and (b5 & 128) != 0 and (b6 & 128) != 0 and (b7 & 128) != 0 and (b8 & 128) != 0
    instances:
      negative:
        value: (b0 & 1) != 0
      unsigned_value:
        value: >-
          ((b0 >> 1) & 63).as<u8> |
          (((b0 & 128) == 0 ? 0.as<u8> : (b1 & 127).as<u8>) << 6) |
          (((b1 & 128) == 0 ? 0.as<u8> : (b2 & 127).as<u8>) << 13) |
          (((b2 & 128) == 0 ? 0.as<u8> : (b3 & 127).as<u8>) << 20) |
          (((b3 & 128) == 0 ? 0.as<u8> : (b4 & 127).as<u8>) << 27) |
          (((b4 & 128) == 0 ? 0.as<u8> : (b5 & 127).as<u8>) << 34) |
          (((b5 & 128) == 0 ? 0.as<u8> : (b6 & 127).as<u8>) << 41) |
          (((b6 & 128) == 0 ? 0.as<u8> : (b7 & 127).as<u8>) << 48) |
          (((b7 & 128) == 0 ? 0.as<u8> : (b8 & 127).as<u8>) << 55) |
          (((b8 & 128) == 0 ? 0.as<u8> : (b9 & 127).as<u8>) << 62)
      value:
        value: >-
          negative ? -unsigned_value : unsigned_value
  array_value:
    seq:
      - id: length
        type: vint
      - id: items
        type: storm_value
        repeat: expr
        repeat-expr: length.value
  bit_array_value:
    seq:
      - id: bit_length
        type: vint
      - id: data
        size: (bit_length.value + 7) / 8
  blob_value:
    seq:
      - id: length
        type: vint
      - id: data
        size: length.value
  choice_value:
    seq:
      - id: tag
        type: vint
      - id: value
        type: storm_value
  optional_value:
    seq:
      - id: present
        type: u1
      - id: value
        type: storm_value
        if: present != 0
  struct_value:
    seq:
      - id: length
        type: vint
      - id: fields
        type: struct_field
        repeat: expr
        repeat-expr: length.value
  struct_field:
    seq:
      - id: tag
        type: vint
      - id: value
        type: storm_value
  bool_value:
    seq:
      - id: value
        type: u1
  bytes4_value:
    seq:
      - id: data
        size: 4
  bytes8_value:
    seq:
      - id: data
        size: 8
