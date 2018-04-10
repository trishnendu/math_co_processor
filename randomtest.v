module randomtest;
	reg [7:0] arr;
	reg M;
	integer i, file;
	reg Global_clk;

	always begin
		#1 Global_clk = ~Global_clk;
		$display("Togling clk %x", Global_clk);
	end

	initial begin 
		Global_clk = 0;
		repeat (10) begin
			$display("Stalling");
			@ (posedge Global_clk);
		end
		$finish;
	end

endmodule