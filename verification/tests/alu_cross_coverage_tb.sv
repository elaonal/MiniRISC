`timescale 1ns/1ps

module alu_cross_coverage_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer total_tests;
    integer covered_bins;

    // ========================================================
    // OPERATION x ZERO CROSS COVERAGE COUNTERS
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
    // CROSS COVERAGE MONITOR
    // ========================================================

    task automatic sample_cross_coverage;

        begin

            total_tests = total_tests + 1;

            case (op)

                // ------------------------------------------------
                // ADD
                // ------------------------------------------------

                3'b000: begin

                    if (zero == 1'b0)
                        add_z0_hits = add_z0_hits + 1;

                    else if (zero == 1'b1)
                        add_z1_hits = add_z1_hits + 1;

                end


                // ------------------------------------------------
                // SUB
                // ------------------------------------------------

                3'b001: begin

                    if (zero == 1'b0)
                        sub_z0_hits = sub_z0_hits + 1;

                    else if (zero == 1'b1)
                        sub_z1_hits = sub_z1_hits + 1;

                end


                // ------------------------------------------------
                // AND
                // ------------------------------------------------

                3'b010: begin

                    if (zero == 1'b0)
                        and_z0_hits = and_z0_hits + 1;

                    else if (zero == 1'b1)
                        and_z1_hits = and_z1_hits + 1;

                end


                // ------------------------------------------------
                // OR
                // ------------------------------------------------

                3'b011: begin

                    if (zero == 1'b0)
                        or_z0_hits = or_z0_hits + 1;

                    else if (zero == 1'b1)
                        or_z1_hits = or_z1_hits + 1;

                end


                // ------------------------------------------------
                // XOR
                // ------------------------------------------------

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


            $display(
                "A=%0d B=%0d OP=%b | R=%0d Z=%b C=%b",
                a,
                b,
                op,
                result,
                zero,
                carry
            );


            sample_cross_coverage();

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        total_tests  = 0;
        covered_bins = 0;

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


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ALU CROSS COVERAGE");
        $display("==============================================");
        $display("");


        // ====================================================
        // ADD
        // ====================================================

        // ADD with Z=0
        run_test(
            8'd5,
            8'd3,
            3'b000
        );


        // ADD with Z=1
        // 255 + 1 -> 0
        run_test(
            8'd255,
            8'd1,
            3'b000
        );


        // ====================================================
        // SUB
        // ====================================================

        // SUB with Z=0
        run_test(
            8'd10,
            8'd3,
            3'b001
        );


        // SUB with Z=1
        run_test(
            8'd5,
            8'd5,
            3'b001
        );


        // ====================================================
        // AND
        // ====================================================

        // AND with Z=0
        run_test(
            8'hAA,
            8'hCC,
            3'b010
        );


        // AND with Z=1
        run_test(
            8'hF0,
            8'h0F,
            3'b010
        );


        // ====================================================
        // OR
        // ====================================================

        // OR with Z=0
        run_test(
            8'hAA,
            8'h55,
            3'b011
        );

        // NOTICE:
        // We deliberately do NOT test OR with Z=1 yet.


        // ====================================================
        // XOR
        // ====================================================

        // XOR with Z=0
        run_test(
            8'hAA,
            8'hCC,
            3'b100
        );

        // NOTICE:
        // We deliberately do NOT test XOR with Z=1 yet.


        // ====================================================
        // CALCULATE COVERED BINS
        // ====================================================

        if (add_z0_hits > 0)
            covered_bins = covered_bins + 1;

        if (add_z1_hits > 0)
            covered_bins = covered_bins + 1;


        if (sub_z0_hits > 0)
            covered_bins = covered_bins + 1;

        if (sub_z1_hits > 0)
            covered_bins = covered_bins + 1;


        if (and_z0_hits > 0)
            covered_bins = covered_bins + 1;

        if (and_z1_hits > 0)
            covered_bins = covered_bins + 1;


        if (or_z0_hits > 0)
            covered_bins = covered_bins + 1;

        if (or_z1_hits > 0)
            covered_bins = covered_bins + 1;


        if (xor_z0_hits > 0)
            covered_bins = covered_bins + 1;

        if (xor_z1_hits > 0)
            covered_bins = covered_bins + 1;


        // ====================================================
        // COVERAGE REPORT
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" CROSS COVERAGE REPORT");
        $display("==============================================");

        $display("Total transactions = %0d", total_tests);

        $display("");
        $display("              Z=0    Z=1");
        $display("--------------------------------");
        $display(
            "ADD hits      %0d      %0d",
            add_z0_hits,
            add_z1_hits
        );

        $display(
            "SUB hits      %0d      %0d",
            sub_z0_hits,
            sub_z1_hits
        );

        $display(
            "AND hits      %0d      %0d",
            and_z0_hits,
            and_z1_hits
        );

        $display(
            "OR hits       %0d      %0d",
            or_z0_hits,
            or_z1_hits
        );

        $display(
            "XOR hits      %0d      %0d",
            xor_z0_hits,
            xor_z1_hits
        );


        $display("");
        $display(
            "Cross bins covered = %0d / 10",
            covered_bins
        );


        if (covered_bins == 10) begin

            $display("CROSS COVERAGE: 100%%");

        end

        else begin

            $display("CROSS COVERAGE: INCOMPLETE");
        end


        // ====================================================
        // IDENTIFY COVERAGE HOLES
        // ====================================================

        $display("");
        $display("COVERAGE HOLES:");

        if (add_z0_hits == 0)
            $display("- ADD with Z=0");

        if (add_z1_hits == 0)
            $display("- ADD with Z=1");

        if (sub_z0_hits == 0)
            $display("- SUB with Z=0");

        if (sub_z1_hits == 0)
            $display("- SUB with Z=1");

        if (and_z0_hits == 0)
            $display("- AND with Z=0");

        if (and_z1_hits == 0)
            $display("- AND with Z=1");

        if (or_z0_hits == 0)
            $display("- OR with Z=0");

        if (or_z1_hits == 0)
            $display("- OR with Z=1");

        if (xor_z0_hits == 0)
            $display("- XOR with Z=0");

        if (xor_z1_hits == 0)
            $display("- XOR with Z=1");


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule