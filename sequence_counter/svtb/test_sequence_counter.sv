module tb_sequence_detector;

  logic clk;
  logic reset;
  logic x_i;
  logic det_o;

  // Instantiate the DUT. Adjust port names if your sequence detector uses different names.
  sequence_detector dut (
    .clk(clk),
    .reset(reset),
    .x_i(x_i),
    .det_o(det_o)
  );

  localparam bit [11:0] TARGET_SEQUENCE = 12'b1110_1101_1011;

  initial begin
    $dumpfile("test_sequence_detector.vcd");
    $dumpvars(0, tb_sequence_detector);

    clk = 0;
    reset = 0;
    x_i = 0;

    #10 reset = 1;
    @(posedge clk);

    // Shift the target sequence into the DUT one bit per clock.
    for (int i = 11; i >= 0; i--) begin
      x_i = TARGET_SEQUENCE[i];
      @(posedge clk);
    end

    // Give the DUT one cycle to assert the detection output.
    @(posedge clk);

    if (det_o !== 1'b1) begin
      $display("[FAIL] Sequence 1110_1101_1011 was not detected.");
      $fatal;
    end else begin
      $display("[PASS] Sequence 1110_1101_1011 detected.");
    end

    #10 $finish;
  end

  always #5 clk = ~clk;

endmodule
