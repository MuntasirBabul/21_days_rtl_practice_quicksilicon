
class dff_mon_cls extends uvm_monitor;

  `uvm_component_utils(dff_mon_cls)

  function new(string name="dff_mon_cls", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual dff_if vif;

  uvm_analysis_port #(dff_txn_mon_cls) mon_analysis_port;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dff_if)::get(this, "", "dff_vif", vif))
      `uvm_fatal("MON", "Could not get vif")
    mon_analysis_port = new ("mon_analysis_port", this);
  endfunction

//  virtual task run_phase(uvm_phase phase);
//    super.run_phase(phase);
//    
//    forever begin
//      dff_txn_mon_cls dff_txn_mon_obj;
//      @(posedge vif.clk);
//      
//      dff_txn_mon_obj = dff_txn_mon_cls::type_id::create("dff_txn_mon_obj");
//
//      dff_txn_mon_obj.d_i   = vif.d_i;
//      dff_txn_mon_obj.reset = vif.reset;
//
//      dff_txn_mon_obj.q_norst_o = vif.q_norst_o;
//      dff_txn_mon_obj.q_async_rising_clk_rising_reset_o = vif.q_async_rising_clk_rising_reset_o;
//      dff_txn_mon_obj.q_async_rising_clk_falling_reset_o = vif.q_async_rising_clk_falling_reset_o;
//      dff_txn_mon_obj.q_async_falling_clk_falling_reset_o = vif.q_async_falling_clk_falling_reset_o;
//      dff_txn_mon_obj.q_async_falling_clk_rising_reset_o = vif.q_async_falling_clk_rising_reset_o;
//      dff_txn_mon_obj.q_sync_reset_o = vif.q_sync_reset_o;
//
//      mon_analysis_port.write(dff_txn_mon_obj);
//    end
//  endtask
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    `uvm_info("MON", $sformatf("Wait for item from sequencer"), UVM_LOW)
    fork
      forever begin
        dff_txn_mon_cls dff_txn_mon_obj1;
        dff_txn_mon_cls dff_txn_mon_obj2;
        dff_txn_mon_cls dff_txn_mon_obj3;

        monitor_inputs(dff_txn_mon_obj3);
        monitor_rising_edge(dff_txn_mon_obj1);
        monitor_falling_edge(dff_txn_mon_obj2);
      end
    join_none
  endtask

  virtual task monitor_rising_edge(dff_txn_mon_cls dff_txn_mon_obj1);
    @(posedge vif.clk);
    dff_txn_mon_obj1 = dff_txn_mon_cls::type_id::create("dff_txn_mon_obj1");
    dff_txn_mon_obj1.q_norst_o = vif.q_norst_o;
    dff_txn_mon_obj1.q_async_rising_clk_rising_reset_o = vif.q_async_rising_clk_rising_reset_o;
    dff_txn_mon_obj1.q_async_rising_clk_falling_reset_o = vif.q_async_rising_clk_falling_reset_o;
    dff_txn_mon_obj1.q_sync_reset_o = vif.q_sync_reset_o;
  endtask

  virtual task monitor_falling_edge(dff_txn_mon_cls dff_txn_mon_obj2);
    @(negedge vif.clk);
    dff_txn_mon_obj2 = dff_txn_mon_cls::type_id::create("dff_txn_mon_obj2");
    dff_txn_mon_obj2.q_async_falling_clk_falling_reset_o = vif.q_async_falling_clk_falling_reset_o;
    dff_txn_mon_obj2.q_async_falling_clk_rising_reset_o = vif.q_async_falling_clk_rising_reset_o;
  endtask

  virtual task monitor_inputs(dff_txn_mon_cls dff_txn_mon_obj3);
    dff_txn_mon_obj3 = dff_txn_mon_cls::type_id::create("dff_txn_mon_obj3");
    dff_txn_mon_obj3.d_i   = vif.d_i;
    dff_txn_mon_obj3.reset = vif.reset;
  endtask  

endclass
