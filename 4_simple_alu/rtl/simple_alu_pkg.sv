package alu_pkg;

  parameter DATA_WIDTH = 8;

  typedef enum logic [2:0] {
    ADD = 3'b000,
    SUB = 3'b001,
    SLL = 3'b010,
    LSR = 3'b011,
    AND = 3'b100,
    OR  = 3'b101,
    XOR = 3'b110,
    EQL = 3'b111
  } opcode;


endpackage