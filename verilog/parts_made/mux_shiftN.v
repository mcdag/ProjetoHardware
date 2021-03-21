module mux_shiftN (
  input wire         selector,
  input wire  [31:0] input_one,
  input wire  [31:0] input_two,
  output wire [31:0] output_final;
);

  assign output_final = (selector) ? input_two : input_one;

  endmodule