`timescale 1ns/1ps

module sv_function_test;

    logic [7:0] a;
    logic [7:0] b;

    logic [7:0] expected_result;


    // ========================================================
    // REFERENCE FUNCTION
    // ========================================================

    function automatic logic [7:0] add_reference(
        input logic [7:0] x,
        input logic [7:0] y
    );

        add_reference = x + y;

    endfunction


    // ========================================================
    // TEST
    // ========================================================

    initial begin

        $display("");
        $display("SYSTEMVERILOG FUNCTION TEST");

        a = 5;
        b = 3;

        expected_result = add_reference(a, b);

        $display(
            "%0d + %0d = %0d",
            a,
            b,
            expected_result
        );


        a = 10;
        b = 4;

        expected_result = add_reference(a, b);

        $display(
            "%0d + %0d = %0d",
            a,
            b,
            expected_result
        );


        a = 255;
        b = 1;

        expected_result = add_reference(a, b);

        $display(
            "%0d + %0d = %0d",
            a,
            b,
            expected_result
        );


        $finish;

    end

endmodule