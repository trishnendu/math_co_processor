`include "InstructionSetHeader.v"
`include "SystemArchHeader.v"
`include "SystemDelays.v"

module EXEU();
	integer i, total_clk_cycle;
	reg Global_clk, hlt;
	reg [`MEM_WORD_WIDTH-1:0] reg_bank [0:2**`REG_ADDR_WIDTH-1];
	reg [`MEM_ADDR_WIDTH-1:0] PC;
	reg [`OPCODE_WIDTH-1:0] Opcode;
	reg [`REG_ADDR_WIDTH-1:0] Dest_reg, Src_reg1, Src_reg2;
	reg [`MEM_ADDR_WIDTH-1:0] Dest_address;

	reg Write_back_sig, Read_back_sig, Read_sig, Write_sig, Mem_op_enable;
	reg [`MEM_ADDR_WIDTH-1:0] MAR;
	reg [`MEM_WORD_WIDTH-1:0] MDR_out;
	wire [`MEM_WORD_WIDTH-1:0] MDR_in;
	wire Mem_op_success;
	MEMU test_memu(Global_clk, Read_back_sig, Write_back_sig, Read_sig, Write_sig, Mem_op_enable, MAR, MDR_out, MDR_in, Mem_op_success);

	reg AU_op_enable;
	reg [`DATA_WIDTH-1:0] AU_in1, AU_in2;
	wire [`DATA_WIDTH-1:0] AU_out;
	reg [`OPCODE_WIDTH-1:0] Mode;
	AU test_au(Global_clk, AU_op_enable, Mode, AU_in1, AU_in2, AU_out);

	always begin
		#1 Global_clk = ~Global_clk;
		total_clk_cycle += 1;
	end

	initial begin
		//Reset Global_clk
		total_clk_cycle = 0;
		Global_clk = 0;
		//Start processor
		hlt = 0;
		//Load RAM from file
		Read_back_sig = 1;
		Read_back_sig = 0;
		repeat (`MEM_RWB_DELAY) begin
			@ (posedge Global_clk);
		end		
		//Load PC with starting address
		PC = `MEM_ADDR_WIDTH'h00;
		hlt = 0;
		while (!hlt) begin	
			//IF
			Read_sig = 1;
			Write_sig = 0;
			MAR = PC;
			Mem_op_enable = 1;
			Mem_op_enable = 0;
			repeat (`MEM_OP_DELAY) begin
				@ (posedge Global_clk);
			end
			$display("Executing Insruction %x%x%x%x", MDR_in[15:12], MDR_in[11:8], MDR_in[7:4], MDR_in[3:0]);
			Opcode = MDR_in[`OPCODE_OFFSET-1:`OPCODE_OFFSET-`OPCODE_WIDTH];
			
			//ID
			if (Opcode[`OPCODE_WIDTH-1]) begin   		//AU operations	
				if(Opcode[0]) begin 					//Immediate addressing mode operations- ADDI, SUBI, MULTI, DIVI
					Dest_reg = MDR_in[`REG_DEST_OFFSET-1: `REG_DEST_OFFSET - `REG_ADDR_WIDTH];
					Src_reg1 = MDR_in[`REG_SRC1_OFFSET-1:`REG_SRC2_OFFSET];
					$display("Loading Immediate");
					PC += 1;
					Read_sig = 1;
					Write_sig = 0;
					MAR = PC;
					Mem_op_enable = 1;
					Mem_op_enable = 0;
					repeat (`MEM_OP_DELAY) begin
						@ (posedge Global_clk);
					end
					AU_in1 = reg_bank[Src_reg1];
					AU_in2 = MDR_in;
					Mode = Opcode;
					Mode[0] = 0;
					AU_op_enable = 1;
					AU_op_enable = 0;
					repeat (`AU_OP_DELAY) begin
						@ (posedge Global_clk);
					end
					reg_bank[Dest_reg] = AU_out;
					for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
						$display("Reg[%x] = %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
					end
				end else begin 							//Register addressing mode operations- ADD, SUB, MULT, DIV
					Dest_reg = MDR_in[`REG_DEST_OFFSET-1:`REG_DEST_OFFSET-`REG_ADDR_WIDTH];
					Src_reg1 = MDR_in[`REG_SRC1_OFFSET-1:`REG_SRC2_OFFSET];
					Src_reg2 = MDR_in[`REG_SRC2_OFFSET-1:`REG_SRC2_OFFSET-`REG_ADDR_WIDTH];
					AU_in1 = reg_bank[Src_reg1];
					AU_in2 = reg_bank[Src_reg2];
					Mode = Opcode;
					AU_op_enable = 1;
					AU_op_enable = 0;
					repeat (`AU_OP_DELAY) begin
						@ (posedge Global_clk);
					end
					reg_bank[Dest_reg] = AU_out;
					for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
						$display("Reg[%x] = %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
					end
				end 
			end else begin  		//MEM Operations	
				case (Opcode)
					`NOP:	begin
								$display("Stalling");
							end
					`HLT:	begin
								$display("Halting");
								hlt = 1;
							end
					`MV:	begin
								Dest_reg = MDR_in[`REG_DEST_OFFSET-1:`REG_DEST_OFFSET-`REG_ADDR_WIDTH];
								Src_reg1 = MDR_in[`REG_SRC1_OFFSET-1:`REG_SRC2_OFFSET];
								$display("Moving from reg %d to reg %d", Src_reg1, Dest_reg);
								reg_bank[Dest_reg] = reg_bank[Src_reg1];
								for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
									$display("Reg[%x] = %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
								end
							end
					
					`LD:	begin
								$display("Loading");
								Dest_reg = MDR_in[`REG_DEST_OFFSET-1:`REG_DEST_OFFSET-`REG_ADDR_WIDTH];
								MAR = MDR_in[`REG_SRC1_OFFSET-1:`REG_SRC1_OFFSET-`MEM_ADDR_WIDTH];
								Read_sig = 1;
								Write_sig = 0;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
								repeat (`MEM_OP_DELAY) begin
									@ (posedge Global_clk);
								end
								reg_bank[Dest_reg] = MDR_in;
								for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
									$display("Reg[%x] = %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
								end
							end
					
					`LDI:	begin
								$display("Loading Immediate");
								Dest_reg = MDR_in[`REG_DEST_OFFSET-1:`REG_DEST_OFFSET-`REG_ADDR_WIDTH];
								PC += 1;
								Read_sig = 1;
								Write_sig = 0;
								MAR = PC;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
								repeat (`MEM_OP_DELAY) begin
									@ (posedge Global_clk);
								end
								reg_bank[Dest_reg] = MDR_in;
								for(i = 0; i < 2**`REG_ADDR_WIDTH; i+=1) begin
									$display("Reg[%x] = %x%x%x%x", i, reg_bank[i][15:12], reg_bank[i][11:8], reg_bank[i][7:4], reg_bank[i][3:0]);
								end	
							end
					`ST:	begin
								$display("Storing");
								Dest_reg = MDR_in[`REG_DEST_OFFSET-1:`REG_DEST_OFFSET-`REG_ADDR_WIDTH];
								MAR = MDR_in[`REG_SRC1_OFFSET-1:`REG_SRC1_OFFSET-`MEM_ADDR_WIDTH];
								MDR_out = reg_bank[Dest_reg];
								Read_sig = 0;
								Write_sig = 1;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
								repeat (`MEM_OP_DELAY) begin
									@ (posedge Global_clk);
								end
							end	
					`STI:	begin
								$display("Storing Immediate");
								Dest_address = MDR_in[`REG_SRC1_OFFSET-1:0];
								PC += 1;
								MAR = PC;
								Read_sig = 1;
								Write_sig = 0;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
								repeat (`MEM_OP_DELAY) begin
									@ (posedge Global_clk);
								end
								MAR = Dest_address;
								MDR_out = MDR_in;
								Read_sig = 0;
								Write_sig = 1;
								Mem_op_enable = 1;
								Mem_op_enable = 0;
								repeat (`MEM_OP_DELAY) begin
									@ (posedge Global_clk);
								end
							end
				endcase
			end
		PC += 1;	
		end
		//Write RAM back to file
		Write_back_sig = 1;
		Write_back_sig = 0;
		repeat (`MEM_RWB_DELAY) begin
			@ (posedge Global_clk);
		end
		$display("Number of clock cycle = %d", total_clk_cycle);
		$finish;			
	end	
endmodule