`include "SystemArchHeader.v"

`define NOP `OPCODE_WIDTH'h0
`define LDPC `OPCODE_WIDTH'h1
`define MV `OPCODE_WIDTH'h2
`define MVI `OPCODE_WIDTH'h3
`define LD `OPCODE_WIDTH'h4
`define LDI `OPCODE_WIDTH'h5
`define ST `OPCODE_WIDTH'h6
`define STI `OPCODE_WIDTH'h7
`define ADD `OPCODE_WIDTH'h8
`define ADDI `OPCODE_WIDTH'h9
`define SUB `OPCODE_WIDTH'hA
`define SUBI `OPCODE_WIDTH'hB
`define MULT `OPCODE_WIDTH'hC
`define MULTI `OPCODE_WIDTH'hD
`define DIV `OPCODE_WIDTH'hE
`define DIVI `OPCODE_WIDTH'hF
