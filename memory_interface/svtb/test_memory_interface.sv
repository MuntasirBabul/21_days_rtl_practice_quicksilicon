`timescale 1ns/1ps

// Testbench for memory_interface.
// The DUT has random latency (LFSR-based), so the TB waits for pready before
// considering a transaction complete.

module test_memory_interface ();

  logic        clk;
  logic        reset;
  logic        req_i;
  logic        req_rnw_i;
  logic [3:0]  req_addr_i;
  logic [31:0] req_wdata_i;
  wire         req_ready_o;
  wire  [31:0] req_rdata_o;

  memory_interface dut (.*);

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Reference memory model
  logic [31:0] ref_mem [0:15];

  task automatic do_write(input logic [3:0] addr, input logic [31:0] data);
    req_i      = 1'b1;
    req_rnw_i  = 1'b0;
    req_addr_i = addr;
    req_wdata_i = data;
    // Wait until the memory accepts (ready with count == 0)
    @(posedge clk);
    while (!req_ready_o) @(posedge clk);
    req_i = 1'b0;
    @(posedge clk);
    ref_mem[addr] = data;
    $display("[%0t] WRITE addr=0x%0h data=0x%08X", $time, addr, data);
  endtask

  task automatic do_read(input logic [3:0] addr);
    req_i      = 1'b1;
    req_rnw_i  = 1'b1;
    req_addr_i = addr;
    @(posedge clk);
    while (!req_ready_o) @(posedge clk);
    req_i = 1'b0;
    #1;
    if (req_rdata_o !== ref_mem[addr])
      $display("FAIL: READ addr=0x%0h  got=0x%08X  expected=0x%08X", addr, req_rdata_o, ref_mem[addr]);
    else
      $display("PASS: READ addr=0x%0h  data=0x%08X", addr, req_rdata_o);
    @(posedge clk);
  endtask

  initial begin
    $dumpfile("test_memory_interface.vcd");
    $dumpvars(0, test_memory_interface);

    reset      = 1'b1;
    req_i      = 1'b0;
    req_rnw_i  = 1'b0;
    req_addr_i = 4'h0;
    req_wdata_i = 32'h0;

    // Initialize reference model
    foreach (ref_mem[i]) ref_mem[i] = 32'h0;

    @(posedge clk);
    reset = 1'b0;
    @(posedge clk);

    // Write several locations
    do_write(4'h0, 32'hDEAD_BEEF);
    do_write(4'h3, 32'hCAFE_BABE);
    do_write(4'hF, 32'h1234_5678);

    // Read them back
    do_read(4'h0);
    do_read(4'h3);
    do_read(4'hF);

    // Write and immediately read a different location
    do_write(4'h7, 32'hAAAA_5555);
    do_read(4'h7);

    repeat(4) @(posedge clk);
    $display("[%0t] Simulation complete.", $time);
    $finish();
  end

endmodule
