`timescale 1ns/1ps

module control_fsm_assertion_tb;

    // ========================================================
    // STATE ENCODING
    // Must match rtl/control_fsm.v
    // ========================================================

    localparam logic [2:0] FETCH     = 3'd0;
    localparam logic [2:0] DECODE    = 3'd1;
    localparam logic [2:0] EXECUTE   = 3'd2;
    localparam logic [2:0] WRITEBACK = 3'd3;
    localparam logic [2:0] HALT      = 3'd4;


    // ========================================================
    // DUT SIGNALS
    // ========================================================

    logic clk;
    logic reset;
    logic halt_req;

    logic [2:0] state;

    logic fetch_state;
    logic decode_state;
    logic execute_state;
    logic writeback_state;
    logic halted;


    // ========================================================
    // STATISTICS
    // ========================================================

    integer assertion_checks;
    integer assertion_failures;


    // ========================================================
    // DUT
    // ========================================================

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


    // ========================================================
    // CLOCK
    // ========================================================

    always #5 clk = ~clk;


    // ========================================================
    // CHECK LEGAL STATE
    // ========================================================

    task automatic check_legal_state;

        begin

            assertion_checks = assertion_checks + 1;

            assert (
                state == FETCH     ||
                state == DECODE    ||
                state == EXECUTE   ||
                state == WRITEBACK ||
                state == HALT
            )

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "ILLEGAL FSM STATE | state=%b",
                    state
                );

            end

        end

    endtask


    // ========================================================
    // CHECK STATE OUTPUT DECODING
    // ========================================================

    task automatic check_state_outputs;

        begin

            assertion_checks = assertion_checks + 1;

            case (state)

                FETCH: begin

                    assert (
                        fetch_state     === 1'b1 &&
                        decode_state    === 1'b0 &&
                        execute_state   === 1'b0 &&
                        writeback_state === 1'b0 &&
                        halted          === 1'b0
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("FETCH OUTPUT ASSERTION FAILED");

                    end

                end


                DECODE: begin

                    assert (
                        fetch_state     === 1'b0 &&
                        decode_state    === 1'b1 &&
                        execute_state   === 1'b0 &&
                        writeback_state === 1'b0 &&
                        halted          === 1'b0
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("DECODE OUTPUT ASSERTION FAILED");

                    end

                end


                EXECUTE: begin

                    assert (
                        fetch_state     === 1'b0 &&
                        decode_state    === 1'b0 &&
                        execute_state   === 1'b1 &&
                        writeback_state === 1'b0 &&
                        halted          === 1'b0
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("EXECUTE OUTPUT ASSERTION FAILED");

                    end

                end


                WRITEBACK: begin

                    assert (
                        fetch_state     === 1'b0 &&
                        decode_state    === 1'b0 &&
                        execute_state   === 1'b0 &&
                        writeback_state === 1'b1 &&
                        halted          === 1'b0
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("WRITEBACK OUTPUT ASSERTION FAILED");

                    end

                end


                HALT: begin

                    assert (
                        fetch_state     === 1'b0 &&
                        decode_state    === 1'b0 &&
                        execute_state   === 1'b0 &&
                        writeback_state === 1'b0 &&
                        halted          === 1'b1
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("HALT OUTPUT ASSERTION FAILED");

                    end

                end

            endcase

        end

    endtask


    // ========================================================
    // CHECK EXPECTED STATE
    // ========================================================

    task automatic check_expected_state(
        input logic [2:0] expected_state,
        input string      test_name
    );

        begin

            assertion_checks = assertion_checks + 1;


            $display(
                "CHECK | %-24s | STATE=%0d EXPECTED=%0d",
                test_name,
                state,
                expected_state
            );


            assert (state === expected_state)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "STATE TRANSITION FAILED | %s | actual=%0d expected=%0d",
                    test_name,
                    state,
                    expected_state
                );

            end


            check_legal_state();

            check_state_outputs();

        end

    endtask


    // ========================================================
    // WAIT FOR NEXT FSM CLOCK
    // ========================================================

    task automatic next_cycle;

        begin

            @(posedge clk);

            // Allow non-blocking state update to complete.
            #1;

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        clk = 1'b0;

        reset    = 1'b1;
        halt_req = 1'b0;

        assertion_checks   = 0;
        assertion_failures = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - CONTROL FSM ASSERTIONS");
        $display("==============================================");
        $display("");


        // ====================================================
        // RESET -> FETCH
        // ====================================================

        next_cycle();

        check_expected_state(
            FETCH,
            "RESET -> FETCH"
        );


        // Release reset
        reset = 1'b0;


        // ====================================================
        // FETCH -> DECODE
        // ====================================================

        next_cycle();

        check_expected_state(
            DECODE,
            "FETCH -> DECODE"
        );


        // ====================================================
        // DECODE -> EXECUTE
        //
        // halt_req = 0
        // ====================================================

        halt_req = 1'b0;

        next_cycle();

        check_expected_state(
            EXECUTE,
            "DECODE -> EXECUTE"
        );


        // ====================================================
        // EXECUTE -> WRITEBACK
        // ====================================================

        next_cycle();

        check_expected_state(
            WRITEBACK,
            "EXECUTE -> WRITEBACK"
        );


        // ====================================================
        // WRITEBACK -> FETCH
        // ====================================================

        next_cycle();

        check_expected_state(
            FETCH,
            "WRITEBACK -> FETCH"
        );


        // ====================================================
        // FETCH -> DECODE AGAIN
        // ====================================================

        next_cycle();

        check_expected_state(
            DECODE,
            "FETCH -> DECODE"
        );


        // ====================================================
        // DECODE + halt_req -> HALT
        // ====================================================

        halt_req = 1'b1;

        next_cycle();

        check_expected_state(
            HALT,
            "DECODE + HALT -> HALT"
        );


        // ====================================================
        // HALT -> HALT
        // ====================================================

        halt_req = 1'b0;

        next_cycle();

        check_expected_state(
            HALT,
            "HALT -> HALT"
        );


        // One more cycle to prove HALT persists
        next_cycle();

        check_expected_state(
            HALT,
            "HALT REMAINS HALT"
        );


        // ====================================================
        // RESET WHILE HALTED -> FETCH
        // ====================================================

        reset = 1'b1;

        next_cycle();

        check_expected_state(
            FETCH,
            "HALT + RESET -> FETCH"
        );


        // Release reset
        reset = 1'b0;


        // ====================================================
        // PROVE FSM RUNS AGAIN AFTER RESET
        // ====================================================

        next_cycle();

        check_expected_state(
            DECODE,
            "POST-RESET FETCH -> DECODE"
        );


        next_cycle();

        check_expected_state(
            EXECUTE,
            "POST-RESET DECODE -> EXECUTE"
        );


        // ====================================================
        // FINAL SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" FSM ASSERTION SUMMARY");
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
            $display("FSM ASSERTIONS: PASS");

        end

        else begin

            $display("");
            $display("FSM ASSERTIONS: FAIL");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule