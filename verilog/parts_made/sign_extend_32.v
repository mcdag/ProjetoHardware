module sign_extend_32 (
    input wire  Data_in,
    input wire [31:0] Data_out
);

    assign Data_out = {31'b0000000000000000000000000000000 , Data_in } 

endmodule 