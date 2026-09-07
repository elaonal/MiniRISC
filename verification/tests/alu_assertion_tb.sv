`timescale 1ns/1ps

module alu_assertion_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer assertion_checks;


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
    // ASSERTION CHECKS
    // ========================================================

    task automatic check_alu_assertions;

        begin

            assertion_checks = assertion_checks + 1;


            // ------------------------------------------------
            // ASSERTION 1:
            //
            // Zero flag must exactly correspond to result == 0.
            // ------------------------------------------------

            assert (zero === (result == 8'd0))

                else begin

                    $error(
                        "ZERO ASSERTION FAILED | R=%0d Z=%b",
                        result,
                        zero
                    );

                end


            // ------------------------------------------------
            // ASSERTION 2:
            //
            // Logic operations should never produce Carry.
            //
            // AND = 010
            // OR  = 011
            // XOR = 100
            // ------------------------------------------------

            if (
                op == 3'b010 ||
                op == 3'b011 ||
                op == 3'b100
            ) begin

                assert (carry === 1'b0)

                    else begin

                        $error(
                            "LOGIC CARRY ASSERTION FAILED | OP=%b C=%b",
                            op,
                            carry
                        );

                    end

            end


            // ------------------------------------------------
            // ASSERTION 3:
            //
            // ADD 255 + 1 must wrap to zero and generate Carry.
            // ------------------------------------------------

            if (
                op == 3'b000 &&
                a  == 8'd255 &&
                b  == 8'd1
            ) begin

                assert (
                    result === 8'd0 &&
                    zero   === 1'b1 &&
                    carry  === 1'b1
                )

                    else begin

                        $error(
                            "ADD OVERFLOW ASSERTION FAILED | R=%0d Z=%b C=%b",
                            result,
                            zero,
                            carry
                        );

                    end

            end

        end

    endtask


    // ========================================================
    // COMPLETE TRANSACTION
    // ========================================================

    task automatic run_test(
        input logic [7:0] test_a,
        input logic [7:0] test_b,
        input logic [2:0] test_op,
        input string      test_name
    );

        begin

            drive_alu(
                test_a,
                test_b,
                test_op
            );


            $display(
                "CHECK | %-18s | A=%0d B=%0d OP=%b | R=%0d Z=%b C=%b",
                test_name,
                a,
                b,
                op,
                result,
                zero,
                carry
            );


            check_alu_assertions();

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        assertion_checks = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ALU ASSERTIONS");
        $display("==============================================");
        $display("");


        // Normal ADD
        run_test(
            8'd5,
            8'd3,
            3'b000,
            "ADD"
        );


        // SUB producing zero
        run_test(
            8'd5,
            8'd5,
            3'b001,
            "SUB ZERO"
        );


        // AND
        run_test(
            8'hAA,
            8'hCC,
            3'b010,
            "AND"
        );


        // OR
        run_test(
            8'hAA,
            8'h55,
            3'b011,
            "OR"
        );


        // XOR
        run_test(
            8'hAA,
            8'hCC,
            3'b100,
            "XOR"
        );


        // Critical overflow case
        run_test(
            8'd255,
            8'd1,
            3'b000,
            "255 + 1"
        );


        $display("");
        $display("==============================================");
        $display(" ASSERTION SUMMARY");
        $display("==============================================");

        $display(
            "Transactions checked = %0d",
            assertion_checks
        );

        $display("");
        $display("ALL ASSERTIONS COMPLETED WITHOUT FAILURE");
        $display("==============================================");
        $display("");

        $finish;

    end

endmodule