`timescale 1ns/1ps

module instruction_memory_tb;

    reg  [7:0]  address;
    wire [15:0] instruction;


    instruction_memory dut (
        .address(address),
        .instruction(instruction)
    );


    initial begin

        $dumpfile("sim/instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        $display("ADDRESS | INSTRUCTION");
        $monitor("%d      | %b", address, instruction);


        address = 8'd0;
        #10;

        address = 8'd1;
        #10;

        address = 8'd2;
        #10;

        address = 8'd3;
        #10;

        address = 8'd4;
        #10;

        address = 8'd5;
        #10;


        $finish;

    end

endmodule