module D(
    input wire d,
    input wire reset,
    input wire clk,
    output reg q
);

    always @(negedge clk or ~reset) begin
        if(~reset) begin
            q = 0;
        end else begin
            q = d;
        end
    end
endmodule

module A(
    input wire A,
    input wire B,
    input wire reset,
    input wire clk,
    output wire sum,
    output reg carry
); 
    reg tmp;
    D my_d(tmp, reset, clk, sum);
    always begin 
        #1
        tmp = A ^ B;
        carry = A * B;
        
    end
endmodule

module tb;
reg reset, clk, A, B;
wire S, C;
A my_a(A, B, reset, clk, S, C);
always begin
    #2 clk = ~clk;
end
initial begin
    clk = 0;
    reset = 0;
    #1
    reset = 1;
    A = 1;
    B = 0;
    #4
    $display("%d %d", S, C);
    $finish;
end

endmodule


