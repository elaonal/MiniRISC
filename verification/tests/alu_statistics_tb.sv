`timescale 1ns/1ps

module alu_statistics_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer total_tests;
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
    // MONITOR + STATISTICS
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


            // Count every transaction
            total_tests = total_tests + 1;


            // Count operation type
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


            // Count interesting flag events
            if (zero == 1'b1)
                zero_seen = zero_seen + 1;

            if (carry == 1'b1)
                carry_seen = carry_seen + 1;

        end

    endtask


    // ========================================================
    // TRANSACTION
    // ========================================================

    task automatic run_alu_transaction(
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

            monitor_alu();

        end

    endtask


    // ========================================================
    // TEST
    // ========================================================

    initial begin

        // Initialise statistics
        total_tests = 0;

        add_tests = 0;
        sub_tests = 0;
        and_tests = 0;
        or_tests  = 0;
        xor_tests = 0;

        zero_seen  = 0;
        carry_seen = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ALU STATISTICS");
        $display("==============================================");
        $display("");


        // ADD
        run_alu_transaction(
            8'd5,
            8'd3,
            3'b000
        );


        // SUB
        run_alu_transaction(
            8'd10,
            8'd3,
            3'b001
        );


        // AND
        run_alu_transaction(
            8'hAA,
            8'hCC,
            3'b010
        );


        // OR
        run_alu_transaction(
            8'hAA,
            8'hCC,
            3'b011
        );


        // XOR
        run_alu_transaction(
            8'hAA,
            8'hCC,
            3'b100
        );


        // ZERO RESULT
        run_alu_transaction(
            8'd5,
            8'd5,
            3'b001
        );


        // CARRY
        run_alu_transaction(
            8'd255,
            8'd1,
            3'b000
        );


        // ====================================================
        // STATISTICS SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" TEST STATISTICS");
        $display("==============================================");

        $display("Total transactions = %0d", total_tests);

        $display("ADD tests          = %0d", add_tests);
        $display("SUB tests          = %0d", sub_tests);
        $display("AND tests          = %0d", and_tests);
        $display("OR tests           = %0d", or_tests);
        $display("XOR tests          = %0d", xor_tests);

        $display("Zero observed      = %0d", zero_seen);
        $display("Carry observed     = %0d", carry_seen);

        $display("==============================================");
        $display("");

        $finish;

    end

endmodule