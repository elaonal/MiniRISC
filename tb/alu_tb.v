`timescale 1ns/1ps

module alu_tb;

    reg  [7:0] a;
    reg  [7:0] b;
    reg  [2:0] op;

    wire [7:0] result;
    wire       zero;
    wire       carry;

    alu dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .carry(carry)
    );

    initial begin

        $dumpfile("sim/alu.vcd");
        $dumpvars(0, alu_tb);

        $display(" A    B    OP    RESULT    Z    C");
        $monitor("%d   %d   %b      %d      %b    %b",
                 a, b, op, result, zero, carry);

        // ADD: 5 + 3 = 8
        a = 8'd5;
        b = 8'd3;
        op = 3'b000;
        #10;

        // SUB: 10 - 3 = 7
        a = 8'd10;
        b = 8'd3;
        op = 3'b001;
        #10;

        // AND
        a = 8'b10101010;
        b = 8'b11001100;
        op = 3'b010;
        #10;

        // OR
        op = 3'b011;
        #10;

        // XOR
        op = 3'b100;
        #10;

        // SUB producing zero: 5 - 5 = 0
        a = 8'd5;
        b = 8'd5;
        op = 3'b001;
        #10;

        // ADD carry case: 255 + 1
        a = 8'd255;
        b = 8'd1;
        op = 3'b000;
        #10;

        $finish;

    end

endmodule