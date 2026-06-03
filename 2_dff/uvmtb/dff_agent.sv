/* The agent is a container for the driver, monitor and sequencer */
class dff_agent_cls extends uvm_agent;

  `uvm_component_utils(dff_agent_cls)

  function new(string name = "dff_agent_cls", uvm_component parent = null);
    super.new(name, parent);
  endfunction
 
  uvm_sequencer #(dff_txn_drv_cls)	dff_seqr_obj; // Sequencer Handle 
  dff_drv_cls    dff_drv_obj;                     // Driver Handle
  dff_mon_cls    dff_mon_obj;                     // Monitor Handle

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    dff_seqr_obj = uvm_sequencer#(dff_txn_drv_cls)::type_id::create("dff_seqr_obj", this);
    dff_drv_obj  = dff_drv_cls::type_id::create("dff_drv_obj" , this);
    dff_mon_obj  = dff_mon_cls::type_id::create("dff_mon_obj" , this);

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dff_drv_obj.seq_item_port.connect(dff_seqr_obj.seq_item_export);
  endfunction

endclass
