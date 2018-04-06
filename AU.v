`include "InstructionSetHeader.v"
`include "SystemArchHeader.v"

module AU(
		input wire AU_op_enable,
		input wire [`OPCODE_WIDTH-1:0] Mode,
		input wire [`DATA_WIDTH-1:0]	AU_in_1,
		input wire [`DATA_WIDTH-1:0]	AU_in_2,
		output reg [`DATA_WIDTH-1:0]	AU_out
	);
	

	always @(posedge AU_op_enable) begin
		case (Mode)
			`NOP:	$display("Stall");

			`ADD:	begin
						AU_out = AU_in_1 + AU_in_2;
						$display("%d + %d = %d", AU_in_1, AU_in_2, AU_out);
					end

			`SUB:	begin
						AU_out = AU_in_1 - AU_in_2;
						$display("%d - %d = %d", AU_in_1, AU_in_2, AU_out);
					end

			`MULT:	begin
						AU_out = AU_in_1 * AU_in_2;
						$display("%d * %d = %d", AU_in_1, AU_in_2, AU_out);
					end

			`DIV:	begin
						AU_out = AU_in_1 / AU_in_2;	
						$display("%d / %d = %d", AU_in_1, AU_in_2, AU_out);
					end
		endcase
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