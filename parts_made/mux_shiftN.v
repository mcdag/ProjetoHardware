module mux_shiftN (
  input wire   [1:0] selector,
  input wire  [15:0] offset,
  input wire  [31:0] b,
  output wire [4:0] output_final
);

  assign input_one  = b[10:6];
  assign input_two  = b[4:0];

  assign aux = (selector[0]) ? input_two : input_one;
  assign output_final = (selector[1]) ? 5'b10000 : aux;

  endmodule