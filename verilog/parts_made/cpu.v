module cpu(
    input wire clk,
    input wire reset
);
    // Control wires
    wire PC_w;
    wire MEM_w;
    wire IR_w;
    wire REG_w;
    wire AB_w;
    wire EPC_w;
    wire [1:0] M_EXCEPTION;
    wire [1:0] M_RMEM;

    // Data wires
    wire [31:0] PC_input;
    wire [31:0] IR_input;
    wire [31:0] ULA_A_input;
    wire [31:0] ULA_B_input;
    wire [31:0] PC_out;
    wire [31:0] MEM_out;
    wire [31:0] BR_A_out;
    wire [31:0] BR_B_out;
    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;
    wire [31:0] M_EXCEPTION_out;
    wire [31:0] M_RMEM_out;

    Registrador PC_(
        clk,
        reset,
        PC_w,
        PC_input,
        PC_out
    );

    Registrador B_(
        clk,
        reset,
        AB_w,
        BR_B_out,
        ULA_B_input
    );

    Registrador A_(
        clk,
        reset,
        AB_w,
        BR_A_out,
        ULA_A_input
    );

    Registrador EPC_(
        clk,
        reset,
        PC_w,
        PC_input,
        PC_out
    );

    Memoria MEM_(
        M_RMEM_out,
        clk,
        MEM_w,
        ULA_out,
        MEM_out
    );

    Instr_Reg IR_(
        clk,
        reset,
        IR_w,
        IR_input,
        OPCODE,
        RS,
        RT,
        OFFSET
    );


    mux_exception M_EXCEPTION_(
        M_EXCEPTION,
        M_EXCEPTION_out
    );

    mux_inputPC M_RMEM_(
        M_RMEM,
        PC_out,
        ULA_out,
        M_EXCEPTION_out,
        M_RMEM_out
    );



    // Banco_reg REG_BASE (
    //     clk,
    //     reset,
    //     REG_w,
    //     RS, // na verdade vamos usar o mux "mux_readReg1", ainda não sabemos quem são os registradores hi e lo
    //     RT, 
    //     WriteReg, // na verdade vamos usar o mux "mux_writeReg", ainda não sabemos quem são os registradores hi,lo e ra
    //     WriteData, // mux ainda nao completo pq causa da mutiplicacao e divisao
    //     ReadData1,
    //     ReadData2
    // );

endmodule