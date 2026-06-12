module tb_mux2to1;
  import mux_pkg::*;

  logic a, b, sel;
  logic y;

  // Instantiate DUT
  parameterized_mux #(.WIDTH(param_width)) dut (
    .a(a),
    .b(b),
    .sel(sel),
    .y(y)
  );

  // Simple reference model (because trust issues are healthy in verification)
  function logic expected(input logic a, input logic b, input logic sel);
    return sel ? b : a;
  endfunction

  task apply(input logic ta, input logic tb, input logic tsel);
    begin
      a   = ta;
      b   = tb;
      sel = tsel;
      #1;

      if (y !== expected(ta, tb, tsel)) begin
        $display("FAIL: a=%0b b=%0b sel=%0b y=%0b", ta, tb, tsel, y);
      end else begin
        $display("PASS: a=%0b b=%0b sel=%0b y=%0b", ta, tb, tsel, y);
      end
    end
  endtask

  initial begin
    $dumpfile("mux2to1.vcd");
    $dumpvars(0, tb_mux2to1);

    // initialize
    a = 0; b = 0; sel = 0;
    #1;

    // Exhaustive-ish testing, because guessing is not verification
    apply(0, 0, 0);
    apply(0, 0, 1);
    apply(0, 1, 0);
    apply(0, 1, 1);
    apply(1, 0, 0);
    apply(1, 0, 1);
    apply(1, 1, 0);
    apply(1, 1, 1);

    $display("Simulation done. If everything passed, suspiciously smooth.");
    $finish;
  end

endmodule
