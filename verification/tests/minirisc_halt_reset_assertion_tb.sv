`timescale 1ns/1ps

module minirisc_halt_reset_assertion_tb;

    // ========================================================
    // CPU STATE ENCODING
    // ========================================================

    localparam logic [2:0] FETCH = 3'd0;
    localparam logic [2:0] HALT  = 3'd4;


    // ========================================================
    // SIGNALS
    // ========================================================

    logic clk;
    logic reset;

    logic [7:0]  pc;
    logic [15:0] instruction;
    logic [2:0]  state;

    logic zero;
    logic carry;
    logic halted;


    // ========================================================
    // SAVED ARCHITECTURAL STATE
    // ========================================================

    logic [7:0] saved_pc;
    logic [7:0] saved_r1;


    // ========================================================
    // STATISTICS
    // ========================================================

    integer assertion_checks;
    integer assertion_failures;

    integer timeout_counter;


    // ========================================================
    // DUT
    // ========================================================

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


    // ========================================================
    // CLOCK
    // ========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ========================================================
    // NEXT CLOCK CYCLE
    // ========================================================

    task automatic next_cycle;

        begin

            @(posedge clk);

            // Allow non-blocking assignments to complete.
            #1;

        end

    endtask


    // ========================================================
    // ASSERT CPU REACHED HALT
    // ========================================================

    task automatic check_halt_state;

        begin

            assertion_checks = assertion_checks + 1;


            assert (halted === 1'b1)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "HALT ASSERTION FAILED | halted=%b state=%0d PC=%0d",
                    halted,
                    state,
                    pc
                );

            end


            assertion_checks = assertion_checks + 1;


            assert (state === HALT)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "HALT STATE ASSERTION FAILED | state=%0d",
                    state
                );

            end

        end

    endtask


    // ========================================================
    // ASSERT PROGRAM RESULT
    //
    // halt_reset_test.mem should execute:
    //
    // LDI R1, 7
    // HALT
    // ========================================================

    task automatic check_program_result;

        begin

            assertion_checks = assertion_checks + 1;


            assert (
                dut.u_regfile.registers[1] === 8'd7
            )

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "PROGRAM RESULT ASSERTION FAILED | R1=%0d expected=7",
                    dut.u_regfile.registers[1]
                );

            end

        end

    endtask


    // ========================================================
    // ASSERT HALTED ARCHITECTURAL STATE IS STABLE
    // ========================================================

    task automatic check_halt_stability;

        integer i;

        begin

            saved_pc = pc;
            saved_r1 = dut.u_regfile.registers[1];


            $display(
                "Saved HALT state | PC=%0d R1=%0d",
                saved_pc,
                saved_r1
            );


            // Check several complete clock cycles.
            for (i = 0; i < 5; i = i + 1) begin

                next_cycle();


                // --------------------------------------------
                // CPU must remain halted
                // --------------------------------------------

                assertion_checks = assertion_checks + 1;

                assert (halted === 1'b1)

                else begin

                    assertion_failures = assertion_failures + 1;

                    $error(
                        "CPU LEFT HALT | cycle=%0d",
                        i
                    );

                end


                // --------------------------------------------
                // FSM must remain HALT
                // --------------------------------------------

                assertion_checks = assertion_checks + 1;

                assert (state === HALT)

                else begin

                    assertion_failures = assertion_failures + 1;

                    $error(
                        "FSM LEFT HALT | cycle=%0d state=%0d",
                        i,
                        state
                    );

                end


                // --------------------------------------------
                // PC must not change
                // --------------------------------------------

                assertion_checks = assertion_checks + 1;

                assert (pc === saved_pc)

                else begin

                    assertion_failures = assertion_failures + 1;

                    $error(
                        "PC CHANGED DURING HALT | original=%0d current=%0d",
                        saved_pc,
                        pc
                    );

                end


                // --------------------------------------------
                // R1 must not change
                // --------------------------------------------

                assertion_checks = assertion_checks + 1;

                assert (
                    dut.u_regfile.registers[1] === saved_r1
                )

                else begin

                    assertion_failures = assertion_failures + 1;

                    $error(
                        "R1 CHANGED DURING HALT | original=%0d current=%0d",
                        saved_r1,
                        dut.u_regfile.registers[1]
                    );

                end

            end

        end

    endtask


    // ========================================================
    // ASSERT RESET STATE
    // ========================================================

    task automatic check_reset_state;

        begin

            // ------------------------------------------------
            // PC resets to zero
            // ------------------------------------------------

            assertion_checks = assertion_checks + 1;

            assert (pc === 8'd0)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "RESET PC ASSERTION FAILED | PC=%0d",
                    pc
                );

            end


            // ------------------------------------------------
            // Register file resets
            // ------------------------------------------------

            assertion_checks = assertion_checks + 1;

            assert (
                dut.u_regfile.registers[1] === 8'd0
            )

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "RESET REGISTER ASSERTION FAILED | R1=%0d",
                    dut.u_regfile.registers[1]
                );

            end


            // ------------------------------------------------
            // FSM resets to FETCH
            // ------------------------------------------------

            assertion_checks = assertion_checks + 1;

            assert (state === FETCH)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "RESET FSM ASSERTION FAILED | state=%0d",
                    state
                );

            end


            // ------------------------------------------------
            // HALT must be released
            // ------------------------------------------------

            assertion_checks = assertion_checks + 1;

            assert (halted === 1'b0)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "RESET HALT ASSERTION FAILED | halted=%b",
                    halted
                );

            end

        end

    endtask


    // ========================================================
    // WAIT FOR CPU TO HALT
    // ========================================================

    task automatic wait_for_halt;

        begin

            timeout_counter = 0;


            while (
                halted !== 1'b1 &&
                timeout_counter < 30
            ) begin

                next_cycle();

                timeout_counter = timeout_counter + 1;

            end


            assertion_checks = assertion_checks + 1;


            assert (halted === 1'b1)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "CPU TIMEOUT | CPU did not reach HALT within 30 cycles"
                );

            end

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        reset = 1'b1;

        assertion_checks   = 0;
        assertion_failures = 0;

        saved_pc = 8'd0;
        saved_r1 = 8'd0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - CPU HALT/RESET ASSERTIONS");
        $display("==============================================");
        $display("");


        // ====================================================
        // INITIAL RESET
        // ====================================================

        next_cycle();


        $display("CHECKING INITIAL RESET...");

        check_reset_state();


        // ====================================================
        // FIRST EXECUTION
        // ====================================================

        reset = 1'b0;


        $display("");
        $display("RUNNING CPU - FIRST EXECUTION...");


        wait_for_halt();


        $display(
            "CPU HALTED | PC=%0d STATE=%0d R1=%0d",
            pc,
            state,
            dut.u_regfile.registers[1]
        );


        check_halt_state();

        check_program_result();


        // ====================================================
        // HALT STABILITY
        // ====================================================

        $display("");
        $display("CHECKING HALT STABILITY FOR 5 CYCLES...");


        check_halt_stability();


        // ====================================================
        // RESET WHILE HALTED
        // ====================================================

        $display("");
        $display("RESETTING CPU WHILE HALTED...");


        reset = 1'b1;

        next_cycle();


        check_reset_state();


        // ====================================================
        // SECOND EXECUTION
        // ====================================================

        reset = 1'b0;


        $display("");
        $display("RUNNING CPU - SECOND EXECUTION...");


        wait_for_halt();


        $display(
            "CPU HALTED AGAIN | PC=%0d STATE=%0d R1=%0d",
            pc,
            state,
            dut.u_regfile.registers[1]
        );


        check_halt_state();

        check_program_result();


        // ====================================================
        // FINAL SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" CPU HALT/RESET ASSERTION SUMMARY");
        $display("==============================================");

        $display(
            "Assertion checks   = %0d",
            assertion_checks
        );

        $display(
            "Assertion failures = %0d",
            assertion_failures
        );


        if (assertion_failures == 0) begin

            $display("");
            $display("CPU HALT/RESET ASSERTIONS: PASS");

        end

        else begin

            $display("");
            $display("CPU HALT/RESET ASSERTIONS: FAIL");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule