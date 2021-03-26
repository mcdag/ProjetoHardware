module mux_writeReg (
  input wire  [1:0]  selector,
  input wire  [4:0] input_one,
  input wire  [15:0] offset,
  input wire  [4:0] input_three,
  output wire [4:0] output_final
);

  wire [4:0] aux_1;
  wire [4:0] aux_2;
  wire [4:0] input_two;

  assign input_two = offset[15:11];

  assign aux_1 = (selector[0]) ? input_two : input_one;
  assign aux_2 = (selector[0]) ? 5'b11111 : input_three; //ra - input_three
  assign output_final = (selector[1]) ? aux_2 : aux_1;

  endmodule