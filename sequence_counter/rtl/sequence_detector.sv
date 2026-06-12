// Detecting a big sequence - 1110_1101_1011
module sequence_detector #
(
  parameter LENGTH = 12
)(
  input     wire        clk,
  input     wire        reset,
  input     wire        x_i,

  output    wire        det_o
);

  logic [LENGTH-1:0] shift_ff;
  logic [LENGTH-1:0] nxt_shift;

  always_ff@(posedge clk or negedge reset)
    if (reset == 'b0)
      shift_ff <= '0;
    else 
      shift_ff <= nxt_shift;
  
  assign nxt_shift = {shift_ff[LENGTH-1:0], x_i};

  assign det_o = (shift_ff[LENGTH-1:0] == 12'b1110_1101_1011);

endmodule
