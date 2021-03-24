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

  // variaveis
  reg [1:0] state;
  reg [2:0] cont;

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
  
end

always @(posedge clk) begin

end

endmodule