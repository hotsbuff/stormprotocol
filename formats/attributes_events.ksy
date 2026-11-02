meta:
  id: attributes_events
  endian: le
seq:
  - id: source
    type: u1
  - id: map_namespace
    type: u4
  - id: reserved
    type: u4
  - id: entries
    type: attribute
    repeat: eos
types:
  attribute:
    seq:
      - id: namespace
        type: u4
      - id: id
        type: u4
      - id: scope
        type: u1
      - id: value
        size: 4
