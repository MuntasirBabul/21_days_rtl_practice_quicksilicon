module test_self_reloading_counter ();

  logic       clk;
  logic       reset;
  logic       load_i;
  logic [3:0] load_val_i;
  logic [3:0] count_o;

  self_reloading_counter dut (.*);

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("test_self_reloading_counter.vcd");
    $dumpvars(0, test_self_reloading_counter);

    reset     = 1'b0;
    load_i    = 1'b0;
    load_val_i = 4'h0;

    // Assert active-low reset
    @(posedge clk);
    reset = 1'b1;
    @(posedge clk);

    // Load value 5 and let the counter run until it wraps back
    load_i    = 1'b1;
    load_val_i = 4'h5;
    @(posedge clk);
    load_i = 1'b0;

    // Run for enough cycles to see the counter reach 0xF and self-reload
    repeat(20) @(posedge clk);

    // Load a different value mid-run
    load_i    = 1'b1;
    load_val_i = 4'hA;
    @(posedge clk);
    load_i = 1'b0;

    repeat(15) @(posedge clk);

    $finish();
  end

endmodule
