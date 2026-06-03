// This is the base transaction object that will be used
// in the environment to initiate new transactions and
// capture transactions at DUT interface
class dff_txn_drv_cls extends uvm_sequence_item;
   rand bit d_i;
   rand bit reset;

  // Use utility macros to implement standard functions
  // like print, copy, clone, etc
  `uvm_object_utils_begin(dff_txn_drv_cls)
  	`uvm_field_int (d_i,                                UVM_DEFAULT)
  	`uvm_field_int (reset,                              UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "dff_txn_drv_cls");
    super.new(name);
  endfunction

endclass
