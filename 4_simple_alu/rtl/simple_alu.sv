import alu_pkg::*;

module simple_alu #
(
  parameter DATA_WIDTH = alu_pkg::DATA_WIDTH
)
(
  input   logic [DATA_WIDTH-1:0] a_i,
  input   logic [DATA_WIDTH-1:0] b_i,
  input   alu_pkg::opcode op_i,

  output  logic [DATA_WIDTH-1:0] alu_o
);

always_comb 
begin
  case(op_i) 

    ADD:    begin 
              alu_o = a_i + b_i;
            end
    
    SUB:    begin
              alu_o = a_i - b_i;
            end
    
    SLL:    begin
              alu_o = a_i[DATA_WIDTH-1:0] << b_i[2:0];
            end
    
    LSR:    begin 
              alu_o = a_i[DATA_WIDTH-1:0] >> b_i[2:0];
            end
    
    AND:    begin
              alu_o = a_i[DATA_WIDTH-1:0] & b_i[DATA_WIDTH-1:0];
            end
    
    OR :    begin 
              alu_o = a_i | b_i;
            end
    
    XOR:    begin 
              alu_o = a_i ^ b_i;
            end
    
    EQL: 
            begin 
              if (a_i == b_i)
                alu_o = 8'b1;
              else 
                alu_o = 8'b0;
            end
    
    default: alu_o = 'b0;
  
  endcase
end
endmodule : simple_alu