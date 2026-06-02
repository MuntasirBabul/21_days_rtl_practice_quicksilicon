class dff_sequencer extends uvm_sequencer #(dff_drv_txn_cls);

   `uvm_component_utils(dff_sequencer)

   function new(string name = "dff_sequencer", uvm_component parent = null);
      super.new(name, parent);
   endfunction

endclass
