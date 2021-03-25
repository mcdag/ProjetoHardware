module shift_left2_32 (
    input wire [31:0] Data_in,
    output wire [31:0] Data_out
);

    assign Data_out = {Data_in<<2};

endmodule 