class dff_env_cls extends uvm_env;
  
  `uvm_component_utils(dff_env_cls)
  
  function new(string name="dff_env_cls", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  dff_agent_cls 		   dff_agent_obj; 		// Agent handle
  dff_sboard_cls	    dff_sboard_obj; 		// Scoreboard handle

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dff_agent_obj = dff_agent_cls::type_id::create("dff_agent_obj", this);
    dff_sboard_obj = dff_sboard_cls::type_id::create("dff_sboard_obj", this);
  endfunction
  
  // Connect the monitor to the scoreboard
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dff_agent_obj.dff_mon_obj.mon_analysis_port.connect(dff_sboard_obj.imp);
  endfunction
endclass
