`timescale 1ns/1ps

module program_counter_tb;

    reg        clk;
    reg        reset;
    reg        enable;
    reg        load;
    reg  [7:0] next_pc;

    wire [7:0] pc;


    program_counter dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .load(load),
        .next_pc(next_pc),
        .pc(pc)
    );


    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin

        $dumpfile("sim/program_counter.vcd");
        $dumpvars(0, program_counter_tb);

        $display("TIME   CLK RESET LOAD NEXT_PC PC");
        $monitor(
            "%4t    %b     %b    %b     %d    %d",
            $time,
            clk,
            reset,
            load,
            next_pc,
            pc
        );


        // Start with reset active
        reset   = 1;
        enable  = 1;
        load    = 0;
        next_pc = 8'd0;

        #10;


        // Release reset
        // PC should now increment normally
        reset = 0;

        #30;


        // Jump to address 20
        next_pc = 8'd20;
        load    = 1;

        #10;


        // Return to normal PC + 1 behaviour
        load = 0;

        #20;


        $finish;

    end

endmodule