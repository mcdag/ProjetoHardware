module mux_4 (
  input wire  [2:0]  selector,
  input wire  [31:0] input_one,
  input wire  [31:0] input_two,
  input wire  [31:0] input_three,
  input wire  [31:0] input_four,
  input wire  [31:0] input_five;
  output wire [31:0] output_final;
);

  wire [31:0] aux_1;
  wire [31:0] aux_2;
  wire [31:0] aux_3;

  assign aux_1 = (selector[0]) ? input_two : input_one;
  assign aux_2 = (selector[0]) ? input_four : input_three;
  assign aux_3 = (selector[1]) ? aux_2 : aux_1;
  assign output_final = (selector[3]) ? input_five : aux_2;

  endmodule