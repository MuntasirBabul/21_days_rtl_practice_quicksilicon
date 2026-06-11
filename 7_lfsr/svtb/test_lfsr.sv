module test_lfsr ();

  logic clk;
  logic reset;
  logic [3:0] lfsr_o;


  lfsr dut (.*);

  always begin
    clk = 1'b1;
    #5;
    clk = 1'b0;
    #5;
  end

  initial begin 
    reset = 1'b0;
    @(posedge clk);
    reset = 1'b1;
    @(posedge clk);
    for (int i = 0; i < 32; i++) begin 
      @(posedge clk);
    end
    $finish;
  end
endmodule