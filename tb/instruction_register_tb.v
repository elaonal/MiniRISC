`timescale 1ns/1ps

module instruction_register_tb;

reg         clk;
reg         reset;
reg         load;
reg  [15:0] instruction_in;

wire [15:0] instruction_out;


instruction_register dut (
    .clk(clk),
    .reset(reset),
    .load(load),
    .instruction_in(instruction_in),
    .instruction_out(instruction_out)
);


// Clock: 10 ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


initial begin

    $dumpfile("sim/instruction_register.vcd");
    $dumpvars(0, instruction_register_tb);

    $display("TIME CLK RESET LOAD | INSTRUCTION_IN   INSTRUCTION_OUT");

    $monitor(
        "%4t   %b    %b     %b   | %b   %b",
        $time,
        clk,
        reset,
        load,
        instruction_in,
        instruction_out
    );


    // ------------------------------------------------
    // 1. Reset
    // ------------------------------------------------
    reset          = 1;
    load           = 0;
    instruction_in = 16'b0000000000000000;

    #10;


    // ------------------------------------------------
    // 2. Load first instruction
    // ------------------------------------------------
    reset          = 0;
    load           = 1;
    instruction_in = 16'b0001001000000101;

    #10;


    // ------------------------------------------------
    // 3. Disable load.
    // Change input, but output should HOLD old instruction.
    // ------------------------------------------------
    load           = 0;
    instruction_in = 16'b1010000000010100;

    #20;


    // ------------------------------------------------
    // 4. Load second instruction
    // ------------------------------------------------
    load = 1;

    #10;


    // ------------------------------------------------
    // 5. Hold again
    // ------------------------------------------------
    load = 0;

    #10;


    // ------------------------------------------------
    // 6. Reset again
    // ------------------------------------------------
    reset = 1;

    #10;


    $finish;

end

endmodule