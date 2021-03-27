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
  parameter ST_RESET  = 6'b000000;
  parameter ST_COMMON = 6'b000001;
  parameter ST_ADD    = 6'b000010;
  parameter ST_ADDI   = 6'b000011;
  parameter ST_SUB    = 6'b000100;
  parameter ST_BEQ    = 6'b000111;
  parameter ST_BNE    = 6'b001000;
  parameter ST_BLE    = 6'b001001;
  parameter ST_BGT    = 6'b001010;
  parameter ST_AND    = 6'b001011;
  parameter ST_DIV    = 6'b001100;
  parameter ST_MULT   = 6'b001101;
  parameter ST_BREAK  = 6'b001111;
  parameter ST_RTE    = 6'b010000;
  parameter ST_JR     = 6'b010001;


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
  parameter BREAK =   6'b001101;
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
      //COMEÇA A FAZER OS ESTADOS EM COMUM
      ST_COMMON: begin
        if (COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin //3 cicles to complete
          STATE = ST_COMMON;
          // 3 ciclos -> lendo memoria e calculando pc + 4
          PCwrite =  1'b0;
          MemWrite =  1'b0; /// Ler Memoria
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b10;
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
          // monitor disse que era um único ciclo
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
              endcase
            end
            ADDI: begin
              STATE = ST_ADDI;
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

      //COMEÇA A FAZER O ADD
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

      //COMEÇA A FAZER O ADDI
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

      //COMEÇA A FAZER O SUB
      ST_SUB: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_SUB;
          // 1 ciclos -> realizar subtração e escrever em ALUOut
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
          // 1 ciclos -> escrever resultado da subtração no banco de registradores
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

      //COMEÇA A FAZER O BEQ
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
          ALUOp = 3'b111; //comparação
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

      //COMEÇA A FAZER O BNE
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
          ALUOp = 3'b111; //comparação
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

      //COMEÇA A FAZER O BLE
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
          ALUOp = 3'b111; //comparação
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
      
      //COMEÇA A FAZER O BGT
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
          ALUOp = 3'b111; //comparação
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

      //COMEÇA A FAZER O AND
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
          ALUOp = 3'b011; /// and lógico
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

      //COMEÇA A FAZER O MULT - NAO TESTADO E VALIDADO
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

      //COMEÇA A FAZER O DIV - NAO TESTADO E VALIDADO
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

      //COMEÇA A FAZER O BREAK
      ST_BREAK: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_BREAK;
          // 1 ciclos -> realizar subtração e mandar para o mux pc_source
          PCwrite =  1'b0;
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0;
          HIWrite =  1'b0;
          LOWrite =  1'b0;
          MDRWrite =  1'b0;
          ALUOutWrite =  1'b1; // escrever em ALOOut
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

      //COMEÇA A FAZER O RTE
      ST_RTE: begin
        if (COUNTER == 3'b000) begin
          STATE = ST_RTE;
          // 1 ciclos -> tranferir o que tem no epc para o pc
          PCwrite =  1'b1; //ESCREVE O NO PC
          MemWrite =  1'b0; 
          IRWrite =  1'b0;
          BRWrite =  1'b0;
          ABWrite =  1'b0;
          EPCWrite =  1'b0; // JA FOI ESCRITO NO COMMONS
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

      //COMEÇA A FAZER O JR
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
          ALUOutWrite =  1'b1; // escrever em ALUOut
          ALUOp = 3'b000; /// carrega A(valor de rs)
          ShiftCtrl = 2'b00;
          MultOrDiv = 1'b0;
          HiOrLow = 1'b0;
          Shiftln = 1'b0;
          IorD = 2'b00;
          RegDst = 2'b00;
          ALUSrcA = 2'b0; ///PEGA O VALOR DE RS
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
      
    endcase
  end 
end

endmodule