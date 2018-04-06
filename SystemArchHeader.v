`define DATA_WIDTH 16
`define OPCODE_WIDTH 4
`define REG_ADDR_WIDTH 4
`define MEM_WORD_WIDTH 16
`define MEM_ADDR_WIDTH 8

`define OPCODE_OFFSET `DATA_WIDTH
`define REG_DEST_OFFSET `OPCODE_OFFSET - `OPCODE_WIDTH
`define REG_SRC1_OFFSET `REG_DEST_OFFSET - `REG_ADDR_WIDTH 
`define REG_SRC2_OFFSET `REG_SRC1_OFFSET - `REG_ADDR_WIDTH 
`define CONST_OFFSET `REG_ADDR_WIDTH + `REG_SRC2_OFFSET