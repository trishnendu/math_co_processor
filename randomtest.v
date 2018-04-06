module randomtest;
	reg [7:0] arr;
	reg M;
	integer i, file;


	initial begin 
		file = $fopen("RAM.mem", "r");
		i = $fgets(arr, file);
		$finish;
	end

endmodule