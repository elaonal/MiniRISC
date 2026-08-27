`timescale 1ns/1ps

module and_gate_tb;

    reg a;
    reg b;
    wire y;

    and_gate dut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin

        $dumpfile("sim/and_gate.vcd");
        $dumpvars(0, and_gate_tb);

        $display("a b | y");
        $monitor("%b %b | %b", a, b, y);

        a = 0;
        b = 0;
        #10;

        a = 0;
        b = 1;
        #10;

        a = 1;
        b = 0;
        #10;

        a = 1;
        b = 1;
        #10;

        $finish;

    end

endmodule
