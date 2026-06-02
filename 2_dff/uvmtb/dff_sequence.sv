class dff_rand_seq_cls extends uvm_sequence #(dff_txn_drv_cls);

  `uvm_object_utils(dff_rand_seq_cls)

  task body();
    repeat(200) begin
      dff_txn_drv_cls dff_txn_drv_obj;
      dff_txn_drv_obj = dff_txn_drv_cls::type_id::create("dff_txn_drv_obj");
      start_item(dff_txn_drv_obj);
      assert(dff_txn_drv_obj.randomize());
      finish_item(dff_txn_drv_obj);
    end
  endtask

endclass
