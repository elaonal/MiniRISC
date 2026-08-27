`timescale 1ns/1ps

module instruction_decoder_tb;

    reg  [15:0] instruction;

    wire [3:0] opcode;
    wire [2:0] rd;
    wire [2:0] rs;
    wire [7:0] immediate;


    instruction_decoder dut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs(rs),
        .immediate(immediate)
    );


    initial begin

        $dumpfile("sim/instruction_decoder.vcd");
        $dumpvars(0, instruction_decoder_tb);

        $display("INSTRUCTION         OPCODE RD  RS  IMM");
        $monitor("%b   %b   %b  %b  %d",
                 instruction, opcode, rd, rs, immediate);


        // LDI R1, 5
        instruction = 16'b0001_001_0_00000101;
        #10;


        // ADD R1, R2
        instruction = 16'b0011_001_010_000000;
        #10;


        // STORE R1, address 10
        instruction = 16'b1001_001_0_00001010;
        #10;


        // JMP address 20
        instruction = 16'b1010_0000_00010100;
        #10;


        $finish;

    end

endmodule