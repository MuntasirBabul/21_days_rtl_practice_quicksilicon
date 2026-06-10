import alu_pkg::*;

module test_simple_alu ();


  logic [DATA_WIDTH-1:0] a_i;
  logic [DATA_WIDTH-1:0] b_i;
  opcode op_i;
  logic [DATA_WIDTH-1:0] alu_o;
  logic [DATA_WIDTH-1:0] exp_alu_o;

simple_alu dut (.*);

initial begin

  for (int j = 0; j < 3; j++) begin

    for (int i = 0; i < 8; i++) begin

      a_i  = $urandom_range(0, 8'hFF);
      b_i  = $urandom_range(0, 8'hFF);
      op_i = i;

      #1;

      exp_alu_o = alu_ref(a_i, b_i, op_i);

      if (alu_o !== exp_alu_o) begin
        $error("Mismatch! op=%0d a=%0h b=%0h exp=%0h got=%0h",
                op_i, a_i, b_i, exp_alu_o, alu_o);
      end else begin 
        $display("Match! op=%0d a=%0h b=%0h exp=%0h got=%0h",
                op_i, a_i, b_i, exp_alu_o, alu_o);
      end

      #9;

    end

  end

  $display("TEST PASSED");
  $finish;

end

endmodule : test_simple_alu

function automatic logic [DATA_WIDTH-1:0] alu_ref (
  input logic [DATA_WIDTH-1:0] a,
  input logic [DATA_WIDTH-1:0] b,
  input opcode           op
);

  case(op)

    ADD : alu_ref = a + b;

    SUB : alu_ref = a - b;

    SLL : alu_ref = a << b[2:0];

    LSR : alu_ref = a >> b[2:0];

    AND : alu_ref = a & b;

    OR  : alu_ref = a | b;

    XOR : alu_ref = a ^ b;

    EQL : alu_ref = (a == b);

    default : alu_ref = '0;

  endcase

endfunction