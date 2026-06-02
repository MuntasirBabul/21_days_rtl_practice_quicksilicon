class dff_scoreboard_cls extends uvm_scoreboard;

   `uvm_component_utils(dff_scoreboard_cls)

   uvm_analysis_imp #(dff_mon_txn_cls,dff_scoreboard_cls) imp;

   bit exp_q_norst;

   function new(string name, uvm_component parent);
      super.new(name,parent);
      imp = new("imp",this);
   endfunction

   function void write(dff_mon_txn_cls tr);
      exp_q_norst = tr.d_i;
      if(tr.q_norst_o !== exp_q_norst)
         `uvm_error("DFF","Mismatch on q_norst_o")
   endfunction

endclass
