class dff_agent extends uvm_agent;

  `uvm_component_utils(dff_agent)

  function new(string name = "dff_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  dff_seqr_cls   seqr;
  dff_drv_cls    drv;
  dff_mon_cls    mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seqr = dff_seqr_cls::type_id::create("seqr", this);
    drv  = dff_drv_cls::type_id::create("drv" , this);
    mon  = dff_mon_cls::type_id::create("mon" , this);

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass
