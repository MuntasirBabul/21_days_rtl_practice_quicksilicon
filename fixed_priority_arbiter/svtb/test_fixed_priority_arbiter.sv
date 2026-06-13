module test_fixed_priority_arbiter ();

  parameter NUM_PORTS = 4;

  logic [NUM_PORTS-1:0] req_i;
  logic [NUM_PORTS-1:0] gnt_o;

  fixed_priority_arbiter #(.NUM_PORTS(NUM_PORTS)) dut (.*);

  // Expected: lowest set bit of req_i wins (port 0 = highest priority)
  function automatic logic [NUM_PORTS-1:0] expected_gnt(input logic [NUM_PORTS-1:0] req);
    for (int i = 0; i < NUM_PORTS; i++)
      if (req[i]) return NUM_PORTS'(1 << i);
    return '0;
  endfunction

  int pass_count;
  int fail_count;

  initial begin
    pass_count = 0;
    fail_count = 0;

    // Exhaustive test for all request patterns
    for (int i = 0; i < 2**NUM_PORTS; i++) begin
      req_i = i[NUM_PORTS-1:0];
      #5;
      if (gnt_o !== expected_gnt(req_i)) begin
        $display("FAIL: req=%04b  gnt=%04b  expected=%04b", req_i, gnt_o, expected_gnt(req_i));
        fail_count++;
      end else begin
        $display("PASS: req=%04b  gnt=%04b", req_i, gnt_o);
        pass_count++;
      end
    end

    $display("\n%0d passed, %0d failed.", pass_count, fail_count);
    $finish();
  end

endmodule
