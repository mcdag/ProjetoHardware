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
  output reg       PCwrite,
  output reg       PCwriteCond,
  output reg       LoadSizeOp,
  output reg       ALUOutWrite,
  output reg       MemRead,
  output reg       MemWrite,
  output reg       IRWrite,

//Controllers with more than 1 bit
  output reg [2:0] ULAOp,
  output reg [2:0] ShiftCtrl,

//Controller for muxes
  output reg [1:0] IorD,
  output reg [1:0] rsOp,
  output reg [1:0] RegDst,
  output reg [2:0] MemToReg,
  output reg [1:0] ALUSrcA,
  output reg [1:0] ALUSrcB,
  output reg [2:0] PCSource,
  output reg       MultOrDiv,
  output reg       HiOrLow,
  output reg       Shiftln,
  output reg [1:0] ShiftAmt,
  output reg [1:0] Exception,

//Especial controller for reset instruction
  output reg       Reset//não está no desenho, é intuitivo
);

endmodule