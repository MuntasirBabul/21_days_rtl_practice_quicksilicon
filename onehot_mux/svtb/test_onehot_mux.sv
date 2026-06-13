module test_onehot_mux ();

  logic [3:0] a_i;
  logic [3:0] sel_i;
  logic       y_ter_o;
  logic       y_case_o;
  logic       y_ifelse_o;
  logic       y_loop_o;
  logic       y_aor_o;

  onehot_mux dut (.*);

  int pass_count;
  int fail_count;

  // All five outputs must agree and must equal the selected bit of a_i
  task check(input logic [3:0] a, input logic [3:0] sel, input logic exp);
    logic outputs_match;
    outputs_match = (y_ter_o === exp) && (y_case_o === exp) &&
                    (y_ifelse_o === exp) && (y_loop_o === exp) && (y_aor_o === exp);
    if (outputs_match) begin
      $display("PASS: a=%04b sel=%04b  all outputs=%0b", a, sel, exp);
      pass_count++;
    end else begin
      $display("FAIL: a=%04b sel=%04b  ter=%0b case=%0b ifelse=%0b loop=%0b aor=%0b  expected=%0b",
               a, sel, y_ter_o, y_case_o, y_ifelse_o, y_loop_o, y_aor_o, exp);
      fail_count++;
    end
  endtask

  initial begin
    pass_count = 0;
    fail_count = 0;

    // Test each one-hot select with various input combinations
    for (int s = 0; s < 4; s++) begin
      sel_i = 4'(1 << s);
      for (int a = 0; a < 16; a++) begin
        a_i = 4'(a);
        #5;
        check(a_i, sel_i, a_i[s]);
      end
    end

    $display("\n%0d passed, %0d failed.", pass_count, fail_count);
    $finish();
  end

endmodule
