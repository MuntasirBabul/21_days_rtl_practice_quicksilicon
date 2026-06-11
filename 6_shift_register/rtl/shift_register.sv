module shift_register 
(
  input   logic clk,
  input   logic reset,
  input   logic x_i,
  output  logic [3:0] sr_o
);

  always_ff @(posedge clk or negedge reset) begin
    if (!reset)
      sr_o <= 4'b0;
    else
      sr_o <= {sr_o[2:0], x_i};
  end


endmodule : shift_register