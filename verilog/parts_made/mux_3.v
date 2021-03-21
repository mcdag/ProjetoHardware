module mux_3 (
  input wire  [2:0]  selector,
  input wire  [31:0] input_one,
  input wire  [31:0] input_two,
  input wire  [31:0] input_five,
  output wire [31:0] output_final;
);

  wire [31:0] aux_1;
  wire [31:0] aux_2;
  wire [31:0] aux_3;
  wire [31:0] aux_4;

  assign aux_1 = (selector[0]) ? input_two : input_one;
  assign aux_2 = (selector[0]) ? "LO" : "HI";
  assign aux_3 = (selector[1]) ? aux_2 : aux_1;
  assign aux_4 = (selector[0]) ? "RA" : input_five;
  assign output_final = (selector[2]) ? aux_4 : aux_3;

  endmodule