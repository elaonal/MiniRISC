`timescale 1ns/1ps

module control_fsm_tb;

    reg clk;
    reg reset;
    reg halt_req;

    wire [2:0] state;

    wire fetch_state;
    wire decode_state;
    wire execute_state;
    wire writeback_state;
    wire halted;


    control_fsm dut (
        .clk(clk),
        .reset(reset),
        .halt_req(halt_req),

        .state(state),

        .fetch_state(fetch_state),
        .decode_state(decode_state),
        .execute_state(execute_state),
        .writeback_state(writeback_state),
        .halted(halted)
    );


    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin

        $dumpfile("sim/control_fsm.vcd");
        $dumpvars(0, control_fsm_tb);

        $display(
            "TIME CLK RESET HALT_REQ | STATE | F D E W H"
        );

        $monitor(
            "%4t  %b    %b      %b     |  %b  | %b %b %b %b %b",
            $time,
            clk,
            reset,
            halt_req,
            state,
            fetch_state,
            decode_state,
            execute_state,
            writeback_state,
            halted
        );


        // Start in reset
        reset    = 1;
        halt_req = 0;

        #10;


        // Release reset
        reset = 0;

        // Allow one full instruction cycle
        #40;


        // Request HALT
        halt_req = 1;

        #20;


        // Remove request - CPU should remain halted
        halt_req = 0;

        #20;


        // Reset should restart CPU
        reset = 1;

        #10;


        reset = 0;

        #20;


        $finish;

    end

endmodule