`timescale 1ns/1ps

module minirisc_jz_taken_tb;

reg clk;
reg reset;

wire [7:0]  pc;
wire [15:0] instruction;
wire [2:0]  state;

wire zero;
wire carry;
wire halted;


// ============================================================
// MINIRISC CPU
// ============================================================

minirisc_cpu #(
    .PROGRAM_FILE("programs/jz_taken_test.mem")
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


// ============================================================
// CLOCK
// ============================================================

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


// ============================================================
// TEST
// ============================================================

initial begin

    $dumpfile("sim/minirisc_jz_taken.vcd");
    $dumpvars(0, minirisc_jz_taken_tb);

    $display(
        "TIME | STATE | PC | INSTRUCTION       | Z C | HALT"
    );

    $monitor(
        "%4t |  %b   | %d | %b | %b %b |  %b",
        $time,
        state,
        pc,
        instruction,
        zero,
        carry,
        halted
    );


    // Reset CPU
    reset = 1;
    #12;
    reset = 0;


    // Allow program to execute
    #320;


    $display("");
    $display("==========================================");
    $display("            JZ TAKEN TEST");
    $display("==========================================");

    $display(
        "R1         = %d",
        dut.u_regfile.registers[1]
    );

    $display(
        "R2         = %d",
        dut.u_regfile.registers[2]
    );

    $display(
        "R3         = %d",
        dut.u_regfile.registers[3]
    );

    $display(
        "Zero Flag  = %b",
        zero
    );

    $display(
        "PC         = %d",
        pc
    );

    $display(
        "Halted     = %b",
        halted
    );


    $display("");
    $display("==========================================");
    $display("              TEST RESULTS");
    $display("==========================================");


    if (dut.u_regfile.registers[1] == 8'd5)
        $display("PASS: R1 contains 5");
    else
        $display(
            "FAIL: R1 should contain 5, actual = %d",
            dut.u_regfile.registers[1]
        );


    if (dut.u_regfile.registers[2] == 8'd5)
        $display("PASS: R2 contains 5");
    else
        $display(
            "FAIL: R2 should contain 5, actual = %d",
            dut.u_regfile.registers[2]
        );


    if (dut.u_regfile.registers[3] == 8'd42)
        $display(
            "PASS: JZ taken correctly - R3 contains 42"
        );
    else
        $display(
            "FAIL: R3 should contain 42, actual = %d",
            dut.u_regfile.registers[3]
        );


    if (zero == 1'b1)
        $display(
            "PASS: Zero flag is set"
        );
    else
        $display(
            "FAIL: Zero flag should be 1"
        );


    if (halted == 1'b1)
        $display(
            "PASS: CPU halted"
        );
    else
        $display(
            "FAIL: CPU should be halted"
        );


    $display("");
    $display("==========================================");

    $finish;

end

endmodule