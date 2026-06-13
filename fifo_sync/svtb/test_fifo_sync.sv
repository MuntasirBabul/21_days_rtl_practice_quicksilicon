module test_fifo_sync ();

  parameter DEPTH  = 4;
  parameter DATA_W = 8;

  logic              clk;
  logic              reset;
  logic              push_i;
  logic [DATA_W-1:0] push_data_i;
  logic              pop_i;
  logic [DATA_W-1:0] pop_data_o;
  logic              full_o;
  logic              empty_o;

  fifo_sync #(.DEPTH(DEPTH), .DATA_W(DATA_W)) dut (.*);

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Simple reference queue
  logic [DATA_W-1:0] ref_q[$];

  task push(input logic [DATA_W-1:0] data);
    push_i      = 1'b1;
    push_data_i = data;
    ref_q.push_back(data);
    @(posedge clk);
    push_i = 1'b0;
  endtask

  task pop_check();
    logic [DATA_W-1:0] exp;
    pop_i = 1'b1;
    @(posedge clk);
    pop_i = 1'b0;
    exp = ref_q.pop_front();
    #1;
    if (pop_data_o !== exp)
      $display("FAIL: pop_data_o=%0h  expected=%0h", pop_data_o, exp);
    else
      $display("PASS: popped data=%0h", pop_data_o);
  endtask

  initial begin
    $dumpfile("test_fifo_sync.vcd");
    $dumpvars(0, test_fifo_sync);

    reset       = 1'b0;
    push_i      = 1'b0;
    pop_i       = 1'b0;
    push_data_i = '0;

    @(posedge clk);
    reset = 1'b1;
    @(posedge clk);

    // Push until full
    $display("--- Filling FIFO ---");
    for (int i = 0; i < DEPTH; i++)
      push(DATA_W'(8'hA0 + i));

    $display("full_o=%0b (expect 1)", full_o);

    // Pop all entries
    $display("--- Draining FIFO ---");
    for (int i = 0; i < DEPTH; i++)
      pop_check();

    $display("empty_o=%0b (expect 1)", empty_o);

    // Interleaved push/pop
    $display("--- Interleaved push/pop ---");
    push(8'hDE);
    push(8'hAD);
    pop_check();
    push(8'hBE);
    pop_check();
    pop_check();

    repeat(2) @(posedge clk);
    $finish();
  end

endmodule
