`timescale 1ns/1ps

module minirisc_post_synth_smoke_tb;

    logic clk;
    logic reset;

    wire [7:0]  pc;
    wire [15:0] instruction;
    wire [2:0]  state;

    wire zero;
    wire carry;
    wire halted;

    integer cycles;
    integer failures;


    // ========================================================
    // SYNTHESIZED DUT
    // ========================================================

    minirisc_cpu dut (
        .clk(clk),
        .reset(reset),

        .pc_debug(pc),
        .instruction_debug(instruction),
        .state_debug(state),

        .zero_debug(zero),
        .carry_debug(carry),

        .halted(halted)
    );


    // ========================================================
    // CLOCK
    // ========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ========================================================
    // TEST
    // ========================================================

    initial begin

        reset    = 1'b1;
        cycles   = 0;
        failures = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - POST-SYNTHESIS SMOKE TEST");
        $display("==============================================");
        $display("");


        // ----------------------------------------------------
        // RESET
        // ----------------------------------------------------

        repeat (2)
            @(posedge clk);

        reset = 1'b0;


        // ----------------------------------------------------
        // RUN SYNTHESIZED CPU
        // ----------------------------------------------------

        while (
            halted !== 1'b1 &&
            cycles < 100
        ) begin

            @(posedge clk);

            cycles = cycles + 1;


            if (
                dut.state_debug == 3'd0
            ) begin

                $display(
                    "FETCH | cycle=%0d PC=%0d INSTR=%b",
                    cycles,
                    pc,
                    instruction
                );

            end

        end


        #1;


        // ----------------------------------------------------
        // HALT CHECK
        // ----------------------------------------------------

        if (halted !== 1'b1) begin

            failures = failures + 1;

            $display("");
            $display(
                "FAIL | Synthesized CPU did not reach HALT"
            );

        end


        // ----------------------------------------------------
        // EXPECTED TEST PROGRAM HALT LOCATION
        // ----------------------------------------------------

        if (
            halted === 1'b1 &&
            pc !== 8'd11
        ) begin

            failures = failures + 1;

            $display(
                "FAIL | Final PC=%0d expected=11",
                pc
            );

        end


        // ----------------------------------------------------
        // UNKNOWN CHECK
        // ----------------------------------------------------

        if (
            $isunknown(pc) ||
            $isunknown(state) ||
            $isunknown(halted)
        ) begin

            failures = failures + 1;

            $display(
                "FAIL | X/Z detected in synthesized CPU state"
            );

        end


        // ====================================================
        // SUMMARY
        // ========================================================

        $display("");
        $display("==============================================");
        $display(" POST-SYNTHESIS SUMMARY");
        $display("==============================================");

        $display(
            "Cycles      = %0d",
            cycles
        );

        $display(
            "Final PC    = %0d",
            pc
        );

        $display(
            "Final State = %0d",
            state
        );

        $display(
            "Instruction = %b",
            instruction
        );

        $display(
            "Halted      = %b",
            halted
        );

        $display(
            "Failures    = %0d",
            failures
        );


        if (failures == 0) begin

            $display("");
            $display(
                "POST-SYNTHESIS SMOKE TEST: PASS"
            );

        end

        else begin

            $display("");
            $display(
                "POST-SYNTHESIS SMOKE TEST: FAIL"
            );

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule