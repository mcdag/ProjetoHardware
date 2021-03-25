module cpu(
    input wire clk,
    input wire reset
);
    // Control wires
    wire PC_w;
    wire MEM_w;
    wire IR_w;
    wire BR_w;
    wire AB_w;
    wire EPC_w;
    wire HI_w;
    wire LO_w;
    wire MDR_w;
    wire ALUOut_w;
    wire [3:0] ALU_op;
    wire [2:0] Shift_op;
    wire [1:0] M_SrcA;
    wire [1:0] M_SrcB;
    wire [1:0] M_EXCEPTION;
    wire [1:0] M_IorD;
    wire [1:0] M_WRITE_REG;
    wire [1:0] M_WRITE_DATA;
    wire M_Shift_In;
    wire M_Shift_N;

    // Data wires
    wire [31:0] PC_input;
    wire [31:0] PC_out;
    wire [31:0] EPC_out;
    wire [31:0] M_EXCEPTION_out;
    wire [31:0] IR_input;
    wire [31:0] MDR_out;
    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;
    wire [32:00] SE_16_32_out;
    wire [32:00] SE_1_32_out;
    wire [32:00] SL_32_out;
    wire [31:0] M_IorD_out;
    wire [4:0] WriteReg_input;
    wire [31:0] WriteData_input;
    wire [31:0] BR_A_out;
    wire [31:0] BR_B_out;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] ALU_A_input;
    wire [31:0] ALU_B_input;
    wire [31:0] HI_LO_input;
    wire [31:0] ALU_out;
    wire [31:0] ALUOut_out;
    wire [31:0] HI_out;
    wire [31:0] LO_out;
    wire [31:0] M_ALUA_out;
    wire [31:0] M_ALUB_out;
    wire [31:0] M_Shift_In_out;
    wire [31:0] Shift_REG_out;
    wire O;
    wire N;
    wire Z;
    wire ET;
    wire LT;
    wire GT;

    Registrador PC_(
        clk,
        reset,
        PC_w,
        PC_input,
        PC_out
    );

    //mux_PCSource M_PCSource_(); -- ainda nao esta pronto

    Registrador B_(
        clk,
        reset,
        AB_w,
        BR_B_out,
        B_out
    );

    Registrador A_(
        clk,
        reset,
        AB_w,
        BR_A_out,
        A_out
    );

    Registrador HI_(
        clk,
        reset,
        HI_w,
        HI_LO_input,
        HI_out
    );

    Registrador LO_(
        clk,
        reset,
        LO_w,
        HI_LO_input,
        LO_out
    );

    Registrador EPC_(
        clk,
        reset,
        EPC_w,
        PC_input,
        EPC_out
    );

    Registrador ALUOut_(
        clk,
        reset,
        ALUOut_w,
        ALU_out,
        ALUOut_out,
    );

    Registrador MDR_(
        clk,
        reset,
        MDR_w,
        MEM_out,
        MDR_out,
    );

    Memoria MEM_(
        M_IorD_out,
        clk,
        MEM_w,
        ALU_out,
        IR_input
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

    sign_extend_16_to_32 SE_16_32_(
        OFFSET,
        SE_16_32_out
    );

    sign_extend_1_to_32 SE_1_32_(
        LT,
        SE_1_32_out
    );

    shift_left2_32 SL_32 (
        SE_16_32_out,
        SL_32_out
    );

    ula32 ALU_(
        M_ALUA_out,
        M_ALUB_out,
        ALU_op,
        ALU_out, // resultado da operacao
        O, //Overflow
        N, //Negativo
        Z, // quando S for zero 
        ET, // igual
        LT, // menor que
        GT, // maior que 
    );

    mux_exception M_EXCEPTION_(
        M_EXCEPTION,
        M_EXCEPTION_out
    );

    mux_IorD M_IorD_(
        M_IorD,
        PC_out,
        ALU_out,
        M_EXCEPTION_out,
        M_IorD_out
    );
    
    mux_ulaA M_ALUA_(
        M_SrcA,
        PC_out,
        A_out,
        B_out,
        MDR_out,
        ALU_A_input
    );

    mux_ulaB M_ALUB_(
        M_SrcB,
        B_out,
        SE_16_32_out,
        SL_32_out,
        ALU_B_input
    );

    mux_shiftInput M_shift_In_(
        M_shift_In,
        ALU_A_input,
        ALU_B_input
    );

    mux_shiftInput M_shift_In_(
        M_Shift_In,
        ALU_A_input,
        ALU_B_input,
        M_Shift_In_out
    );

    mux_shiftN M_shift_N_(
        M_Shift_N,
        OFFSET,
        ALU_B_input,
        M_Shift_N_out
    );

    RegDesloc Shift_REG_(
        clk,
        reset,
        Shift_op,
        M_Shift_N_out,
        M_Shift_In_out,
        Shift_REG_out
    );

    mux_writeReg M_Write_Reg_(
        M_WRITE_REG,
        RT,
        OFFSET,
        RS,
        WriteReg_input
    );

    mux_writeData M_Write_Data_(
        M_WRITE_DATA,
        MDR_out,
        ALUOut_out,
        HI_out,
        LO_out,
        Shift_REG_out,
        SE_1_32_out,
        WriteData_input
    );

    Banco_reg BR_(
        clk,
        reset,
        BR_w,
        RS,
        RT,
        WriteReg_input,
        WriteData_input,
        BR_A_out,
        BR_B_out
    );

endmodule