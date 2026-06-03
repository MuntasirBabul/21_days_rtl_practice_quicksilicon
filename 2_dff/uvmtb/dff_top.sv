`include "uvm_macros.svh"
import uvm_pkg::*;
`include "dff_include_files.sv"

module top;

   // -----------------------
   // Clock generation
   // -----------------------
   bit clk;

   initial clk = 0;
   always #5 clk = ~clk;

   // -----------------------
   // Interface instance
   // -----------------------
   dff_if vif();

   assign vif.clk = clk;

   // -----------------------
   // DUT instance
   // -----------------------
   dff_examples dut (
      .clk(clk),
      .reset(vif.reset),
      .d_i(vif.d_i),
      .q_norst_o(vif.q_norst_o),

      .q_async_rising_clk_rising_reset_o(
         vif.q_async_rising_clk_rising_reset_o
      ),

      .q_async_falling_clk_rising_reset_o(
         vif.q_async_falling_clk_rising_reset_o
      ),

      .q_async_falling_clk_falling_reset_o(
         vif.q_async_falling_clk_falling_reset_o
      ),

      .q_async_rising_clk_falling_reset_o(
         vif.q_async_rising_clk_falling_reset_o
      ),

      .q_sync_reset_o(vif.q_sync_reset_o)
   );

   // -----------------------
   // UVM start-up
   // -----------------------
   initial begin

      // Give interface to UVM world
      uvm_config_db#(virtual dff_if)::set(null, "*", "dff_vif", vif);

      // Start test
      run_test("dff_test_cls");

   end
endmodule