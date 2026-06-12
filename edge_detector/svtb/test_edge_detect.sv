module edge_detect_tb ();

  logic clk;
  logic reset;
  logic a_i;
  logic rising_edge_o;
  logic falling_edge_o;

edge_detector dut (.*);

// clk
always begin 
  clk = 1'b1;
  #5;
  clk = 1'b0;
  #5;
end 

// stimulus
initial begin 
  #10 reset <= 1'b1;
  #10 a_i <= 1'b0;
  @(posedge clk);
  reset <= 1'b0;
  @(posedge clk);
  
  for (int i = 0; i < 32; i++) begin 
    a_i <= $random%2;
    @(posedge clk);
  end
  $finish;
end

endmodule : edge_detect_tb