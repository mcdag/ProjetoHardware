module mux_memRead (
  input wire  [1:0]  selector,
  input wire  [31:0] input_one,
  input wire  [31:0] input_two,
  input wire  [31:0] input_three,
  output wire [31:0] output_final;
);

  wire [31:0] aux;

  assign aux = (selector[0]) ? input_two : input_one;
  assign output_final = (selector[1]) ? input_three : aux;

  endmodule