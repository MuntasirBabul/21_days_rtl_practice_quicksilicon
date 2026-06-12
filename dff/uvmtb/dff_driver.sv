class dff_drv_cls extends uvm_driver #(dff_txn_drv_cls);

  `uvm_component_utils(dff_drv_cls)

  function new(string name = "dff_drv_cls", uvm_component parent=null);
    super.new(name, parent);
  endfunction
   
  virtual dff_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dff_if)::get(this, "", "dff_vif", vif))
      `uvm_fatal("DRV", "Could not get vif")
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      dff_txn_drv_cls dff_txn_drv_obj;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(dff_txn_drv_obj);
      drive_item(dff_txn_drv_obj);
      seq_item_port.item_done();
    end
  endtask

  virtual task drive_item(dff_txn_drv_cls dff_txn_drv_obj);
    vif.d_i   <= dff_txn_drv_obj.d_i;
    vif.reset <= dff_txn_drv_obj.reset;
    @(posedge vif.clk);
  endtask

endclass
