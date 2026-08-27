`timescale 1ns/1ps

module minirisc_waveform_tb;

    reg clk;
    reg reset;

    wire [7:0]  pc;
    wire [15:0] instruction;
    wire [2:0]  state;

    wire zero;
    wire carry;
    wire halted;


    minirisc_cpu #(
        .PROGRAM_FILE("programs/waveform_test.mem")
    ) dut (
        .clk(clk),
        .reset(reset),

        .pc_debug(pc),
        .instruction_debug(instruction),
        .state_debug(state),

        .zero_debug(zero),
        .carry_debug(carry),

        .halted(halted)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin

        $dumpfile("sim/minirisc_waveform.vcd");
        $dumpvars(0, minirisc_waveform_tb);

        reset = 1;

        #12;

        reset = 0;

        #200;

        $finish;

    end

endmodule