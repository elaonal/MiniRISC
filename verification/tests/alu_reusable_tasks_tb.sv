`timescale 1ns/1ps

module alu_reusable_tasks_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;


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
    // REUSABLE TRANSACTION
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

        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - REUSABLE ALU TRANSACTIONS");
        $display("==============================================");
        $display("");


        run_alu_transaction(
            8'd5,
            8'd3,
            3'b000
        );


        run_alu_transaction(
            8'd10,
            8'd3,
            3'b001
        );


        run_alu_transaction(
            8'hAA,
            8'hCC,
            3'b010
        );


        run_alu_transaction(
            8'hAA,
            8'hCC,
            3'b011
        );


        run_alu_transaction(
            8'hAA,
            8'hCC,
            3'b100
        );


        run_alu_transaction(
            8'd5,
            8'd5,
            3'b001
        );


        run_alu_transaction(
            8'd255,
            8'd1,
            3'b000
        );


        $display("");
        $display("==============================================");

        $finish;

    end

endmodule