module test_odd_counter ();

  logic       clk;
  logic       reset;
  logic[7:0]  cnt_o;

  // clock
  always begin 
  clk = 1'b1;
  #5;
  clk = 1'b0;
  #5;
  end

  odd_counter dut (.*);

  initial begin 
  @(posedge clk);
  reset = 1'b1;
  @(posedge clk);
  reset = 1'b0;
  for (int i = 0; i < 100; i++) begin 
    @(posedge clk);
  end
  $finish;
  end
  
endmodule : test_odd_counter