interface dff_if;

   logic clk;
   logic reset;
   logic d_i;

   logic q_norst_o;
   logic q_async_rising_clk_rising_reset_o;
   logic q_async_rising_clk_falling_reset_o;
   logic q_async_falling_clk_falling_reset_o;
   logic q_async_falling_clk_rising_reset_o;
   logic q_sync_reset_o;

endinterface
