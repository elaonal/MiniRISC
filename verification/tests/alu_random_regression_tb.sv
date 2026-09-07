`timescale 1ns/1ps

module alu_random_regression_tb;

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

    integer add_hits;
    integer sub_hits;
    integer and_hits;
    integer or_hits;
    integer xor_hits;

    logic [7:0] random_a;
    logic [7:0] random_b;
    logic [2:0] random_op;


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
    // REFERENCE RESULT
    // ========================================================

    function automatic logic [7:0] ref_result(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        begin

            case (ref_op)

                3'b000:
                    ref_result = ref_a + ref_b;

                3'b001:
                    ref_result = ref_a - ref_b;

                3'b010:
                    ref_result = ref_a & ref_b;

                3'b011:
                    ref_result = ref_a | ref_b;

                3'b100:
                    ref_result = ref_a ^ ref_b;

                default:
                    ref_result = 8'd0;

            endcase

        end

    endfunction


    // ========================================================
    // REFERENCE ZERO
    // ========================================================

    function automatic logic ref_zero(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        logic [7:0] expected_result;

        begin

            expected_result =
                ref_result(
                    ref_a,
                    ref_b,
                    ref_op
                );

            ref_zero =
                (expected_result == 8'd0);

        end

    endfunction


    // ========================================================
    // REFERENCE CARRY
    // ========================================================

    function automatic logic ref_carry(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        logic [8:0] extended;

        begin

            ref_carry = 1'b0;

            if (ref_op == 3'b000) begin

                extended =
                    {1'b0, ref_a} +
                    {1'b0, ref_b};

                ref_carry =
                    extended[8];

            end

        end

    endfunction


    // ========================================================
    // RUN ONE RANDOM TEST
    // ========================================================

    task automatic run_test(
        input logic [7:0] test_a,
        input logic [7:0] test_b,
        input logic [2:0] test_op
    );

        logic [7:0] expected_result;
        logic       expected_zero;
        logic       expected_carry;

        begin

            a  = test_a;
            b  = test_b;
            op = test_op;

            #1;


            expected_result =
                ref_result(a, b, op);

            expected_zero =
                ref_zero(a, b, op);

            expected_carry =
                ref_carry(a, b, op);


            total_tests =
                total_tests + 1;


            case (op)

                3'b000: add_hits++;
                3'b001: sub_hits++;
                3'b010: and_hits++;
                3'b011: or_hits++;
                3'b100: xor_hits++;

            endcase


            if (
                result === expected_result &&
                zero   === expected_zero   &&
                carry  === expected_carry
            ) begin

                pass_count =
                    pass_count + 1;

            end

            else begin

                fail_count =
                    fail_count + 1;


                $display(
                    "FAIL #%0d | A=%0d B=%0d OP=%b",
                    total_tests,
                    a,
                    b,
                    op
                );


                $display(
                    "    DUT R=%0d Z=%b C=%b",
                    result,
                    zero,
                    carry
                );


                $display(
                    "    REF R=%0d Z=%b C=%b",
                    expected_result,
                    expected_zero,
                    expected_carry
                );

            end

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;

        add_hits = 0;
        sub_hits = 0;
        and_hits = 0;
        or_hits  = 0;
        xor_hits = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - RANDOM ALU REGRESSION");
        $display("==============================================");
        $display("");


        // ====================================================
        // 200 RANDOM TESTS
        // ====================================================

        for (i = 0; i < 200; i = i + 1) begin

            random_a =
                $urandom_range(255, 0);

            random_b =
                $urandom_range(255, 0);

            random_op =
                $urandom_range(4, 0);


            run_test(
                random_a,
                random_b,
                random_op
            );

        end


        // ====================================================
        // SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" RANDOM REGRESSION SUMMARY");
        $display("==============================================");

        $display(
            "TOTAL = %0d",
            total_tests
        );

        $display(
            "PASS  = %0d",
            pass_count
        );

        $display(
            "FAIL  = %0d",
            fail_count
        );


        $display("");

        $display(
            "ADD hits = %0d",
            add_hits
        );

        $display(
            "SUB hits = %0d",
            sub_hits
        );

        $display(
            "AND hits = %0d",
            and_hits
        );

        $display(
            "OR hits  = %0d",
            or_hits
        );

        $display(
            "XOR hits = %0d",
            xor_hits
        );


        if (fail_count == 0) begin

            $display("");
            $display(
                "RANDOM ALU REGRESSION: PASS"
            );

        end

        else begin

            $display("");
            $display(
                "RANDOM ALU REGRESSION: FAIL"
            );

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule