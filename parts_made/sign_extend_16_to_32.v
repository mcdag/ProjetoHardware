module sign_extend_16 (
    input wire [15:0] Data_in,
    output wire [31:0] Data_out
);

    assign Data_out = (Data_in[15]) ?  {16'b1111111111111111 , Data_in } : {16'b0000000000000000 , Data_in };

endmodule