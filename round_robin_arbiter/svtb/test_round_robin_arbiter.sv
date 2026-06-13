module test_round_robin_arbiter ();

  logic       clk;
  logic       reset;
  logic [3:0] req_i;
  logic [3:0] gnt_o;

  round_robin_arbiter dut (.*);

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Verify grant is one-hot and only set for an active request
  task check_grant(input logic [3:0] req, input logic [3:0] gnt);
    // Must be one-hot or zero
    logic is_onehot;
    is_onehot = (gnt == '0) || ((gnt & (gnt - 1)) == '0);
    if (!is_onehot)
      $display("FAIL: gnt not one-hot: req=%04b gnt=%04b", req, gnt);
    // Granted port must be requesting
    if (gnt != '0 && !(req & gnt))
      $display("FAIL: grant to non-requesting port: req=%04b gnt=%04b", req, gnt);
    else if (is_onehot)
      $display("PASS: req=%04b gnt=%04b", req, gnt);
  endtask

  initial begin
    $dumpfile("test_round_robin_arbiter.vcd");
    $dumpvars(0, test_round_robin_arbiter);

    reset = 1'b1;
    req_i = 4'b0000;
    @(posedge clk);
    @(posedge clk);
    reset = 1'b0;
    @(posedge clk);

    // All ports request simultaneously — expect round-robin rotation
    $display("--- All ports requesting ---");
    req_i = 4'b1111;
    repeat(8) begin
      @(posedge clk);
      #1;
      check_grant(req_i, gnt_o);
    end

    // Single port requesting
    $display("--- Only port 2 requesting ---");
    req_i = 4'b0100;
    repeat(4) begin
      @(posedge clk);
      #1;
      check_grant(req_i, gnt_o);
    end

    // Alternating pairs
    $display("--- Alternating port pairs ---");
    for (int i = 0; i < 8; i++) begin
      req_i = (i % 2 == 0) ? 4'b0101 : 4'b1010;
      @(posedge clk);
      #1;
      check_grant(req_i, gnt_o);
    end

    // No requests
    $display("--- No requests ---");
    req_i = 4'b0000;
    @(posedge clk);
    #1;
    check_grant(req_i, gnt_o);

    repeat(2) @(posedge clk);
    $finish();
  end

endmodule
