
// This is the base transaction object that will be used
// in the environment to initiate new transactions and
// capture transactions at DUT interface
class dff_txn_mon_cls extends uvm_sequence_item;
   bit d_i;
   bit reset;

   bit q_norst_o;
   bit q_sync_rising_clk_rising_reset_o;
   bit q_sync_rising_clk_falling_reset_o;
   bit q_sync_falling_clk_falling_reset_o;
   bit q_sync_falling_clk_rising_reset_o;
   bit q_asyncrst_o;

  // Use utility macros to implement standard functions
  // like print, copy, clone, etc
  `uvm_object_utils_begin(dff_txn_mon_cls)
  	`uvm_field_int (d_i,                                UVM_DEFAULT)
  	`uvm_field_int (reset,                              UVM_DEFAULT)
  	`uvm_field_int (q_norst_o,                          UVM_DEFAULT)
  	`uvm_field_int (q_sync_rising_clk_rising_reset_o,   UVM_DEFAULT)
  	`uvm_field_int (q_sync_rising_clk_falling_reset_o,  UVM_DEFAULT)
  	`uvm_field_int (q_sync_rising_clk_falling_reset_o,  UVM_DEFAULT)
  	`uvm_field_int (q_sync_falling_clk_rising_reset_o,  UVM_DEFAULT)
  	`uvm_field_int (q_asyncrst_o,                       UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "dff_txn_mon_cls");
    super.new(name);
  endfunction

endclass
