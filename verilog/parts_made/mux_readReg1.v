module mux_readReg1 (
  input wire  [1:0]  selector,
  input wire  [31:0] input_one,
  output wire [31:0] output_final;
);

  wire [31:0] aux;

  assign aux = (selector[0]) ? "HI" : input_one;
  assign output_final = (selector[1]) ? "LO" : aux;

  endmodule