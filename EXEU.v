`include "InstructionSetHeader.v"
`include "SystemArchHeader.v"

module EXEU();
	
	reg [`MEM_WORD_WIDTH-1:0] reg_bank [0:2**`REG_ADDR_WIDTH-1];
	reg [`MEM_ADDR_WIDTH-1:0] PC;
	reg [`MEM_WORD_WIDTH-1:0] I_in;
	reg [`OPCODE_WIDTH-1:0] Opcode;
	reg [`REG_ADDR_WIDTH-1:0] Dest_reg, Src_reg1, Src_reg2;
	reg [`MEM_ADDR_WIDTH-1:0] Dest_address;

	reg Write_back_sig, Read_back_sig, Read_sig, Write_sig, Mem_op_enable;
	reg [`MEM_ADDR_WIDTH-1:0] Address_in;
	reg [`MEM_WORD_WIDTH-1:0] Data_in;
	wire [`MEM_WORD_WIDTH-1:0] Data_out;
	wire Mem_op_success;
	MEMU test_memu(Write_back_sig, Read_back_sig, Read_sig, Write_sig, Mem_op_enable, Address_in, Data_in, Data_out, Mem_op_success);

	reg AU_op_enable;
	reg [`DATA_WIDTH-1:0] AU_in1, AU_in2;
	wire [`DATA_WIDTH-1:0] AU_out;
	reg [`OPCODE_WIDTH-1:0] Mode;
	AU test_au(AU_op_enable, Mode, AU_in1, AU_in2, AU_out);

	integer i;
	initial begin
		//Load RAM
			Read_back_sig = 1;
			Read_back_sig = 0;
		//Load PC
		#1	PC = `MEM_ADDR_WIDTH'h00;
			while (PC < 10) begin	
				//IF
				Read_sig = 1;
				Write_sig = 0;
				Address_in = PC;
				Mem_op_enable = 1;
				Mem_op_enable = 0;
			#1
				$display("IN EXEU Data %x%x%x%x", Data_out[15:12], Data_out[11:8], Data_out[7:4], Data_out[3:0]);
				Opcode = Data_out[`OPCODE_OFFSET-1:`OPCODE_OFFSET-`OPCODE_WIDTH];
				
				//ID
				if (Opcode[`OPCODE_WIDTH-1]) begin
					$display("AU operation");
					if(Opcode[0]) begin
						Dest_reg = Data_out[`REG_DEST_OFFSET-1:`REG_SRC1_OFFSET];
						Src_reg1 = Data_out[`REG_SRC1_OFFSET-1:`REG_SRC2_OFFSET];
						PC += 1;
						Read_sig = 1;
						Write_sig = 0;
						Address_in = PC;
						Mem_op_enable = 1;
						Mem_op_enable = 0;
						#1 
						AU_in1 = reg_bank[Src_reg1];
						AU_in2 = Data_out;
						Mode = Opcode;
						Mode[0] = 0;
						AU_op_enable = 1;
						AU_op_enable = 0;
						#1 reg_bank[Dest_reg] = AU_out;
						for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
							$display("Reg[%d] %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
						end
					end else begin
						Dest_reg = Data_out[`REG_DEST_OFFSET-1:`REG_SRC1_OFFSET];
						Src_reg1 = Data_out[`REG_SRC1_OFFSET-1:`REG_SRC2_OFFSET];
						Src_reg2 = Data_out[`REG_SRC2_OFFSET-1:0];
						AU_in1 = reg_bank[Src_reg1];
						AU_in2 = reg_bank[Src_reg2];
						Mode = Opcode;
						AU_op_enable = 1;
						AU_op_enable = 0;
						#1 reg_bank[Dest_reg] = AU_out;
						for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
							$display("Reg[%d] %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
						end
					end 
				end else begin
				
				case (Opcode)
					`LD:	begin
								$display("Loading");
								Dest_reg = Data_out[`REG_DEST_OFFSET-1:`REG_DEST_OFFSET-`REG_ADDR_WIDTH];
								Address_in = Data_out[`REG_SRC1_OFFSET-1:0];
								Read_sig = 1;
								Write_sig = 0;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
								#1 reg_bank[Dest_reg] = Data_out;
								for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
									$display("Reg[%d] %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
								end
							end
					
					`LDI:	begin
								$display("Loading Immediate");
								Dest_reg = Data_out[`REG_DEST_OFFSET-1:`REG_DEST_OFFSET-`REG_ADDR_WIDTH];
								PC += 1;
								Read_sig = 1;
								Write_sig = 0;
								Address_in = PC;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
								#1 reg_bank[Dest_reg] = Data_out;
								for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
									$display("Reg[%d] %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
								end	
							end
					`ST:	begin
								$display("Storing");
								Dest_reg = Data_out[`REG_DEST_OFFSET-1:`REG_DEST_OFFSET-`REG_ADDR_WIDTH];
								Address_in = Data_out[`REG_SRC1_OFFSET-1:0];
								Data_in = reg_bank[Dest_reg];
								Read_sig = 0;
								Write_sig = 1;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
							end	
					`STI:	begin
								$display("Storing Immediate");
								Dest_address = Data_out[`REG_SRC1_OFFSET-1:0];
								PC += 1;
								Address_in = PC;
								Read_sig = 1;
								Write_sig = 0;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
								#1 
								Address_in = Dest_address;
								Data_in = Data_out;
								Read_sig = 0;
								Write_sig = 1;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
							end
				endcase
				end
			PC += 1;	
			
			end
		#1	Write_back_sig = 1;
			Write_back_sig = 0;
				
	end	
endmodule