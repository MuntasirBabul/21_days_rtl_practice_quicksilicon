module edge_detector
(
  input logic clk,
  input logic reset,
  input logic a_i,
  output logic rising_edge_o,
  output logic falling_edge_o
);

  logic sig_dly;

  always_ff@(posedge clk or posedge reset)
  if (reset == 1'b1) begin 
    sig_dly <= 1'b0;
  end
  else begin 
    sig_dly <= a_i;
  end

  assign rising_edge_o = a_i & ~sig_dly;
  assign falling_edge_o = ~a_i & sig_dly; 

endmodule : edge_detector
