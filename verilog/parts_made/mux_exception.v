module mux_8 (
  input wire  [1:0]  selector,
  output wire [31:0] output_final;
);

  wire [31:0] aux;


  assign aux = (selector[0]) ? 32'b000000000000000000000000011111110 : 32'b000000000000000000000000011111101;
  assign output_final = (selector[1]) ? 32'b000000000000000000000000011111111 : aux;

  endmodule