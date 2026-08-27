`timescale 1ns/1ps

module status_register_tb;

    reg clk;
    reg reset;
    reg write_enable;

    reg zero_in;
    reg carry_in;

    wire zero_flag;
    wire carry_flag;


    status_register dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),

        .zero_in(zero_in),
        .carry_in(carry_in),

        .zero_flag(zero_flag),
        .carry_flag(carry_flag)
    );


    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin

        $dumpfile("sim/status_register.vcd");
        $dumpvars(0, status_register_tb);

        $display("TIME CLK RESET WE | Z_IN C_IN | Z C");

        $monitor(
            "%4t  %b    %b    %b |   %b    %b  | %b %b",
            $time,
            clk,
            reset,
            write_enable,
            zero_in,
            carry_in,
            zero_flag,
            carry_flag
        );


        // Reset
        reset        = 1;
        write_enable = 0;
        zero_in      = 0;
        carry_in     = 0;

        #10;


        // Release reset
        reset = 0;


        // Prepare Z=1, C=0
        write_enable = 1;
        zero_in      = 1;
        carry_in     = 0;

        #10;


        // Stop writing
        write_enable = 0;


        // Change inputs, but flags should NOT change
        zero_in  = 0;
        carry_in = 1;

        #10;


        // Now allow new flags to be stored
        write_enable = 1;

        #10;


        write_enable = 0;

        #10;


        $finish;

    end

endmodule