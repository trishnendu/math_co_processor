`include "InstructionSetHeader.v"
`include "SystemArchHeader.v"

module AU(
		input wire Global_clk,
		input wire AU_op_enable,
		input wire [`OPCODE_WIDTH-1:0] Mode,
		input wire [`DATA_WIDTH-1:0] AU_in_1,
		input wire [`DATA_WIDTH-1:0] AU_in_2,
		output reg [`DATA_WIDTH-1:0] AU_out
	);
	
	reg output_signbit;
	reg [`DATA_WIDTH-1:0] tmp_in_1, tmp_in_2, tmp_swap;

	always @(posedge AU_op_enable) begin
		tmp_in_1 = AU_in_1;
		tmp_in_1[`MSB] = 0;
		tmp_in_2 = AU_in_2;
		tmp_in_2[`MSB] = 0;
		if (Mode == `MULT | Mode == `DIV) begin
			output_signbit = AU_in_1[`MSB] ^ AU_in_2[`MSB];
		end else begin
			 if (tmp_in_1 > tmp_in_2) begin
			 	output_signbit = AU_in_1[`MSB];
			 end else begin
			 	if (Mode == `SUB) begin
			 		output_signbit = ~AU_in_2[`MSB];	
			 	end else begin
			 		output_signbit = AU_in_2[`MSB];
			 	end
			 	tmp_swap = tmp_in_1;
			 	tmp_in_1 = tmp_in_2;
			 	tmp_in_2 = tmp_swap;	
			 end
		end


		case (Mode)	
			`NOP:	begin
						$display("Stall");
					end
			`ADD:	begin
						$display("Adding in AU");
						if (AU_in_1[`MSB] ^ AU_in_2[`MSB]) begin
							AU_out = tmp_in_1 - tmp_in_2;
							AU_out[`MSB] = output_signbit;	
						end else begin
							AU_out = tmp_in_1 + tmp_in_2;
							AU_out[`MSB] = output_signbit;
						end
						
						$display("%d + %d = %d", AU_in_1, AU_in_2, AU_out);
					end

			`SUB:	begin
						$display("Substracting in AU");
						if (AU_in_1[`MSB] ^ AU_in_2[`MSB]) begin
							AU_out = tmp_in_1 + tmp_in_2;
							AU_out[`MSB] = output_signbit;	
						end else begin
							AU_out = tmp_in_1 - tmp_in_2;
							AU_out[`MSB] = output_signbit;
						end
						$display("%d - %d = %d", AU_in_1, AU_in_2, AU_out);
					end

			`MULT:	begin
						$display("Multiplying in AU");
						AU_out = AU_in_1 * AU_in_2;
						AU_out[`MSB] = output_signbit;
						$display("%d * %d = %d", AU_in_1, AU_in_2, AU_out);
					end

			`DIV:	begin
						$display("Dividing in AU");
						AU_out = AU_in_1 / AU_in_2;	
						AU_out[`MSB] = output_signbit;
						$display("%d / %d = %d", AU_in_1, AU_in_2, AU_out);
					end
		endcase
		//AU_out[`MSB] = output_signbit;							
	end
endmodule

/*
module AU_tb;
	reg [`DATA_WIDTH-1:0] A, B;
	wire [`DATA_WIDTH-1:0] Y;
	reg [`OPCODE_WIDTH-1:0] Mode;
	AU test_au(Mode, A, B, Y);

	initial begin
		#1	A = `DATA_WIDTH'h3;
			B = `DATA_WIDTH'h2;
			Mode = `ADD;
		
		$finish;
	end
endmodule
*/