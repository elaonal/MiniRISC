`timescale 1ns/1ps

module alu_coverage_report_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer total_tests;

    // ========================================================
    // OPERATION COVERAGE
    // ========================================================

    integer add_hits;
    integer sub_hits;
    integer and_hits;
    integer or_hits;
    integer xor_hits;

    // ========================================================
    // FLAG COVERAGE
    // ========================================================

    integer zero_0_hits;
    integer zero_1_hits;

    integer carry_0_hits;
    integer carry_1_hits;

    // ========================================================
    // BOUNDARY COVERAGE
    // ========================================================

    integer a_zero_hits;
    integer a_one_hits;
    integer a_254_hits;
    integer a_255_hits;

    integer b_zero_hits;
    integer b_one_hits;
    integer b_254_hits;
    integer b_255_hits;

    // ========================================================
    // CROSS COVERAGE: OPERATION x ZERO
    // ========================================================

    integer add_z0_hits;
    integer add_z1_hits;

    integer sub_z0_hits;
    integer sub_z1_hits;

    integer and_z0_hits;
    integer and_z1_hits;

    integer or_z0_hits;
    integer or_z1_hits;

    integer xor_z0_hits;
    integer xor_z1_hits;

    // ========================================================
    // COVERAGE TOTALS
    // ========================================================

    integer operation_bins_covered;
    integer flag_bins_covered;
    integer boundary_bins_covered;
    integer cross_bins_covered;

    integer total_bins_covered;
    integer total_bins;

    real coverage_percentage;


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
    // COVERAGE SAMPLER
    // ========================================================

    task automatic sample_coverage;

        begin

            total_tests = total_tests + 1;


            // =================================================
            // OPERATION COVERAGE
            // =================================================

            case (op)

                3'b000: add_hits = add_hits + 1;
                3'b001: sub_hits = sub_hits + 1;
                3'b010: and_hits = and_hits + 1;
                3'b011: or_hits  = or_hits  + 1;
                3'b100: xor_hits = xor_hits + 1;

            endcase


            // =================================================
            // FLAG COVERAGE
            // =================================================

            if (zero == 1'b0)
                zero_0_hits = zero_0_hits + 1;

            else if (zero == 1'b1)
                zero_1_hits = zero_1_hits + 1;


            if (carry == 1'b0)
                carry_0_hits = carry_0_hits + 1;

            else if (carry == 1'b1)
                carry_1_hits = carry_1_hits + 1;


            // =================================================
            // BOUNDARY COVERAGE — A
            // =================================================

            if (a == 8'd0)
                a_zero_hits = a_zero_hits + 1;

            if (a == 8'd1)
                a_one_hits = a_one_hits + 1;

            if (a == 8'd254)
                a_254_hits = a_254_hits + 1;

            if (a == 8'd255)
                a_255_hits = a_255_hits + 1;


            // =================================================
            // BOUNDARY COVERAGE — B
            // =================================================

            if (b == 8'd0)
                b_zero_hits = b_zero_hits + 1;

            if (b == 8'd1)
                b_one_hits = b_one_hits + 1;

            if (b == 8'd254)
                b_254_hits = b_254_hits + 1;

            if (b == 8'd255)
                b_255_hits = b_255_hits + 1;


            // =================================================
            // CROSS COVERAGE
            // =================================================

            case (op)

                // ADD
                3'b000: begin

                    if (zero == 1'b0)
                        add_z0_hits = add_z0_hits + 1;

                    else if (zero == 1'b1)
                        add_z1_hits = add_z1_hits + 1;

                end


                // SUB
                3'b001: begin

                    if (zero == 1'b0)
                        sub_z0_hits = sub_z0_hits + 1;

                    else if (zero == 1'b1)
                        sub_z1_hits = sub_z1_hits + 1;

                end


                // AND
                3'b010: begin

                    if (zero == 1'b0)
                        and_z0_hits = and_z0_hits + 1;

                    else if (zero == 1'b1)
                        and_z1_hits = and_z1_hits + 1;

                end


                // OR
                3'b011: begin

                    if (zero == 1'b0)
                        or_z0_hits = or_z0_hits + 1;

                    else if (zero == 1'b1)
                        or_z1_hits = or_z1_hits + 1;

                end


                // XOR
                3'b100: begin

                    if (zero == 1'b0)
                        xor_z0_hits = xor_z0_hits + 1;

                    else if (zero == 1'b1)
                        xor_z1_hits = xor_z1_hits + 1;

                end

            endcase

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

            sample_coverage();

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        // ====================================================
        // INITIALISE COUNTERS
        // ====================================================

        total_tests = 0;

        add_hits = 0;
        sub_hits = 0;
        and_hits = 0;
        or_hits  = 0;
        xor_hits = 0;

        zero_0_hits = 0;
        zero_1_hits = 0;

        carry_0_hits = 0;
        carry_1_hits = 0;

        a_zero_hits = 0;
        a_one_hits  = 0;
        a_254_hits  = 0;
        a_255_hits  = 0;

        b_zero_hits = 0;
        b_one_hits  = 0;
        b_254_hits  = 0;
        b_255_hits  = 0;

        add_z0_hits = 0;
        add_z1_hits = 0;

        sub_z0_hits = 0;
        sub_z1_hits = 0;

        and_z0_hits = 0;
        and_z1_hits = 0;

        or_z0_hits = 0;
        or_z1_hits = 0;

        xor_z0_hits = 0;
        xor_z1_hits = 0;

        operation_bins_covered = 0;
        flag_bins_covered      = 0;
        boundary_bins_covered  = 0;
        cross_bins_covered     = 0;

        total_bins_covered = 0;

        total_bins = 27;

        coverage_percentage = 0.0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - COMBINED COVERAGE REPORT");
        $display("==============================================");
        $display("");


        // ====================================================
        // OPERATION + CROSS COVERAGE TESTS
        // ====================================================


        // ----------------------------------------------------
        // ADD with Zero = 0
        // ----------------------------------------------------

        run_test(
            8'd5,
            8'd3,
            3'b000
        );


        // ----------------------------------------------------
        // ADD with Zero = 1
        // 255 + 1 -> 0, Carry = 1
        // ----------------------------------------------------

        run_test(
            8'd255,
            8'd1,
            3'b000
        );


        // ----------------------------------------------------
        // SUB with Zero = 0
        // ----------------------------------------------------

        run_test(
            8'd10,
            8'd3,
            3'b001
        );


        // ----------------------------------------------------
        // SUB with Zero = 1
        // ----------------------------------------------------

        run_test(
            8'd5,
            8'd5,
            3'b001
        );


        // ----------------------------------------------------
        // AND with Zero = 0
        // ----------------------------------------------------

        run_test(
            8'hAA,
            8'hCC,
            3'b010
        );


        // ----------------------------------------------------
        // AND with Zero = 1
        // F0 AND 0F = 00
        // ----------------------------------------------------

        run_test(
            8'hF0,
            8'h0F,
            3'b010
        );


        // ----------------------------------------------------
        // OR with Zero = 0
        // ----------------------------------------------------

        run_test(
            8'hAA,
            8'h55,
            3'b011
        );


        // ----------------------------------------------------
        // OR with Zero = 1
        //
        // Coverage-closure test:
        // 0 OR 0 = 0
        // ----------------------------------------------------

        run_test(
            8'd0,
            8'd0,
            3'b011
        );


        // ----------------------------------------------------
        // XOR with Zero = 0
        // ----------------------------------------------------

        run_test(
            8'hAA,
            8'hCC,
            3'b100
        );


        // ----------------------------------------------------
        // XOR with Zero = 1
        //
        // Coverage-closure test:
        // equal operands XOR to zero
        // AA XOR AA = 00
        // ----------------------------------------------------

        run_test(
            8'hAA,
            8'hAA,
            3'b100
        );


        // ====================================================
        // ADDITIONAL BOUNDARY TESTS
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


        // A = 255 already exercised above by 255 + 1


        // B = 0
        run_test(
            8'd5,
            8'd0,
            3'b001
        );


        // B = 1 already exercised above by 255 + 1


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
        // CALCULATE OPERATION COVERAGE
        // ====================================================

        if (add_hits > 0)
            operation_bins_covered = operation_bins_covered + 1;

        if (sub_hits > 0)
            operation_bins_covered = operation_bins_covered + 1;

        if (and_hits > 0)
            operation_bins_covered = operation_bins_covered + 1;

        if (or_hits > 0)
            operation_bins_covered = operation_bins_covered + 1;

        if (xor_hits > 0)
            operation_bins_covered = operation_bins_covered + 1;


        // ====================================================
        // CALCULATE FLAG COVERAGE
        // ====================================================

        if (zero_0_hits > 0)
            flag_bins_covered = flag_bins_covered + 1;

        if (zero_1_hits > 0)
            flag_bins_covered = flag_bins_covered + 1;

        if (carry_0_hits > 0)
            flag_bins_covered = flag_bins_covered + 1;

        if (carry_1_hits > 0)
            flag_bins_covered = flag_bins_covered + 1;


        // ====================================================
        // CALCULATE BOUNDARY COVERAGE
        // ====================================================

        if (a_zero_hits > 0)
            boundary_bins_covered = boundary_bins_covered + 1;

        if (a_one_hits > 0)
            boundary_bins_covered = boundary_bins_covered + 1;

        if (a_254_hits > 0)
            boundary_bins_covered = boundary_bins_covered + 1;

        if (a_255_hits > 0)
            boundary_bins_covered = boundary_bins_covered + 1;


        if (b_zero_hits > 0)
            boundary_bins_covered = boundary_bins_covered + 1;

        if (b_one_hits > 0)
            boundary_bins_covered = boundary_bins_covered + 1;

        if (b_254_hits > 0)
            boundary_bins_covered = boundary_bins_covered + 1;

        if (b_255_hits > 0)
            boundary_bins_covered = boundary_bins_covered + 1;


        // ====================================================
        // CALCULATE CROSS COVERAGE
        // ====================================================

        if (add_z0_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;

        if (add_z1_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;


        if (sub_z0_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;

        if (sub_z1_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;


        if (and_z0_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;

        if (and_z1_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;


        if (or_z0_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;

        if (or_z1_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;


        if (xor_z0_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;

        if (xor_z1_hits > 0)
            cross_bins_covered = cross_bins_covered + 1;


        // ====================================================
        // CALCULATE TOTAL COVERAGE
        // ====================================================

        total_bins_covered =
            operation_bins_covered +
            flag_bins_covered +
            boundary_bins_covered +
            cross_bins_covered;


        coverage_percentage =
            (total_bins_covered * 100.0) /
            total_bins;


        // ====================================================
        // FINAL REPORT
        // ====================================================

        $display("==============================================");
        $display(" COVERAGE SUMMARY");
        $display("==============================================");

        $display(
            "Operation coverage = %0d / 5",
            operation_bins_covered
        );

        $display(
            "Flag coverage      = %0d / 4",
            flag_bins_covered
        );

        $display(
            "Boundary coverage  = %0d / 8",
            boundary_bins_covered
        );

        $display(
            "Cross coverage     = %0d / 10",
            cross_bins_covered
        );

        $display("----------------------------------------------");

        $display(
            "TOTAL COVERAGE     = %0d / %0d",
            total_bins_covered,
            total_bins
        );

        $display(
            "COVERAGE PERCENT   = %0.2f%%",
            coverage_percentage
        );


        // ====================================================
        // COVERAGE CLOSURE STATUS
        // ====================================================

        $display("");

        if (
            total_bins_covered == total_bins
        ) begin

            $display("COVERAGE HOLES: NONE");
            $display("COVERAGE CLOSURE: COMPLETE");

        end

        else begin

            $display("COVERAGE HOLES:");

            if (add_z0_hits == 0)
                $display("- ADD with Zero = 0");

            if (add_z1_hits == 0)
                $display("- ADD with Zero = 1");


            if (sub_z0_hits == 0)
                $display("- SUB with Zero = 0");

            if (sub_z1_hits == 0)
                $display("- SUB with Zero = 1");


            if (and_z0_hits == 0)
                $display("- AND with Zero = 0");

            if (and_z1_hits == 0)
                $display("- AND with Zero = 1");


            if (or_z0_hits == 0)
                $display("- OR with Zero = 0");

            if (or_z1_hits == 0)
                $display("- OR with Zero = 1");


            if (xor_z0_hits == 0)
                $display("- XOR with Zero = 0");

            if (xor_z1_hits == 0)
                $display("- XOR with Zero = 1");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule