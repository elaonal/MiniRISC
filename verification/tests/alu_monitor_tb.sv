`timescale 1ns/1ps

module alu_monitor_tb;

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
    // MONITOR TASK
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
    // STIMULUS
    // ========================================================

    initial begin

        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ALU MONITOR TEST");
        $display("==============================================");
        $display("");


        // ADD
        a  = 8'd5;
        b  = 8'd3;
        op = 3'b000;

        #1;

        monitor_alu();


        // SUB
        a  = 8'd10;
        b  = 8'd3;
        op = 3'b001;

        #1;

        monitor_alu();


        // AND
        a  = 8'hAA;
        b  = 8'hCC;
        op = 3'b010;

        #1;

        monitor_alu();


        // CARRY TEST
        a  = 8'd255;
        b  = 8'd1;
        op = 3'b000;

        #1;

        monitor_alu();


        $display("");
        $display("==============================================");

        $finish;

    end

endmodule