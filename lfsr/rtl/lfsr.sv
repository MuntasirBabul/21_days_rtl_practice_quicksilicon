module lfsr 
(
  input logic clk,
  input logic reset,
  output logic [3:0] lfsr_o
);

always_ff @(posedge clk or negedge reset) begin
  if (reset == 1'b0)
    lfsr_o <= 4'hE;
  else 
    lfsr_o <= {lfsr_o[0], lfsr_o[1] ^ lfsr_o[3]};
end

endmodule