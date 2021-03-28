module calc_Jump (
    input wire [31:0] pc,
    input wire [25:0] Data_in,
    output wire [31:0] Data_out
);

    wire [27:0] shift;

    assign pc4bits = pc[31:28];
    assign shift = {Data_in<<2};
    assign Data_out = {pc4bits,shift};

endmodule 