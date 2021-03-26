module calc_Jump (
    input wire [31:0] pc,
    input wire [25:0] Data_in,
    output wire [31:0] Data_out
);

    assign pc4bits = pc[31:28];
    assign Data_out = {pc4bits,{{Data_in,2'b00}<<2}};

endmodule 