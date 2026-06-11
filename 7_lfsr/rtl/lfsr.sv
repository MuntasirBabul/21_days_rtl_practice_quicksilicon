module lfsr 
(
  input logic clk,
  input logic reset,
  output logic [3:0] lfsr_o
);

always_ff @(posedge clk or negedge reset) begin
  if (reset == 1'b0)
    lfsr_o <= 'b0;
  else 
    lfsr_o <= {lfsr[0], lfsr[1] ^ lfsr[3]};
end

endmodule