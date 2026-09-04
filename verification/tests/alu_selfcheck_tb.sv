`timescale 1ns/1ps

module alu_selfcheck_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer pass_count;
    integer fail_count;


    // ========================================================
    // DUT — REAL MINIRISC ALU
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
    // REUSABLE SELF-CHECKING TASK
    // ========================================================

    task automatic check_alu(
        input logic [7:0] test_a,
        input logic [7:0] test_b,
        input logic [2:0] test_op,

        input logic [7:0] expected_result,
        input logic       expected_zero,
        input logic       expected_carry,

        input string      test_name
    );

        begin

            a  = test_a;
            b  = test_b;
            op = test_op;

            #1;

            if (
                result === expected_result &&
                zero   === expected_zero   &&
                carry  === expected_carry
            ) begin

                $display(
                    "PASS: %-20s | A=%0d B=%0d | RESULT=%0d Z=%b C=%b",
                    test_name,
                    a,
                    b,
                    result,
                    zero,
                    carry
                );

                pass_count = pass_count + 1;

            end

            else begin

                $display(
                    "FAIL: %-20s | A=%0d B=%0d | ACTUAL=%0d Z=%b C=%b | EXPECTED=%0d Z=%b C=%b",
                    test_name,
                    a,
                    b,
                    result,
                    zero,
                    carry,
                    expected_result,
                    expected_zero,
                    expected_carry
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - SYSTEMVERILOG ALU SELF-CHECK ");
        $display("==============================================");
        $display("");


        // ====================================================
        // INTENTIONAL FAILURE TEST
        //
        // Real result:
        // 5 + 3 = 8
        //
        // We deliberately expect 9 to prove that the
        // self-checking testbench detects a mismatch.
        // ====================================================

        check_alu(
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

        check_alu(
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

        check_alu(
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

        check_alu(
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

        check_alu(
            8'hAA,
            8'hCC,
            3'b100,
            8'h66,
            1'b0,
            1'b0,
            "XOR"
        );


        // ====================================================
        // ZERO FLAG
        // ====================================================

        check_alu(
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

        check_alu(
            8'd255,
            8'd1,
            3'b000,
            8'd0,
            1'b1,
            1'b1,
            "CARRY 255 + 1"
        );


        // ====================================================
        // SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" TEST SUMMARY");
        $display("==============================================");

        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);

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