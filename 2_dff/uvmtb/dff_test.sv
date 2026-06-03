/* The test instantiates an environment, sets up virtual interface 
handles to sub components and starts a top level sequence. In this 
simple example, we have chosen to also reset the DUT using a reset 
task, after which a sequence of type gen_item_seq is started on 
the agent's sequencer.

Since the sequence consumes simulation time and all other testbench 
components have to run as long as the sequence is active, it is 
important to raise and drop objections appropriately. */

class dff_test_cls extends uvm_test;
  
  `uvm_component_utils(dff_test_cls)
  
  function new(string name = "dff_test_cls", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  dff_env_cls dff_env_obj;
  virtual dff_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dff_env_obj = env::type_id::create("dff_env_obj", this);
    if (!uvm_config_db#(virtual dff_if)::get(this, "", "dff_vif", vif))
      `uvm_fatal("TEST", "Did not get vif")
      uvm_config_db#(virtual dff_if)::set(this, "dff_env_obj.dff_agent_obj.*", "dff_vif", vif);
  endfunction

  virtual task run_phase(uvm_phase phase);
    dff_rand_seq_cls dff_rand_seq_obj = dff_rand_seq_cls::type_id::create("dff_rand_seq_obj");
    phase.raise_objection(this);
    apply_reset();

    seq.randomize();
    seq.start(dff_env_obj.dff_agent_obj.dff_seqr_obj);
    phase.drop_objection(this);
  endtask

  virtual task apply_reset();
    vif.reset <= 0;
    repeat(5) @ (posedge vif.clk);
    vif.reset <= 1;
    repeat(10) @ (posedge vif.clk);
    vif.reset <= 0;
    repeat(5) @ (posedge vif.clk);
  endtask
endclass
