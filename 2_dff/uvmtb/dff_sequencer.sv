class dff_seqr_cls extends uvm_sequencer #(dff_drv_txn_cls);

   `uvm_component_utils(dff_seqr_cls)

   function new(string name = "dff_seqr_cls", uvm_component parent = null);
      super.new(name, parent);
   endfunction

endclass
