`timescale 1ns/1ps

module alu_operation_coverage_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer total_tests;

    integer add_hits;
    integer sub_hits;
    integer and_hits;
    integer or_hits;
    integer xor_hits;

    integer covered_operations;


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
    // COVERAGE MONITOR
    // ========================================================

    task automatic sample_coverage;

        begin

            total_tests = total_tests + 1;

            case (op)

                3'b000:
                    add_hits = add_hits + 1;

                3'b001:
                    sub_hits = sub_hits + 1;

                3'b010:
                    and_hits = and_hits + 1;

                3'b011:
                    or_hits = or_hits + 1;

                3'b100:
                    xor_hits = xor_hits + 1;

            endcase

        end

    endtask


    // ========================================================
    // TEST TRANSACTION
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

        total_tests = 0;

        add_hits = 0;
        sub_hits = 0;
        and_hits = 0;
        or_hits  = 0;
        xor_hits = 0;

        covered_operations = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ALU OPERATION COVERAGE");
        $display("==============================================");
        $display("");


        // ADD
        run_test(
            8'd5,
            8'd3,
            3'b000
        );


        // SUB
        run_test(
            8'd10,
            8'd3,
            3'b001
        );


        // AND
        run_test(
            8'hAA,
            8'hCC,
            3'b010
        );


        // OR
        run_test(
            8'hAA,
            8'hCC,
            3'b011
        );


        // XOR
        run_test(
            8'hAA,
            8'hCC,
            3'b100
        );


        // Extra ADD
        run_test(
            8'd255,
            8'd1,
            3'b000
        );


        // Extra SUB
        run_test(
            8'd5,
            8'd5,
            3'b001
        );


        // ====================================================
        // CALCULATE NUMBER OF COVERED OPERATIONS
        // ====================================================

        if (add_hits > 0)
            covered_operations = covered_operations + 1;

        if (sub_hits > 0)
            covered_operations = covered_operations + 1;

        if (and_hits > 0)
            covered_operations = covered_operations + 1;

        if (or_hits > 0)
            covered_operations = covered_operations + 1;

        if (xor_hits > 0)
            covered_operations = covered_operations + 1;


        // ====================================================
        // COVERAGE REPORT
        // ====================================================

        $display("==============================================");
        $display(" OPERATION COVERAGE REPORT");
        $display("==============================================");

        $display("Total transactions = %0d", total_tests);

        $display("");
        $display("ADD hits = %0d", add_hits);
        $display("SUB hits = %0d", sub_hits);
        $display("AND hits = %0d", and_hits);
        $display("OR hits  = %0d", or_hits);
        $display("XOR hits = %0d", xor_hits);

        $display("");
        $display(
            "Operations covered = %0d / 5",
            covered_operations
        );


        if (covered_operations == 5) begin

            $display("OPERATION COVERAGE: 100%%");

        end

        else begin

            $display("OPERATION COVERAGE: INCOMPLETE");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule