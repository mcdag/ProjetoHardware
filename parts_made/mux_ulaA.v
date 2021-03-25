module mux_ulaA (
  input wire  [1:0]  selector,
  input wire  [31:0] input_one,
  input wire  [31:0] input_two,
  input wire  [31:0] input_three,
  input wire  [31:0] input_four,
  output wire [31:0] output_final
);

  wire [31:0] aux_1;
  wire [31:0] aux_2;


  assign aux_1 = (selector[0]) ? input_two : input_one;
  assign aux_2 = (selector[0]) ? input_four : input_three;
  assign output_final = (selector[1]) ? aux_2 : aux_1;

  endmodule