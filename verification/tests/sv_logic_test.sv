`timescale 1ns/1ps

module sv_logic_test;

    logic a;
    logic b;
    logic y;

    assign y = a & b;

    initial begin

        $display("A B | Y");

        a = 0;
        b = 0;
        #10;
        $display("%b %b | %b", a, b, y);

        a = 0;
        b = 1;
        #10;
        $display("%b %b | %b", a, b, y);

        a = 1;
        b = 0;
        #10;
        $display("%b %b | %b", a, b, y);

        a = 1;
        b = 1;
        #10;
        $display("%b %b | %b", a, b, y);

        $finish;

    end

endmodule