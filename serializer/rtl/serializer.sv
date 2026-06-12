// Parallel to serial with valid and empty

module serializer (
  input     logic      clk,
  input     logic      reset,

  output    logic      empty_o,
  input     logic[3:0] parallel_i,
  
  output    logic      serial_o,
  output    logic      valid_o
);

 
  logic [3:0] shift_ff;
  logic [3:0] next_shift;

  always@(posedge clk or negedge reset) begin 
    if (reset == 'b0) begin
      shift_ff <= 'b0;
    end
    else begin
      shift_ff <= next_shift;
    end
  end

  // Take the parallel input when empty
  // Otherwise give the data output serially
  assign next_shift = empty_o ? parallel_i : {'1, shift_ff[3:1]};

  assign serial_o = shift_ff[0];

  // Maintain a counter to drive valid and empty
  logic [2:0] count_ff;
  logic [2:0] next_count;

  // Counter goes to zero when it reaches 4 (As all data given out)
  assign next_count = (count_ff == '1) ? '0 : count_ff + 'b1;
  
  // Valid when count_ff == 0
  assign valid_o = |count_ff;

  // Empty when count_ff == 0
  assign empty_o = (count_ff == '0); 

endmodule
