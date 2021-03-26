module instruction_25 (
    input wire [15:0] offset,
    input wire [4:0] rs,
    input wire [4:0] rt,
    output wire [25:0] Data_out
);

    assign Data_out = {rs,rt,offset};

endmodule 