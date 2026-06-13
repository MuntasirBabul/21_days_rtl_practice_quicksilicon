`timescale 1ns/1ps

// Testbench for apb_master.
// A simple inline APB slave model provides pready and prdata responses.

module test_apb_master ();

  logic        clk;
  logic        reset;
  logic [1:0]  cmd_i;

  // APB bus signals driven/sampled by the master
  wire         psel;
  wire         penable;
  wire [31:0]  paddr;
  wire         pwrite;
  wire [31:0]  pwdata;
  logic        pready;
  logic [31:0] prdata;

  apb_master dut (
    .clk       (clk),
    .reset     (reset),
    .cmd_i     (cmd_i),
    .psel_o    (psel),
    .penable_o (penable),
    .paddr_o   (paddr),
    .pwrite_o  (pwrite),
    .pwdata_o  (pwdata),
    .pready_i  (pready),
    .prdata_i  (prdata)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Inline slave: register at address 0xDEAD_CAFE, returns pready one cycle after ACCESS
  logic [31:0] slave_mem;
  logic        access_d1;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      slave_mem  <= 32'h0000_0042;
      access_d1  <= 1'b0;
      pready     <= 1'b0;
      prdata     <= 32'h0;
    end else begin
      access_d1 <= psel & penable;
      pready    <= access_d1;
      if (psel & penable & pwrite & access_d1)
        slave_mem <= pwdata;
      prdata <= slave_mem;
    end
  end

  initial begin
    $dumpfile("test_apb_master.vcd");
    $dumpvars(0, test_apb_master);

    reset = 1'b1;
    cmd_i = 2'b00;
    @(posedge clk);
    @(posedge clk);
    reset = 1'b0;
    @(posedge clk);

    // Issue a read command
    $display("[%0t] Issuing READ command", $time);
    cmd_i = 2'b01;
    @(posedge clk);
    cmd_i = 2'b00;

    // Wait for transaction to complete
    repeat(6) @(posedge clk);

    // Issue a write command (write read_data + 1 back)
    $display("[%0t] Issuing WRITE command", $time);
    cmd_i = 2'b10;
    @(posedge clk);
    cmd_i = 2'b00;

    repeat(6) @(posedge clk);

    // Issue another read to verify the written value
    $display("[%0t] Issuing second READ command", $time);
    cmd_i = 2'b01;
    @(posedge clk);
    cmd_i = 2'b00;

    repeat(6) @(posedge clk);

    $display("[%0t] Simulation complete. slave_mem = 0x%08X", $time, slave_mem);
    $finish();
  end

endmodule
