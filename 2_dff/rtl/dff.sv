module dff_examples 
(    
    input     logic      clk,
    input     logic      reset,

    input     logic      d_i,         // -> D input to the flop

    output    logic      q_norst_o,   // -> Q output from non-resettable flop
    output    logic      q_sync_rising_clk_rising_reset_o, // -> Q output from flop using synchronous reset
    output    logic      q_sync_rising_clk_falling_reset_o, // -> Q output from flop using synchronous reset
    output    logic      q_sync_falling_clk_falling_reset_o, // -> Q output from flop using synchronous reset
    output    logic      q_sync_falling_clk_rising_reset_o, // -> Q output from flop using synchronous reset
    output    logic      q_asyncrst_o // -> Q output from flop using asynchrnoous reset
);

// | Output                               | Sensitivity List               | Reset Type       | Active Level | Clock Edge |
// | ------------------------------------ | ------------------------------ | ---------------- | ------------ | ---------- |
// | `q_norst_o`                          | `posedge clk`                  | No reset         | N/A          | Rising     |
// | `q_sync_rising_clk_rising_reset_o`   | `posedge clk or posedge reset` | **Asynchronous** | High         | Rising     |
// | `q_sync_rising_clk_falling_reset_o`  | `posedge clk or negedge reset` | **Asynchronous** | Low          | Rising     |
// | `q_sync_falling_clk_falling_reset_o` | `negedge clk or negedge reset` | **Asynchronous** | Low          | Falling    |
// | `q_sync_falling_clk_rising_reset_o`  | `negedge clk or posedge reset` | **Asynchronous** | High         | Falling    |
// | `q_asyncrst_o`                       | `posedge clk`                  | **Synchronous**  | High         | Rising     |


    always_ff@(posedge clk)
        q_norst_o <= d_i; // no reset

    always_ff@(posedge clk or posedge reset) // Asyc reset
        if (reset == 1'b1) begin // active high reset
            q_sync_rising_clk_rising_reset_o <= 1'b0;
        end
        else begin 
            q_sync_rising_clk_rising_reset_o <= d_i;
        end

    always_ff@(posedge clk or negedge reset) // Async reset
        if (reset == 1'b0) begin // active low reset
            q_sync_rising_clk_falling_reset_o <= 1'b0;
        end
        else begin 
            q_sync_rising_clk_falling_reset_o <= d_i;
        end

    always_ff@(negedge clk or negedge reset) // Async reset
        if (reset == 1'b0) begin // active low reset
            q_sync_falling_clk_falling_reset_o <= 1'b0;
        end
        else begin 
            q_sync_falling_clk_falling_reset_o <= d_i;
        end

    always_ff@(negedge clk or posedge reset) // Async reset
        if (reset == 1'b1) begin // active high reset
            q_sync_falling_clk_rising_reset_o <= 1'b0;
        end
        else begin 
            q_sync_falling_clk_rising_reset_o <= d_i;
        end

    always_ff@(posedge clk) // Sync reset
        if (reset == 1'b1) begin // active high reset
            q_asyncrst_o <= 1'b0;
        end
        else begin
            q_asyncrst_o <= d_i;
        end    

endmodule : dff_examples
