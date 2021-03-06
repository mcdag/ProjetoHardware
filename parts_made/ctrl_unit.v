module ctrl_unit (
  input wire       clk,
  input wire       reset,

//Flags -- ULA
  input wire       Overflow,
  input wire       NG,
  input wire       ZR,
  input wire       EQ,
  input wire       GT,
  input wire       LT,

//Inputs with 1 bit
  input wire       ErroDiv,

//Meaningful parte of the instruction
  input wire [5:0] OPCODE,
  input wire [15:0] OFFSET,

//Controllers with 1 bit
  output reg   PCwrite,
  output reg   MemWrite,
  output reg   IRWrite,
  output reg   BRWrite,
  output reg   ABWrite,
  output reg   EPCWrite,
  output reg   HIWrite,
  output reg   LOWrite,
  output reg   MDRWrite,
  output reg   ALUOutWrite,

//Controllers with more than 1 bit
  output reg [2:0] ALUOp,
  output reg [2:0] ShiftCtrl,
  

//Controller for muxes
  output reg       MultOrDiv,
  output reg       HiOrLow,
  output reg       Shiftln,
  output reg [1:0] IorD,
  output reg [1:0] RegDst,
  output reg [1:0] ALUSrcA,
  output reg [1:0] ALUSrcB,
  output reg [1:0] ShiftAmt,
  output reg [1:0] Exception,
  output reg [2:0] MemToReg,
  output reg [2:0] PCSource,

//Especial controller for reset instruction
  output reg       rst_out
);

  // variables
  reg [5:0] STATE;
  reg [2:0] COUNTER;

  wire [5:0] FUNCT = OFFSET[5:0];

  // states
  parameter ST_RESET     = 6'b000000;
  parameter ST_COMMON    = 6'b000001;
  parameter ST_ADD       = 6'b000010;
  parameter ST_ADDI      = 6'b000011;
  parameter ST_SUB       = 6'b000100;
  parameter ST_BEQ       = 6'b000111;
  parameter ST_BNE       = 6'b001000;
  parameter ST_BLE       = 6'b001001;
  parameter ST_BGT       = 6'b001010;
  parameter ST_AND       = 6'b001011;
  parameter ST_DIV       = 6'b001100;
  parameter ST_MULT      = 6'b001101;
  parameter ST_BREAK     = 6'b001111;
  parameter ST_RTE       = 6'b010000;
  parameter ST_JR        = 6'b010001;
  parameter ST_SLL       = 6'b010010;
  parameter ST_SLLV      = 6'b010011;
  parameter ST_SRA       = 6'b010100;
  parameter ST_SRAV      = 6'b010101;
  parameter ST_SRL       = 6'b010110;
  parameter ST_SLT       = 6'b010111;
  parameter ST_SLTI      = 6'b011000;
  parameter ST_XCHG      = 6'b011001;
  parameter ST_MFHI      = 6'b011010;
  parameter ST_MFLO      = 6'b011011;
  parameter ST_JUMP      = 6'b011100;
  parameter ST_JAL       = 6'b011101;
  parameter ST_LW        = 6'b011110;
  parameter ST_SW        = 6'b011111;
  parameter ST_OPCODE_EX = 6'b100000;
  parameter ST_ADDIU    =  6'b100001; 

  // opcodes aliases 
  parameter NULL  =   6'b000000;
  parameter BLM   =   6'b000001;
  parameter J     =   6'b000010;
  parameter JAL   =   6'b000011;
  parameter BEQ   =   6'b000100;
  parameter BNE   =   6'b000101;
  parameter BLE   =   6'b000110;
  parameter BGT   =   6'b000111;
  parameter ADDI  =   6'b001000;
  parameter ADDIU =   6'b001001;
  parameter SLTI  =   6'b001010;
  parameter LUI   =   6'b010000;
  parameter LB    =   6'b100000;
  parameter LH    =   6'b100001;
  parameter LW    =   6'b100011;
  parameter SB    =   6'b101000;
  parameter SW    =   6'b101011;

  // functions aliases
  parameter SLL   =   6'b000000;
  parameter SRL   =   6'b000010;
  parameter SRA   =   6'b000011;
  parameter SLLV  =   6'b000100;
  parameter XCHG  =   6'b000101;
  parameter SRAV  =   6'b000111;
  parameter JR    =   6'b001000;
  parameter BREAK =   6'b001011;
  parameter MFHI  =   6'b010000;
  parameter MFLO  =   6'b010010;
  parameter RTE   =   6'b010011;
  parameter MULT  =   6'b011000;
  parameter DIV   =   6'b011010;
  parameter ADD   =   6'b100000;
  parameter SUB   =   6'b100010;
  parameter AND   =   6'b100100;
  parameter SLT   =   6'b101010;


initial begin
  //makes initial reset on the machine
  rst_out = 1'b1;
end

always @(posedge clk) begin
  if (reset == 1'b1) begin
    if (STATE != ST_RESET) begin
      STATE = ST_RESET;
      //setting all signals
      PCwrite =  1'b0;
      MemWrite =  1'b0;
      IRWrite =  1'b0;
      BRWrite =  1'b0;
      ABWrite =  1'b0;
      EPCWrite =  1'b0;
      HIWrite =  1'b0;
      LOWrite =  1'b0;
      MDRWrite =  1'b0;
      ALUOutWrite =  1'b0;
      ALUOp = 3'b000;
      ShiftCtrl = 2'b00;
      MultOrDiv = 1'b0;
      HiOrLow = 1'b0;
      Shiftln = 1'b0;
      IorD = 2'b00;
      RegDst = 2'b00;
      ALUSrcA = 2'b00;
      ALUSrcB = 2'b00;
      ShiftAmt = 2'b00;
      Exception = 2'b00;
      MemToReg = 3'b000;
      PCSource = 3'b000;

      rst_out = 1'b1; ///
      //setting counter for next operation
      COUNTER = 3'b000;
    end 
    else begin
      STATE = ST_COMMON;
      PCwrite =  1'b0;
      MemWrite =  1'b0;
      IRWrite =  1'b0;
      BRWrite =  1'b0;
      ABWrite =  1'b0;
      EPCWrite =  1'b0;
      HIWrite =  1'b0;
      LOWrite =  1'b0;
      MDRWrite =  1'b0;
      ALUOutWrite =  1'b0;
      ALUOp = 3'b000;
      ShiftCtrl = 2'b00;
      MultOrDiv = 1'b0;
      HiOrLow = 1'b0;
      Shiftln = 1'b0;
      IorD = 2'b00;
      RegDst = 2'b00;
      ALUSrcA = 2'b00;
      ALUSrcB = 2'b00;
      ShiftAmt = 2'b00;
      Exception = 2'b00;
      MemToReg = 3'b000;
      PCSource = 3'b000;

      rst_out = 1'b0; ////
      //setting counter for next operations
      COUNTER = 3'b000;
    end 
  end
  else begin
    case (STATE)
      //COME??A A FAZER OS ESTADOS EM COMUM
      ST_COMMON: begin
        if (COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin //3 cicles to complete
          STATE = ST_COMMON;
          // 3 ciclos -> lendo memoria e calculando pc + 4
          PCwrite =  1'b0;
          MemWrite =  1'b0; /// Ler Memoria
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; // escrever em ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; /// PC
          ALUSrcB = 2'b01; /// 4
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001; // saida do ALUResult

          rst_out = 1'b0;
          //setting counter for next operation
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin //1 cicle to complete
          STATE = ST_COMMON;
          // 1 ciclo -> escrevendo em PC e IR o pc + 4 e saida da memoria respectivamente
          PCwrite =  1'b1; // Write no PC
          MemWrite =  1'b0;
          IRWrite =  1'b1; // Write no IR
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b010;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin
          STATE = ST_COMMON;
          // 1 ciclo -> de acordo com dados do IR vamos buscar registradores no BR e escrever em A e B
          // monitor disse que era um ??nico ciclo
          PCwrite =  1'b0; 
          MemWrite =  1'b0;
          IRWrite =  1'b0; 
          BRWrite =  1'b0;
          ABWrite =  1'b1; // escrita em AB
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0; 
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b101) begin
          // 1 ciclo -> definir o proximo estado
          case (OPCODE) 
            NULL: begin
              case (FUNCT)
                ADD: begin
                  STATE = ST_ADD;
                end
                SUB: begin
                  STATE = ST_SUB;
                end
                AND: begin
                  STATE = ST_AND;
                end
                MULT: begin
                  STATE = ST_MULT;
                end
                DIV: begin
                  STATE = ST_DIV;
                end
                BREAK: begin
                  STATE = ST_BREAK;
                end
                RTE: begin
                  STATE = ST_RTE;
                end
                JR: begin
                  STATE = ST_JR;
                end
                SLL: begin
                  STATE = ST_SLL;
                end
                SLLV: begin
                  STATE = ST_SLLV;
                end
                SRA: begin
                  STATE = ST_SRA;
                end
                SRAV: begin
                  STATE = SRAV;
                end
                SRL: begin
                  STATE = ST_SRL;
                end
                SLT: begin
                  STATE = ST_SLT;
                end
                MFHI: begin
                  STATE = ST_MFHI;
                end
                MFLO: begin
                  STATE = ST_MFLO;
                end
                XCHG: begin
                  STATE = ST_XCHG;
                end
              endcase
            end
            ADDI: begin
              STATE = ST_ADDI;
            end
            ADDIU: begin
              STATE = ST_ADDIU;
            end
            BEQ: begin
              STATE = ST_BEQ;
            end
            BNE: begin
              STATE = ST_BNE;
            end
            BLE: begin
              STATE = ST_BLE;
            end
            BGT: begin
              STATE = ST_BGT;
            end
            LW: begin
              STATE = ST_LW;
            end
            SW: begin
              STATE = ST_SW;
            end
            J: begin
              STATE = ST_JUMP;
            end
            JAL: begin
              STATE = ST_JAL;
            end
            SLTI: begin
              STATE = ST_SLTI;
            end
            default: begin
              STATE = ST_OPCODE_EX;
            end  
          endcase
          PCwrite =  1'b0; 
          MemWrite =  1'b0;
          IRWrite =  1'b0; 
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0; 
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O ADD
      ST_ADD: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_ADD;
          // 1 ciclos -> realizar soma e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; /// A
          ALUSrcB = 2'b00; /// B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_ADD;
          // 1 ciclos -> escrever resultado da soma no banco de registradores
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no Banco de Registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // rd
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O ADDI
      ST_ADDI: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_ADDI;
          // 1 ciclos -> realizar soma e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; /// A
          ALUSrcB = 2'b10; /// OFFSET
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_ADDI;
          // 1 ciclos -> escrever resultado da soma no banco de registradores
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no Banco de Registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; // rt
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      //COME??A A FAZER O ADDIU
      ST_ADDIU: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_ADDIU;
          // 1 ciclos -> realizar soma e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; /// A
          ALUSrcB = 2'b10; /// OFFSET
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_ADDIU;
          // 1 ciclos -> escrever resultado da soma no banco de registradores
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no Banco de Registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; // rt
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O SUB
      ST_SUB: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_SUB;
          // 1 ciclos -> realizar subtra????o e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b010; /// -
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; /// A
          ALUSrcB = 2'b00; /// B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_SUB;
          // 1 ciclos -> escrever resultado da subtra????o no banco de registradores
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no Banco de Registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // rd
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O BEQ
      ST_BEQ: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_BEQ;
          // 1 ciclos -> realizar uma soma(jump) e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; /// PC
          ALUSrcB = 2'b11; /// OFFSET(JUMP)
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_BEQ;
          // 1 ciclos -> mandar o resultado da soma para o mux pc_source
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b111; //compara????o
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; // A
          ALUSrcB = 2'b00; // B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b010; // valor do jump

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b010) begin
          STATE = ST_BEQ;
          if(EQ == 1'b1) begin
            PCwrite = 1'b1;
          end
            rst_out = 1'b0;
            COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      //COME??A A FAZER O BNE
      ST_BNE: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_BNE;
          // 1 ciclos -> realizar uma soma(jump) e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; /// PC
          ALUSrcB = 2'b11; /// OFFSET(JUMP)
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_BNE;
          // 1 ciclos -> mandar o resultado da soma para o mux pc_source
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b111; //compara????o
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; // rt
          ALUSrcA = 2'b01; // A
          ALUSrcB = 2'b00; // B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b010; //valor do jump

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b010) begin
          STATE = ST_BNE;
          if(EQ == 1'b0) begin
            PCwrite = 1'b1;
          end
            rst_out = 1'b0;
            COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      //COME??A A FAZER O BLE
      ST_BLE: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_BLE;
          // 1 ciclos -> realizar uma soma(jump) e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; /// PC
          ALUSrcB = 2'b11; /// OFFSET(JUMP)
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_BLE;
          // 1 ciclos -> mandar o resultado da soma para o mux pc_source
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b111; //compara????o
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; // rt
          ALUSrcA = 2'b01; // A
          ALUSrcB = 2'b00; // B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b010; //valor do jump

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b010) begin
          STATE = ST_BLE;
          if(GT == 1'b0) begin
            PCwrite = 1'b1;
          end
            rst_out = 1'b0;
            COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 
      
      //COME??A A FAZER O BGT
      ST_BGT: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_BGT;
          // 1 ciclos -> realizar uma soma(jump) e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; /// PC
          ALUSrcB = 2'b11; /// OFFSET(JUMP)
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_BGT;
          // 1 ciclos -> mandar o resultado da soma para o mux pc_source
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b111; //compara????o
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; // rt
          ALUSrcA = 2'b01; // A
          ALUSrcB = 2'b00; // B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b010; //valor do jump

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b010) begin
          STATE = ST_BGT;
          if(GT == 1'b1) begin
            PCwrite = 1'b1;
          end
            rst_out = 1'b0;
            COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      //COME??A A FAZER O AND
      ST_AND: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_AND;
          // 1 ciclos -> realizar um and e escrever em ALUOut
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; /// Write no ALUOut
          ALUOp = 3'b011; /// and l??gico
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; /// A
          ALUSrcB = 2'b00; /// B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_AND;
          // 1 ciclos -> escrever resultado da soma no banco de registradores
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no Banco de Registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // rd
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O MULT
      ST_MULT: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_MULT;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; // A
          ALUSrcB = 2'b00; // B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_MULT;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0; //MULT
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_MULT;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b1; //ESCREVE NO REG HI
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0; //
          HiOrLow = 1'b0; //ESCOLHE PRIMEIRO HI
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin
          STATE = ST_MULT;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0; ///
          LOWrite =  1'b1; //ESCREVE NO REG LO
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0; //ESCOLHE SEGUNDO LO
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O DIV
       ST_DIV: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_DIV;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; // A
          ALUSrcB = 2'b00; // B
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_DIV;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b1; //DIV
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_DIV;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b1; //ESCREVE NO REG HI
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0; //
          HiOrLow = 1'b0; //ESCOLHE PRIMEIRO HI
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin
          STATE = ST_DIV;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0; ///
          LOWrite =  1'b1; //ESCREVE NO REG LO
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0; //ESCOLHE SEGUNDO LO
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O BREAK
      ST_BREAK: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_BREAK;
          // 1 ciclos -> realizar subtra????o e mandar para o mux pc_source
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b010; /// -
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; /// PC
          ALUSrcB = 2'b01; /// 4 
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_BREAK;
          // 1 ciclos -> escrever resultado da soma no banco de registradores
          PCwrite =  1'b1; //ESCREVE NO PC
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b010; //LIBERA O PC-4 PRO PC

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O RTE
      ST_RTE: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_RTE;
          // 1 ciclos -> tranferir o que tem no epc para o pc
          PCwrite =  1'b1; //ESCREVE O NO PC
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b1; // ESCREVE NO EPC
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000; //lIBERA O EPC PARA O PC

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      //COME??A A FAZER O JR
      ST_JR: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_JR;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000; /// carrega A(valor de rs)
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; ///PEGA O VALOR DE RS
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_JR;
          PCwrite =  1'b1; //ESCREVE O RS NO PC
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      // COME??A A FAZER SLL
      ST_SLL :begin
        if (COUNTER == 3'b000) begin
          STATE = ST_SLL;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b001; //  load no registrador
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b1; // Entrada recebe B
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b001) begin
          STATE = ST_SLL;
          // 1 ciclos -> Shift left n vezes
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b010; //  Shift left n vezes
          MultOrDiv = 1'b0; 
          HiOrLow = 1'b0;
          Shiftln = 1'b1; // Entrada = B
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; // N = Shamt
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_SLL;
          // wait 

          ShiftCtrl = 3'b000; //  zerando

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b011) begin
          STATE = ST_SLL;
         // 1 ciclos -> Carrega rd = rt << shamt      
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 3'b000;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // Write register = rd
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b100; // Resultado do shift no write data
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      // COME??A A FAZER SLLV
      ST_SLLV: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_SLLV;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b001; //  load no registrador
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0; // Entrada recebe A
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b001) begin
          STATE = ST_SLLV;
          // 1 ciclos -> Shift rs left rt vezes
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b010; //  Shift left n vezes
          MultOrDiv = 1'b0; 
          HiOrLow = 1'b0;
          Shiftln = 1'b0; // Entrada = A
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b01; // N = B
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_SLLV;
          // wait 

          ShiftCtrl = 3'b000; //  zerando

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b011) begin
          STATE = ST_SLLV;
         // 1 ciclos -> Carrega rd = rt << shamt      
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 3'b000;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // Write register = rd
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b100; // Resultado do shift no write data
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      // COME??A A FAZER SRA
      ST_SRA :begin
        if (COUNTER == 3'b000) begin
          STATE = ST_SRA;

          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b001; //  load no registrador
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b1; // Entrada recebe B
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b001) begin
          STATE = ST_SRA;
          
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b100; //  Shift rigth n vezes
          MultOrDiv = 1'b0; 
          HiOrLow = 1'b0;
          Shiftln = 1'b1; // Entrada = B
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; // N = Shamt
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_SRA;
          // wait 

          ShiftCtrl = 3'b000; //  zerando

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b011) begin
          STATE = ST_SRA;
         
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 3'b000;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // Write register = rd
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b100; // Resultado do shift no write data
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

     // COME??A A FAZER SRAV
      ST_SRAV: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_SRAV;

          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b001; //  load no registrador
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0; // Entrada recebe A
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b001) begin
          STATE = ST_SRAV;

          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b100; //  Shift rigth n vezes
          MultOrDiv = 1'b0; 
          HiOrLow = 1'b0;
          Shiftln = 1'b0; // Entrada = A
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b01; // N = B
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_SRAV;
          // wait 

          ShiftCtrl = 3'b000; //  zerando

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b011) begin
          STATE = ST_SRAV;

          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 3'b000;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // Write register = rd
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b100; // Resultado do shift no write data
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

       // COME??A A FAZER SRL
      ST_SRL :begin
        if (COUNTER == 3'b000) begin
          STATE = ST_SRL;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b001; //  load no registrador
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b1; // Entrada recebe B
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b001) begin
          STATE = ST_SRL;
          // 1 ciclos -> Shift left n vezes
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 3'b011; //  Shift rigth n vezes
          MultOrDiv = 1'b0; 
          HiOrLow = 1'b0;
          Shiftln = 1'b1; // Entrada = B
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; // N = Shamt
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_SRL;
          // wait 

          ShiftCtrl = 3'b000; //  zerando

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b011) begin
          STATE = ST_SRL;
         // 1 ciclos -> Carrega rd = rt << shamt      
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 3'b000;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // Write register = rd
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b100; // Resultado do shift no write data
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      // COME??A A FAZER SLT
      ST_SLT :begin
        if (COUNTER == 3'b000) begin
          // 1 ciclos -> Carrega A e B na ula e compara
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b111; // compara????o 
          ShiftCtrl = 3'b000;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0; 
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; /// A
          ALUSrcB = 2'b00; /// B
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b001) begin
         // 1 ciclos -> Carrega rd = rs < rt        
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 3'b010;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b1;
          IorD = 2'b00;
          RegDst = 2'b01; // Write register = rd
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b101; // Sinal LT da ula escrito em write data
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      // COME??A A FAZER SLTI
      ST_SLTI :begin
        if (COUNTER == 3'b000) begin
          // 1 ciclos -> Carrega A e imediato na ula e compara
          PCwrite =  1'b0;
          MemWrite =  1'b0;
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b111; // compara????o 
          ShiftCtrl = 3'b000; 
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0; 
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; /// A
          ALUSrcB = 2'b10; /// imediato
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if(COUNTER == 3'b001) begin
         // 1 ciclos -> Carrega rd = rs < imediato      
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no br
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0; 
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 3'b010;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b1;
          IorD = 2'b00;
          RegDst = 2'b01; // Write register = rd
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          ShiftAmt = 2'b00; 
          Exception = 2'b00;
          MemToReg = 3'b110; // Sinal LT da ula escrito em write data
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O XCHG
      ST_XCHG: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_XCHG;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; // escrever em ALUOut
          ALUOp = 3'b000; /// carrega A(valor de rs)
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; ///PEGA O VALOR DE RS
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_XCHG;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; // rt
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; // ALUOut
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_XCHG;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; // escrever em ALUOut
          ALUOp = 3'b010; /// carrega B(valor de rs)
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; ///PEGA O VALOR DE RS
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin
          STATE = ST_XCHG;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b10; // rs
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; // ALUOut
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      //COME??A A FAZER O SW
      ST_SW: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_SW;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; // escrever em ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; ///PEGA O VALOR DE RS
          ALUSrcB = 2'b11; // offset estendido
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_SW;
          PCwrite =  1'b0;
          MemWrite =  1'b1; // escrever na memoria o que vem de B
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b01; // adress ALUOut
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010 || COUNTER == 3'b011) begin
          STATE = ST_SW;
          //wait 
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O LW
      ST_LW: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_LW;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; // escrever em ALUOut
          ALUOp = 3'b001; /// +
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; ///PEGA O VALOR DE RS
          ALUSrcB = 2'b11; // offset estendido
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001 || COUNTER == 3'b010 || COUNTER == 3'b011) begin
          STATE = ST_LW;
          PCwrite =  1'b0;
          MemWrite =  1'b0;
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b01; // adress ALUOut
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin
          STATE = ST_LW;
          
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b1; // escrever no mdr
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b101) begin
          STATE = ST_LW; 

          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no banco de registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0; 
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; // rt
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b001; // mdr
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b110) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O MFHI
      ST_MFHI: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_MFHI;
          // 1 ciclos -> escrever o HI no banco de registradores
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no Banco de Registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // rd
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b010; //HI
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O MFLO
      ST_MFLO: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_MFLO;
          // 1 ciclos -> escrever o LO no banco de registradores
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no Banco de Registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b01; // rd
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b011; //LO
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      //COME??A A FAZER O JUMP
      ST_JUMP: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_JUMP;
          PCwrite =  1'b1; // escrever em pc
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000; 
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b011; // jump 

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

      //COME??A A FAZER O JAL
      ST_JAL: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_JAL;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; // escrever em alout
          ALUOp = 3'b000; /// carrega A
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; /// PC
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin
          STATE = ST_JAL;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b1; // escrever no Banco de Registradores
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b11; // ra
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; /// ALUOut
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b010) begin
          STATE = ST_JAL;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; // escrever em alout
          ALUOp = 3'b000; /// carrega A(valor de rs)
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b01; ///PEGA O VALOR DE RS
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b001;

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b011) begin
          STATE = ST_JAL;
          PCwrite =  1'b1; //ESCREVE O jump NO PC
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0; 
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000;
          PCSource = 3'b011; // jump 

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b100) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end 

      // COME??A EXCECCAO OPCODE
      ST_OPCODE_EX: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_OPCODE_EX;
          PCwrite =  1'b1; // escrever em pc
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000; 
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00; // opcode inexistente
          MemToReg = 3'b000;
          PCSource = 3'b100; // exception

          rst_out = 1'b0;
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 3'b001) begin 
          STATE = ST_COMMON;
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b0;
          ALUOp = 3'b000;
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00; 
          ALUSrcA = 2'b00;
          ALUSrcB = 2'b00;
          ShiftAmt = 2'b00;
          Exception = 2'b00;
          MemToReg = 3'b000; 
          PCSource = 3'b000;

          rst_out = 1'b0;
          COUNTER = 3'b000;
        end
      end

    endcase
  end 
end

endmodule