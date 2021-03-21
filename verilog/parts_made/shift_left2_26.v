module sign_extend_16 (
    input wire [25:0] Data_in,
    output wire [27:0] Data_out
);

    assign Data_out = {{Data_in,2'b00}<<2};

endmodule 