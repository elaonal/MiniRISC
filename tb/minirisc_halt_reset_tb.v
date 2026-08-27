`timescale 1ns/1ps

module minirisc_halt_reset_tb;

    reg clk;
    reg reset;

    wire [7:0]  pc;
    wire [15:0] instruction;
    wire [2:0]  state;

    wire zero;
    wire carry;
    wire halted;

    reg [7:0] halted_pc;


    // ============================================================
    // CPU
    // ============================================================

    minirisc_cpu #(
        .PROGRAM_FILE("programs/halt_reset_test.mem")
    ) dut (
        .clk(clk),
        .reset(reset),

        .pc_debug(pc),
        .instruction_debug(instruction),
        .state_debug(state),

        .zero_debug(zero),
        .carry_debug(carry),

        .halted(halted)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // ============================================================
    // TEST
    // ============================================================

    initial begin

        $dumpfile("sim/minirisc_halt_reset.vcd");
        $dumpvars(0, minirisc_halt_reset_tb);

        $display(
            "TIME | STATE | PC | R1 | HALT | RESET"
        );

        $monitor(
            "%4t |  %b   | %d | %d |   %b   |   %b",
            $time,
            state,
            pc,
            dut.u_regfile.registers[1],
            halted,
            reset
        );


        // ========================================================
        // INITIAL RESET
        // ========================================================

        reset = 1;
        #12;
        reset = 0;


        // ========================================================
        // FIRST EXECUTION
        // ========================================================

        // Run:
        //
        // LDI R1,7
        // HALT

        #100;


        $display("");
        $display("FIRST HALT CHECK");


        if (dut.u_regfile.registers[1] == 8'd7)
            $display("PASS: R1 contains 7");
        else
            $display(
                "FAIL: R1 should contain 7, actual = %d",
                dut.u_regfile.registers[1]
            );


        if (halted == 1'b1)
            $display("PASS: CPU reached HALT");
        else
            $display("FAIL: CPU should be halted");


        // Remember PC while halted
        halted_pc = pc;


        // ========================================================
        // HALT STABILITY
        // ========================================================

        // Wait several clock cycles.
        //
        // PC and registers should NOT change.

        #50;


        if (halted == 1'b1)
            $display("PASS: CPU remains halted");
        else
            $display("FAIL: CPU left HALT unexpectedly");


        if (pc == halted_pc)
            $display("PASS: PC remained stable during HALT");
        else
            $display(
                "FAIL: PC changed during HALT"
            );


        if (dut.u_regfile.registers[1] == 8'd7)
            $display("PASS: R1 remained stable during HALT");
        else
            $display(
                "FAIL: R1 changed during HALT"
            );


        // ========================================================
        // RESET WHILE HALTED
        // ========================================================

        $display("");
        $display("RESETTING CPU...");

        reset = 1;

        // Enough time to include a rising clock edge
        #10;


        // After reset:
        //
        // PC should be 0
        // registers should be 0
        // FSM should be FETCH
        // halted should be 0

        if (pc == 8'd0)
            $display("PASS: Reset returned PC to 0");
        else
            $display(
                "FAIL: PC should be 0 after reset"
            );


        if (dut.u_regfile.registers[1] == 8'd0)
            $display("PASS: Reset cleared R1");
        else
            $display(
                "FAIL: Reset should clear R1"
            );


        if (halted == 1'b0)
            $display("PASS: Reset released HALT state");
        else
            $display(
                "FAIL: CPU still halted after reset"
            );


        // ========================================================
        // RUN CPU AGAIN
        // ========================================================

        reset = 0;

        #100;


        $display("");
        $display("SECOND EXECUTION CHECK");


        if (dut.u_regfile.registers[1] == 8'd7)
            $display(
                "PASS: CPU executed program again after reset"
            );
        else
            $display(
                "FAIL: R1 should contain 7 after restart"
            );


        if (halted == 1'b1)
            $display(
                "PASS: CPU halted again after restart"
            );
        else
            $display(
                "FAIL: CPU should halt again"
            );


        $display("");
        $display("==========================================");
        $display("       HALT / RESET TEST COMPLETE");
        $display("==========================================");


        $finish;

    end

endmodule