`timescale 1ns/1ps

module alu_regression_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer total_tests;
    integer pass_count;
    integer fail_count;

    integer i;


    // ========================================================
    // DUT
    // ========================================================

    alu dut (
        .a(a),
        .b(b),
        .op(op),

        .result(result),
        .zero(zero),
        .carry(carry)
    );


    // ========================================================
    // REFERENCE RESULT MODEL
    // ========================================================

    function automatic logic [7:0] ref_result(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        begin

            case (ref_op)

                // ADD
                3'b000:
                    ref_result = ref_a + ref_b;

                // SUB
                3'b001:
                    ref_result = ref_a - ref_b;

                // AND
                3'b010:
                    ref_result = ref_a & ref_b;

                // OR
                3'b011:
                    ref_result = ref_a | ref_b;

                // XOR
                3'b100:
                    ref_result = ref_a ^ ref_b;

                default:
                    ref_result = 8'd0;

            endcase

        end

    endfunction


    // ========================================================
    // REFERENCE ZERO FLAG
    // ========================================================

    function automatic logic ref_zero(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        logic [7:0] expected_result;

        begin

            expected_result = ref_result(
                ref_a,
                ref_b,
                ref_op
            );

            ref_zero = (expected_result == 8'd0);

        end

    endfunction


    // ========================================================
    // REFERENCE CARRY FLAG
    // ========================================================

    function automatic logic ref_carry(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        logic [8:0] extended_result;

        begin

            ref_carry = 1'b0;
            extended_result = 9'd0;

            case (ref_op)

                // ADD
                3'b000: begin

                    extended_result =
                        {1'b0, ref_a} +
                        {1'b0, ref_b};

                    ref_carry = extended_result[8];

                end

                default:
                    ref_carry = 1'b0;

            endcase

        end

    endfunction


    // ========================================================
    // DRIVER
    // ========================================================

    task automatic drive_alu(
        input logic [7:0] test_a,
        input logic [7:0] test_b,
        input logic [2:0] test_op
    );

        begin

            a  = test_a;
            b  = test_b;
            op = test_op;

            #1;

        end

    endtask


    // ========================================================
    // SCOREBOARD
    // ========================================================

    task automatic scoreboard_check;

        logic [7:0] expected_result;
        logic       expected_zero;
        logic       expected_carry;

        begin

            expected_result = ref_result(
                a,
                b,
                op
            );

            expected_zero = ref_zero(
                a,
                b,
                op
            );

            expected_carry = ref_carry(
                a,
                b,
                op
            );

            total_tests = total_tests + 1;

            if (
                result === expected_result &&
                zero   === expected_zero &&
                carry  === expected_carry
            ) begin

                pass_count = pass_count + 1;

            end

            else begin

                fail_count = fail_count + 1;

                $display("");
                $display(
                    "FAIL TEST %0d | A=%0d B=%0d OP=%b",
                    total_tests,
                    a,
                    b,
                    op
                );

                $display(
                    "DUT | R=%0d Z=%b C=%b",
                    result,
                    zero,
                    carry
                );

                $display(
                    "REF | R=%0d Z=%b C=%b",
                    expected_result,
                    expected_zero,
                    expected_carry
                );

            end

        end

    endtask


    // ========================================================
    // COMPLETE TEST TRANSACTION
    // ========================================================

    task automatic run_test(
        input logic [7:0] test_a,
        input logic [7:0] test_b,
        input logic [2:0] test_op
    );

        begin

            drive_alu(
                test_a,
                test_b,
                test_op
            );

            scoreboard_check();

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ALU REGRESSION");
        $display("==============================================");
        $display("");


        // ====================================================
        // DIRECTED TESTS
        // ====================================================

        run_test(
            8'd5,
            8'd3,
            3'b000
        );

        run_test(
            8'd10,
            8'd3,
            3'b001
        );

        run_test(
            8'hAA,
            8'hCC,
            3'b010
        );

        run_test(
            8'hAA,
            8'hCC,
            3'b011
        );

        run_test(
            8'hAA,
            8'hCC,
            3'b100
        );

        run_test(
            8'd255,
            8'd1,
            3'b000
        );

        run_test(
            8'd200,
            8'd100,
            3'b000
        );


        // ====================================================
        // AUTOMATIC REGRESSION
        // ====================================================

        for (i = 0; i < 50; i = i + 1) begin

            run_test(
                (i * 37) + 11,
                (i * 53) + 7,
                i % 5
            );

        end


        // ====================================================
        // SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" REGRESSION SUMMARY");
        $display("==============================================");

        $display("TOTAL TESTS = %0d", total_tests);
        $display("PASS        = %0d", pass_count);
        $display("FAIL        = %0d", fail_count);

        if (fail_count == 0) begin

            $display("");
            $display("OVERALL RESULT: PASS");

        end

        else begin

            $display("");
            $display("OVERALL RESULT: FAIL");

        end

        $display("==============================================");
        $display("");

        $finish;

    end

endmodule