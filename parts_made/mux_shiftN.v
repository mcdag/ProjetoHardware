module mux_shiftN (
  input wire         selector,
  input wire  [10:6] input_one,
  input wire  [4:0] input_two,
  output wire [4:0] output_final
);

  assign output_final = (selector) ? input_two : input_one;

  endmodule