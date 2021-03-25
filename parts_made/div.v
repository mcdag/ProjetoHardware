module div(
    input wire clk,
    input wire rst,
    input wire  [31:0] input_one,
    input wire  [31:0] input_two,
    output wire [31:0] output_hi,
    output wire [31:0] output_lo,
    output wire output_erro
);

assign output_erro = 0;
assign output_hi  = 31'b0000000000000000000000000000001;
assign output_hi  = 31'b0000000000000000000000000000001;

endmodule