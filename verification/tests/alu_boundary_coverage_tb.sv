`timescale 1ns/1ps

module alu_boundary_coverage_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer total_tests;

    integer a_zero_hits;
    integer a_one_hits;
    integer a_254_hits;
    integer a_255_hits;

    integer b_zero_hits;
    integer b_one_hits;
    integer b_254_hits;
    integer b_255_hits;

    integer covered_bins;


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
    // BOUNDARY COVERAGE MONITOR
    // ========================================================

    task automatic sample_boundary_coverage;

        begin

            total_tests = total_tests + 1;


            // ------------------------------------------------
            // Operand A
            // ------------------------------------------------

            if (a == 8'd0)
                a_zero_hits = a_zero_hits + 1;

            if (a == 8'd1)
                a_one_hits = a_one_hits + 1;

            if (a == 8'd254)
                a_254_hits = a_254_hits + 1;

            if (a == 8'd255)
                a_255_hits = a_255_hits + 1;


            // ------------------------------------------------
            // Operand B
            // ------------------------------------------------

            if (b == 8'd0)
                b_zero_hits = b_zero_hits + 1;

            if (b == 8'd1)
                b_one_hits = b_one_hits + 1;

            if (b == 8'd254)
                b_254_hits = b_254_hits + 1;

            if (b == 8'd255)
                b_255_hits = b_255_hits + 1;

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

            sample_boundary_coverage();

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        total_tests = 0;

        a_zero_hits = 0;
        a_one_hits  = 0;
        a_254_hits  = 0;
        a_255_hits  = 0;

        b_zero_hits = 0;
        b_one_hits  = 0;
        b_254_hits  = 0;
        b_255_hits  = 0;

        covered_bins = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ALU BOUNDARY COVERAGE");
        $display("==============================================");
        $display("");


        // ====================================================
        // DIRECTED BOUNDARY TESTS
        // ====================================================


        // A = 0
        run_test(
            8'd0,
            8'd5,
            3'b000
        );


        // A = 1
        run_test(
            8'd1,
            8'd5,
            3'b000
        );


        // A = 254
        run_test(
            8'd254,
            8'd1,
            3'b000
        );


        // A = 255
        run_test(
            8'd255,
            8'd1,
            3'b000
        );


        // B = 0
        run_test(
            8'd5,
            8'd0,
            3'b001
        );


        // B = 1
        run_test(
            8'd5,
            8'd1,
            3'b001
        );


        // B = 254
        run_test(
            8'd1,
            8'd254,
            3'b001
        );


        // B = 255
        run_test(
            8'd1,
            8'd255,
            3'b001
        );


        // ====================================================
        // COUNT COVERED BINS
        // ====================================================

        if (a_zero_hits > 0)
            covered_bins = covered_bins + 1;

        if (a_one_hits > 0)
            covered_bins = covered_bins + 1;

        if (a_254_hits > 0)
            covered_bins = covered_bins + 1;

        if (a_255_hits > 0)
            covered_bins = covered_bins + 1;


        if (b_zero_hits > 0)
            covered_bins = covered_bins + 1;

        if (b_one_hits > 0)
            covered_bins = covered_bins + 1;

        if (b_254_hits > 0)
            covered_bins = covered_bins + 1;

        if (b_255_hits > 0)
            covered_bins = covered_bins + 1;


        // ====================================================
        // COVERAGE REPORT
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" BOUNDARY COVERAGE REPORT");
        $display("==============================================");

        $display("Total transactions = %0d", total_tests);

        $display("");
        $display("A = 0   hits = %0d", a_zero_hits);
        $display("A = 1   hits = %0d", a_one_hits);
        $display("A = 254 hits = %0d", a_254_hits);
        $display("A = 255 hits = %0d", a_255_hits);

        $display("");
        $display("B = 0   hits = %0d", b_zero_hits);
        $display("B = 1   hits = %0d", b_one_hits);
        $display("B = 254 hits = %0d", b_254_hits);
        $display("B = 255 hits = %0d", b_255_hits);

        $display("");
        $display(
            "Boundary bins covered = %0d / 8",
            covered_bins
        );


        if (covered_bins == 8) begin

            $display("BOUNDARY COVERAGE: 100%%");

        end

        else begin

            $display("BOUNDARY COVERAGE: INCOMPLETE");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule