module self_reloading_counter 
(
  input   logic clk,
  input   logic reset,
  input   logic load_i,
  input   logic [3:0] load_val_i,
  output  logic [3:0] count_o
);

  always@(posedge clk or negedge reset) begin
    if (reset == 'b1) begin
      count_o <= 'b0;
    end
    else begin
      count_o = load_i ? load_val_i : (count_o == 4'hF) ? load_val_i : count_o + 'b1;
    end


  end


endmodule
