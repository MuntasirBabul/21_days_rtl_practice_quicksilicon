class dff_sboard_cls extends uvm_scoreboard;

   `uvm_component_utils(dff_sboard_cls)
   
   function new(string name="dff_sboard_cls", uvm_component parent=null);
      super.new(name, parent);
   endfunction

   uvm_analysis_imp #(dff_txn_mon_cls,dff_sboard_cls) imp;

   bit exp_q_norst;
   bit exp_q_async_rising_clk_rising_reset;

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      imp = new("imp",this);
   endfunction

   virtual function void write(dff_txn_mon_cls tr);
      exp_q_norst = tr.d_i;
      if(tr.q_norst_o !== exp_q_norst)
         `uvm_error("DFF","Mismatch on q_norst_o")
      else
         `uvm_info("DFF","Match on q_norst_o", UVM_LOW)

      if(tr.reset)
         exp_q_async_rising_clk_rising_reset = 1'b0;
      else
         exp_q_async_rising_clk_rising_reset = tr.d_i;

      if(tr.reset)
         exp_q_async_rising_clk_rising_reset = 0;
      else
         exp_q_async_rising_clk_rising_reset = tr.d_i;

      if(tr.q_async_rising_clk_rising_reset_o !== exp_q_async_rising_clk_rising_reset)
      begin
         `uvm_error("ASYNC_RST",
            $sformatf(
               "Expected=%0b Actual=%0b Reset=%0b D=%0b",
               exp_q_async_rising_clk_rising_reset,
               tr.q_async_rising_clk_rising_reset_o,
               tr.reset,
               tr.d_i
            ))
      end
      else begin
         `uvm_info("ASYNC_RST",
            $sformatf(
               "Match on q_async_rising_clk_rising_reset_o Reset=%0b D=%0b",
               tr.reset,
               tr.d_i
            ), UVM_LOW)
      end
   endfunction

endclass
