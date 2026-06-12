import mux_pkg::param_width;
/* verilator lint_off DECLFILENAME */
module parameterized_mux 
#(
	parameter WIDTH = param_width	
) 
(
	input  logic [WIDTH-1:0] a, 
	input  logic [WIDTH-1:0] b,
    input                    sel,	
	output logic [WIDTH-1:0] y
);

	assign y = sel ? a : b;

`ifdef DUMP_VCD
    initial begin
	    $dumpfile("parameterized_mux.vcd");
	    $dumpvars(0, parameterized_mux); 	
    end
`endif

endmodule : parameterized_mux
