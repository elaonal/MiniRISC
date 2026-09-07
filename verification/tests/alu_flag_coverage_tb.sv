`timescale 1ns/1ps

module alu_flag_coverage_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer total_tests;

    integer zero_0_hits;
    integer zero_1_hits;

    integer carry_0_hits;
    integer carry_1_hits;

    integer zero_bins_covered;
    integer carry_bins_covered;


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
    // FLAG COVERAGE MONITOR
    // ========================================================

    task automatic sample_flag_coverage;

        begin

            total_tests = total_tests + 1;


            // ZERO FLAG COVERAGE
            if (zero == 1'b0)
                zero_0_hits = zero_0_hits + 1;

            else if (zero == 1'b1)
                zero_1_hits = zero_1_hits + 1;


            // CARRY FLAG COVERAGE
            if (carry == 1'b0)
                carry_0_hits = carry_0_hits + 1;

            else if (carry == 1'b1)
                carry_1_hits = carry_1_hits + 1;

        end

    endtask


    // ========================================================
    // COMPLETE TRANSACTION
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

            $display(
                "A=%0d B=%0d OP=%b | R=%0d Z=%b C=%b",
                a,
                b,
                op,
                result,
                zero,
                carry
            );

            sample_flag_coverage();

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        total_tests = 0;

        zero_0_hits = 0;
        zero_1_hits = 0;

        carry_0_hits = 0;
        carry_1_hits = 0;

        zero_bins_covered  = 0;
        carry_bins_covered = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ALU FLAG COVERAGE");
        $display("==============================================");
        $display("");


        // Normal ADD
        // Expected: Z=0 C=0
        run_test(
            8'd5,
            8'd3,
            3'b000
        );


        // SUB producing zero
        // Expected: Z=1 C=0
        run_test(
            8'd5,
            8'd5,
            3'b001
        );


        // ADD producing carry + zero
        // Expected: Z=1 C=1
        run_test(
            8'd255,
            8'd1,
            3'b000
        );


        // ADD producing carry without zero
        // Expected: R=44 Z=0 C=1
        run_test(
            8'd200,
            8'd100,
            3'b000
        );


        // Logic operation
        // Expected: Z=0 C=0
        run_test(
            8'hAA,
            8'hCC,
            3'b010
        );


        // ====================================================
        // CALCULATE COVERED BINS
        // ====================================================

        if (zero_0_hits > 0)
            zero_bins_covered = zero_bins_covered + 1;

        if (zero_1_hits > 0)
            zero_bins_covered = zero_bins_covered + 1;


        if (carry_0_hits > 0)
            carry_bins_covered = carry_bins_covered + 1;

        if (carry_1_hits > 0)
            carry_bins_covered = carry_bins_covered + 1;


        // ====================================================
        // COVERAGE REPORT
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" FLAG COVERAGE REPORT");
        $display("==============================================");

        $display("Total transactions = %0d", total_tests);

        $display("");
        $display("Zero = 0 hits  = %0d", zero_0_hits);
        $display("Zero = 1 hits  = %0d", zero_1_hits);

        $display("");
        $display("Carry = 0 hits = %0d", carry_0_hits);
        $display("Carry = 1 hits = %0d", carry_1_hits);

        $display("");
        $display(
            "Zero bins covered  = %0d / 2",
            zero_bins_covered
        );

        $display(
            "Carry bins covered = %0d / 2",
            carry_bins_covered
        );


        if (
            zero_bins_covered == 2 &&
            carry_bins_covered == 2
        ) begin

            $display("");
            $display("FLAG COVERAGE: COMPLETE");

        end

        else begin

            $display("");
            $display("FLAG COVERAGE: INCOMPLETE");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule