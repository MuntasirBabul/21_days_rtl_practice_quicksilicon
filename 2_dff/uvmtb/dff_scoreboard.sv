
class dff_sboard_cls extends uvm_scoreboard;

   `uvm_component_utils(dff_sboard_cls)

   uvm_analysis_imp #(dff_txn_mon_cls,dff_sboard_cls) imp;

   bit exp_q_norst;

   function new(string name, uvm_component parent);
      super.new(name,parent);
      imp = new("imp",this);
   endfunction

   function void write(dff_txn_mon_cls tr);
      exp_q_norst = tr.d_i;
      if(tr.q_norst_o !== exp_q_norst)
         `uvm_error("DFF","Mismatch on q_norst_o")
   endfunction

endclass
