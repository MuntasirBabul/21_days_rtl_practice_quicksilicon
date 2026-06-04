
/* This is the sequence class that generates random transactions for the
   DFF agent */
class dff_rand_seq_cls extends uvm_sequence #(dff_txn_drv_cls);

  `uvm_object_utils(dff_rand_seq_cls)

  function new(string name="dff_rand_seq_cls");
    super.new(name);
  endfunction

  rand int num; // Config total number of items to be sent

  constraint c1 { num inside {10}; }

  virtual task body();
    for (int i = 0; i < num; i ++) begin
      dff_txn_drv_cls dff_txn_drv_obj;
      dff_txn_drv_obj = dff_txn_drv_cls::type_id::create("dff_txn_drv_obj");
      start_item(dff_txn_drv_obj);
      assert(dff_txn_drv_obj.randomize());
      `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
      dff_txn_drv_obj.print();
      finish_item(dff_txn_drv_obj);
    end
  `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask

endclass
