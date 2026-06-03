class dff_env_cls extends uvm_dff_env_cls;
  
  `uvm_component_utils(dff_env_cls)
  
  function new(string name="dff_env_cls", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  dff_agent_cls 		   dff_agent_obj; 		// Agent handle
  dff_sboard_cls	    dff_sboard_obj; 		// Scoreboard handle

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dff_agent_obj = agent::type_id::create("dff_agent_obj", this);
    dff_sboard_obj = scoreboard::type_id::create("dff_sboard_obj", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dff_agent_obj.m0.mon_analysis_port.connect(dff_sboard_obj.m_analysis_imp);
  endfunction
endclass
