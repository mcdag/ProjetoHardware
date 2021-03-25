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
  input wire [5:0] FUNCT,

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
  output reg       rst_out//não está no desenho, é intuitivo
);

  // variaveis
  reg [4:0] STATE;
  reg [2:0] CONT;

  // states
  parameter ST_RESET = 4'b0000;
  parameter ST_COMMON = 4'b0001;

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
  parameter MFLO  =   6'b010010;
  parameter RTE   =   6'b010011;
  parameter MULT  =   6'b011000;
  parameter DIV   =   6'b011010;
  parameter ADD   =   6'b100000;
  parameter SUB   =   6'b100010;
  parameter AND   =   6'b100100;
  parameter SLT   =   6'b101010;


initial begin
  rst_out = 1'b1;
end

always @(posedge clk) begin
  if (reset == 1'b1) begin
    if (STATE != ST_RESET) begin
      STATE = ST_RESET;
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
      ALUOp = 2'b00;
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
      ALUOp = 2'b00;
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
  else begin
    case (STATE)
      ST_COMMON: begin

      end
    endcase
  end 
end

endmodule