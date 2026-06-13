module test_bin_to_onehot ();

  parameter BIN_W     = 4;
  parameter ONE_HOT_W = 16;

  logic [BIN_W-1:0]     bin_i;
  logic [ONE_HOT_W-1:0] one_hot_o;

  bin_to_onehot #(.BIN_W(BIN_W), .ONE_HOT_W(ONE_HOT_W)) dut (.*);

  int pass_count;
  int fail_count;

  initial begin
    pass_count = 0;
    fail_count = 0;

    for (int i = 0; i < ONE_HOT_W; i++) begin
      bin_i = i[BIN_W-1:0];
      #5;
      if (one_hot_o !== (ONE_HOT_W'(1) << i)) begin
        $display("FAIL: bin_i=%0d  one_hot_o=%016b  expected=%016b", i, one_hot_o, ONE_HOT_W'(1) << i);
        fail_count++;
      end else begin
        $display("PASS: bin_i=%0d  one_hot_o=%016b", i, one_hot_o);
        pass_count++;
      end
    end

    $display("\n%0d passed, %0d failed.", pass_count, fail_count);
    $finish();
  end

endmodule
