`timescale 1ns/1ps

module sv_task_test;

    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] result;


    always_comb begin
        result = a + b;
    end


    task run_add_test;

        input logic [7:0] test_a;
        input logic [7:0] test_b;

        begin

            a = test_a;
            b = test_b;

            #10;

            $display(
                "%0d + %0d = %0d",
                a,
                b,
                result
            );

        end

    endtask


    initial begin

        $display("");
        $display("SYSTEMVERILOG TASK TEST");

        run_add_test(5, 3);
        run_add_test(10, 4);
        run_add_test(100, 20);

        $finish;

    end

endmodule