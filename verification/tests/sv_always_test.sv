`timescale 1ns/1ps

module sv_always_test;

    logic clk;
    logic reset;
    logic load;

    logic [7:0] a;
    logic [7:0] b;

    logic [7:0] sum;
    logic [7:0] stored_sum;


    // ========================================================
    // COMBINATIONAL LOGIC
    // ========================================================

    always_comb begin
        sum = a + b;
    end


    // ========================================================
    // SEQUENTIAL LOGIC
    // ========================================================

    always_ff @(posedge clk) begin

        if (reset) begin
            stored_sum <= 8'd0;
        end

        else if (load) begin
            stored_sum <= sum;
        end

    end


    // ========================================================
    // CLOCK
    // ========================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // ========================================================
    // TEST
    // ========================================================

    initial begin

        $display("");
        $display("TIME | A  B | SUM | LOAD | STORED_SUM");

        reset = 1;
        load  = 0;
        a     = 0;
        b     = 0;

        #10;

        reset = 0;

        // Combinational sum becomes 8 immediately.
        a = 5;
        b = 3;

        #2;

        $display(
            "%4t | %0d  %0d | %0d   |  %b   | %0d",
            $time,
            a,
            b,
            sum,
            load,
            stored_sum
        );


        // Enable register loading.
        load = 1;

        #8;

        $display(
            "%4t | %0d  %0d | %0d   |  %b   | %0d",
            $time,
            a,
            b,
            sum,
            load,
            stored_sum
        );


        // Change inputs while load is disabled.
        load = 0;
        a    = 10;
        b    = 4;

        #10;

        $display(
            "%4t | %0d %0d | %0d  |  %b   | %0d",
            $time,
            a,
            b,
            sum,
            load,
            stored_sum
        );


        $finish;

    end

endmodule