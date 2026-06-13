module fifo_sync 
#(
  parameter DEPTH = 4,
  parameter DATA_W = 1
)
(
  input         logic              clk,
  input         logic              reset,

  input         logic              push_i,
  input         logic[DATA_W-1:0]  push_data_i,

  input         logic              pop_i,
  output        logic[DATA_W-1:0]  pop_data_o,

  output        logic              full_o,
  output        logic              empty_o
);

// Define states for the FSM
typedef enum logic [1:0] {
  ST_PUSH = 2'b01,
  ST_POP  = 2'b10,
  ST_BOTH = 2'b11
} fifo_state_t;

parameter PTR_W = $clog2(DEPTH);

logic [PTR_W:0] nxt_rd_ptr;
logic [PTR_W:0] rd_ptr_q;
logic [PTR_W:0] nxt_wr_ptr;
logic [PTR_W:0] wr_ptr_q;

logic [DATA_W-1:0] fifo_pop_data;

assign pop_data_o = fifo_pop_data;

// Fifo Storage
logic [DEPTH-1:0] [DATA_W-1:0] fifo_mem;

// Flops for pointer
always_ff@(posedge clk or negedge reset) begin
  if (~reset) begin 
    rd_ptr_q <= {PTR_W+1{1'b0}};
    wr_ptr_q <= {PTR_W+1{1'b0}};
  end
  else begin 
    rd_ptr_q <= nxt_rd_ptr;
    wr_ptr_q <= nxt_wr_ptr;
  end
end

// Fifo state based on push pop
always_comb begin 
  nxt_rd_ptr = rd_ptr_q;
  nxt_wr_ptr = wr_ptr_q;
  fifo_pop_data = fifo_mem[rd_ptr_q[PTR_W-1:0]];
  case ({pop_i, push_i})
    ST_PUSH : 
    begin 
      // Increment the write pointer
      nxt_wr_ptr = wr_ptr_q + {{PTR_W{1'b0}}, 1'b1};
    end

    ST_POP :
    begin 
      // Increment the read pointer
      nxt_rd_ptr = rd_ptr_q + {{PTR_W{1'b0}}, 1'b1};
      // Drive the pop data
      fifo_pop_data = fifo_mem[rd_ptr_q[PTR_W-1:0]];
    end

    ST_BOTH :
    begin 
      nxt_wr_ptr = wr_ptr_q + {{PTR_W{1'b0}}, 1'b1};
      nxt_rd_ptr = rd_ptr_q + {{PTR_W{1'b0}}, 1'b1}; 
    end
  endcase
end

// Flops for fifo storage
always_ff @(posedge clk)
  if (push_i)
    fifo_mem[wr_ptr_q[PTR_W-1:0]] <= push_data_i;

// Full when wrap bits are not equal
assign full_o = (rd_ptr_q[PTR_W] != wr_ptr_q[PTR_W]) &
                (rd_ptr_q[PTR_W-1:0] == wr_ptr_q[PTR_W-1:0]);

assign empty_o = (rd_ptr_q[PTR_W:0] == wr_ptr_q[PTR_W:0]);

endmodule
