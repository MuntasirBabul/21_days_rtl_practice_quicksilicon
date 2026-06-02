class dff_agent extends uvm_agent;

   `uvm_component_utils(dff_agent)

   dff_sequencer seqr;
   dff_driver    drv;
   dff_monitor   mon;

   function new(string name = "dff_agent",
                uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      seqr = dff_sequencer::type_id::create("seqr", this);
      drv  = dff_driver   ::type_id::create("drv" , this);
      mon  = dff_monitor  ::type_id::create("mon" , this);

   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      drv.seq_item_port.connect(seqr.seq_item_export);

   endfunction

endclass
