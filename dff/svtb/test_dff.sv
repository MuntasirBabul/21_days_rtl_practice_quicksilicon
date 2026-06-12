`timescale 1ns/1ps

module dff_examples_tb;

    logic clk;
    logic reset;
    logic d_i;

    logic q_norst_o;
    logic q1_syncrst_o;
    logic q2_syncrst_o;
    logic q3_syncrst_o;
    logic q4_syncrst_o;
    logic q_asyncrst_o;

    // DUT
    dff_examples dut (
        .clk(clk),
        .reset(reset),
        .d_i(d_i),

        .q_norst_o(q_norst_o),
        .q1_syncrst_o(q1_syncrst_o),
        .q2_syncrst_o(q2_syncrst_o),
        .q3_syncrst_o(q3_syncrst_o),
        .q4_syncrst_o(q4_syncrst_o),
        .q_asyncrst_o(q_asyncrst_o)
    );

    //-----------------------------------------
    // Clock Generation
    //-----------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    //-----------------------------------------
    // Wave Dump
    //-----------------------------------------
    initial begin
        $dumpfile("dff_examples.vcd");
        $dumpvars(0, dff_examples_tb);
    end

    //-----------------------------------------
    // Monitor
    //-----------------------------------------
    initial begin
        $display("TIME  CLK RST D | NORST Q1 Q2 Q3 Q4 QSYNC");
        $monitor("%4t   %0b   %0b  %0b |   %0b    %0b  %0b  %0b  %0b    %0b",
                 $time,
                 clk,
                 reset,
                 d_i,
                 q_norst_o,
                 q1_syncrst_o,
                 q2_syncrst_o,
                 q3_syncrst_o,
                 q4_syncrst_o,
                 q_asyncrst_o);
    end

    //-----------------------------------------
    // Stimulus
    //-----------------------------------------
    initial begin

        // Initial conditions
        reset = 1'b0;
        d_i   = 1'b0;

        //-------------------------------------
        // Test normal operation
        //-------------------------------------
        repeat(2) @(posedge clk);

        d_i = 1'b1;
        repeat(2) @(posedge clk);

        d_i = 1'b0;
        repeat(2) @(posedge clk);

        //-------------------------------------
        // Test active-high async reset
        //-------------------------------------
        #2;
        reset = 1'b1;      // q1 and q4 reset immediately

        #8;
        reset = 1'b0;

        repeat(2) @(posedge clk);

        //-------------------------------------
        // Test data after reset release
        //-------------------------------------
        d_i = 1'b1;
        repeat(2) @(posedge clk);

        //-------------------------------------
        // Force active-low reset behavior
        // (Your q2/q3 use active-low async reset)
        //-------------------------------------
        reset = 1'b0;      // active for q2/q3

        #7;

        reset = 1'b1;      // release q2/q3

        repeat(2) @(posedge clk);

        //-------------------------------------
        // More transitions
        //-------------------------------------
        d_i = 1'b0;
        repeat(2) @(posedge clk);

        d_i = 1'b1;
        repeat(2) @(posedge clk);

        #20;
        $finish;
    end

endmodule
