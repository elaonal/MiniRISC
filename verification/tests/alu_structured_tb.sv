`timescale 1ns/1ps

module alu_structured_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;


    // ========================================================
    // TEST STATISTICS
    // ========================================================

    integer total_tests;

    integer pass_count;
    integer fail_count;

    integer add_tests;
    integer sub_tests;
    integer and_tests;
    integer or_tests;
    integer xor_tests;

    integer zero_seen;
    integer carry_seen;


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
    // MONITOR
    // ========================================================

    task automatic monitor_alu;

        begin

            $display(
                "MONITOR | A=%0d B=%0d OP=%b | RESULT=%0d Z=%b C=%b",
                a,
                b,
                op,
                result,
                zero,
                carry
            );

        end

    endtask


    // ========================================================
    // STATISTICS
    // ========================================================

    task automatic update_statistics;

        begin

            total_tests = total_tests + 1;


            case (op)

                3'b000:
                    add_tests = add_tests + 1;

                3'b001:
                    sub_tests = sub_tests + 1;

                3'b010:
                    and_tests = and_tests + 1;

                3'b011:
                    or_tests = or_tests + 1;

                3'b100:
                    xor_tests = xor_tests + 1;

            endcase


            if (zero == 1'b1)
                zero_seen = zero_seen + 1;


            if (carry == 1'b1)
                carry_seen = carry_seen + 1;

        end

    endtask


    // ========================================================
    // CHECKER
    // ========================================================

    task automatic check_result(
        input logic [7:0] expected_result,
        input logic       expected_zero,
        input logic       expected_carry,
        input string      test_name
    );

        begin

            if (
                result === expected_result &&
                zero   === expected_zero   &&
                carry  === expected_carry
            ) begin

                $display(
                    "PASS    | %-20s",
                    test_name
                );

                pass_count = pass_count + 1;

            end

            else begin

                $display(
                    "FAIL    | %-20s | EXPECTED R=%0d Z=%b C=%b",
                    test_name,
                    expected_result,
                    expected_zero,
                    expected_carry
                );

                $display(
                    "          ACTUAL   R=%0d Z=%b C=%b",
                    result,
                    zero,
                    carry
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // ========================================================
    // COMPLETE ALU TRANSACTION
    // ========================================================

    task automatic run_alu_test(
        input logic [7:0] test_a,
        input logic [7:0] test_b,
        input logic [2:0] test_op,

        input logic [7:0] expected_result,
        input logic       expected_zero,
        input logic       expected_carry,

        input string      test_name
    );

        begin

            $display("");

            drive_alu(
                test_a,
                test_b,
                test_op
            );


            monitor_alu();


            update_statistics();


            check_result(
                expected_result,
                expected_zero,
                expected_carry,
                test_name
            );

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        // ----------------------------------------------------
        // Initialise counters
        // ----------------------------------------------------

        total_tests = 0;

        pass_count = 0;
        fail_count = 0;

        add_tests = 0;
        sub_tests = 0;
        and_tests = 0;
        or_tests  = 0;
        xor_tests = 0;

        zero_seen  = 0;
        carry_seen = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - STRUCTURED ALU VERIFICATION");
        $display("==============================================");


        // ====================================================
        // ADD
        // ====================================================

        run_alu_test(
            8'd5,
            8'd3,
            3'b000,

            8'd8,
            1'b0,
            1'b0,

            "ADD 5 + 3"
        );


        // ====================================================
        // SUB
        // ====================================================

        run_alu_test(
            8'd10,
            8'd3,
            3'b001,

            8'd7,
            1'b0,
            1'b0,

            "SUB 10 - 3"
        );


        // ====================================================
        // AND
        // ====================================================

        run_alu_test(
            8'hAA,
            8'hCC,
            3'b010,

            8'h88,
            1'b0,
            1'b0,

            "AND"
        );


        // ====================================================
        // OR
        // ====================================================

        run_alu_test(
            8'hAA,
            8'hCC,
            3'b011,

            8'hEE,
            1'b0,
            1'b0,

            "OR"
        );


        // ====================================================
        // XOR
        // ====================================================

        run_alu_test(
            8'hAA,
            8'hCC,
            3'b100,

            8'h66,
            1'b0,
            1'b0,

            "XOR"
        );


        // ====================================================
        // ZERO RESULT
        // ====================================================

        run_alu_test(
            8'd5,
            8'd5,
            3'b001,

            8'd0,
            1'b1,
            1'b0,

            "ZERO FLAG"
        );


        // ====================================================
        // CARRY EDGE CASE
        // ====================================================

        run_alu_test(
            8'd255,
            8'd1,
            3'b000,

            8'd0,
            1'b1,
            1'b1,

            "CARRY 255 + 1"
        );


        // ====================================================
        // FINAL SUMMARY
        // ====================================================

        $display("");
        $display("");
        $display("==============================================");
        $display(" VERIFICATION SUMMARY");
        $display("==============================================");

        $display("Total tests       = %0d", total_tests);

        $display("PASS              = %0d", pass_count);
        $display("FAIL              = %0d", fail_count);

        $display("");
        $display("ADD tests         = %0d", add_tests);
        $display("SUB tests         = %0d", sub_tests);
        $display("AND tests         = %0d", and_tests);
        $display("OR tests          = %0d", or_tests);
        $display("XOR tests         = %0d", xor_tests);

        $display("");
        $display("Zero observed     = %0d", zero_seen);
        $display("Carry observed    = %0d", carry_seen);


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