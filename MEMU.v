`include "SystemArchHeader.v"
`include "SystemDelays.v"

module MEMU(
		input wire Global_clk,
		input wire Read_back_sig,
		input wire Write_back_sig,
		input wire Read_sig,
		input wire Write_sig,
		input wire Mem_op_enable,
		input wire[`MEM_ADDR_WIDTH-1:0] Address_in,
		input wire[`MEM_WORD_WIDTH-1:0] Data_in,
		output reg[`MEM_WORD_WIDTH-1:0] Data_out
	);
	reg [`MEM_WORD_WIDTH-1:0] mem [0:2**`MEM_ADDR_WIDTH-1];
	integer i, file;

	always @(posedge Read_back_sig) begin
		file = $fopen("test_rom.mem", "r");
		$display ("test_rom.mem opened for readback");
		if (file == 0) begin
    		$display ("ERROR: test_rom.mem not opened");
		end else begin
			$readmemh("test_rom.mem", mem);
			//$display("%d -> %x%x%x%x", 15, mem[15][3:0], mem[15][7:4], mem[15][11:8], mem[15][15:12]);
			$display ("Successfully read back");
			$fclose(file);
		end
	end

	always @(posedge Write_back_sig) begin
		file = $fopen("test_rom.mem", "w");
		$display ("test_rom.mem opened for wirteback");
		if (file == 0) begin
    		$display ("ERROR: test_rom.mem not opened");
		end else begin
			for(i = 0; i < 2**`MEM_ADDR_WIDTH; i+=1) begin
				$fdisplay(file, "%x%x%x%x", mem[i][15:12], mem[i][11:8], mem[i][7:4], mem[i][3:0]);
			end
			$display ("Successfully written back");
			$fclose(file);
		end
	end

	always @(posedge Mem_op_enable) begin
		if (Read_sig & !Write_sig) begin
			Data_out = mem[Address_in];
			$display("Reading from Memloc %d, Data %x%x%x%x", Address_in, Data_out[15:12], Data_out[11:8], Data_out[7:4], Data_out[3:0]);
		end
		else if (Write_sig & !Read_sig) begin
			mem[Address_in] = Data_in;
			$display("Writing to Memloc %d, Data %x%x%x%x", Address_in, mem[Address_in][15:12], mem[Address_in][11:8], mem[Address_in][7:4], mem[Address_in][3:0]);
		end
		else begin
			$display("Stall");
		end
	end
endmodule

/*
module MEMU_tb();
	reg Write_back_sig, Read_back_sig, Read_sig, Write_sig, Mem_op_enable;
	reg [`MEM_ADDR_WIDTH-1:0] Address_in;
	reg [`MEM_WORD_WIDTH-1:0] Data_in;
	wire [`MEM_WORD_WIDTH-1:0] Data_out;
	wire Mem_op_success;
	MEMU test_memu(Read_back_sig, Write_back_sig, Read_sig, Write_sig, Mem_op_enable, Address_in, Data_in, Data_out, Mem_op_success);

	initial begin
			Read_back_sig = 1;
			Read_back_sig = 0;
		#1	Read_sig = 1;
			Write_sig = 0;
			Address_in = `MEM_ADDR_WIDTH'h0F;
			Mem_op_enable = 1;
			Mem_op_enable = 0;
		
		#1	Read_sig = 0;
			Write_sig = 1;
			Address_in = `MEM_ADDR_WIDTH'h0F;
			Data_in = `MEM_WORD_WIDTH'hF00F;
			Mem_op_enable = 1;
			Mem_op_enable = 0;	
		#1
			Write_back_sig = 1;
			Write_back_sig = 0;
		#1
		$finish;
	end
endmodule
*/