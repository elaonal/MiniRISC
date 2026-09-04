`timescale 1ns/1ps

module alu_driver_monitor_tb;

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

            // Allow combinational DUT output to settle.
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
    // TEST SEQUENCE
    // ========================================================

    initial begin

        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - DRIVER + MONITOR");
        $display("==============================================");
        $display("");


        // ADD
        drive_alu(
            8'd5,
            8'd3,
            3'b000
        );

        monitor_alu();


        // SUB
        drive_alu(
            8'd10,
            8'd3,
            3'b001
        );

        monitor_alu();


        // AND
        drive_alu(
            8'hAA,
            8'hCC,
            3'b010
        );

        monitor_alu();


        // OR
        drive_alu(
            8'hAA,
            8'hCC,
            3'b011
        );

        monitor_alu();


        // XOR
        drive_alu(
            8'hAA,
            8'hCC,
            3'b100
        );

        monitor_alu();


        // ZERO FLAG
        drive_alu(
            8'd5,
            8'd5,
            3'b001
        );

        monitor_alu();


        // CARRY EDGE CASE
        drive_alu(
            8'd255,
            8'd1,
            3'b000
        );

        monitor_alu();


        $display("");
        $display("==============================================");

        $finish;

    end

endmodule