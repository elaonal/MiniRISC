`timescale 1ns/1ps

module minirisc_branch_tb;

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
//
// Override the default MiniRISC program file so this testbench
// executes the dedicated branch/JMP verification program.
//
// ============================================================

minirisc_cpu #(
    .PROGRAM_FILE("programs/branch_test.mem")
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
// CLOCK GENERATOR
// ============================================================

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


// ============================================================
// TEST
// ============================================================

initial begin

    $dumpfile("sim/minirisc_branch.vcd");
    $dumpvars(0, minirisc_branch_tb);

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


    // ========================================================
    // RESET CPU
    // ========================================================

    reset = 1;

    #12;

    reset = 0;


    // ========================================================
    // RUN BRANCH PROGRAM
    // ========================================================
    //
    // Program:
    //
    // 0: LDI R1, 5
    // 1: LDI R2, 4
    // 2: CMP R1, R2
    // 3: JZ 6
    // 4: LDI R3, 99
    // 5: JMP 7
    // 6: LDI R3, 42
    // 7: HALT
    //
    // CMP performs:
    //
    // 5 - 4 = 1
    //
    // Therefore:
    //
    // Zero Flag = 0
    //
    // JZ 6 must NOT be taken.
    //
    // Execution continues to:
    //
    // 4: LDI R3, 99
    //
    // Then:
    //
    // 5: JMP 7
    //
    // skips:
    //
    // 6: LDI R3, 42
    //
    // Therefore final R3 must remain 99.
    //
    // ========================================================

    #320;


    // ========================================================
    // FINAL CPU STATE
    // ========================================================

    $display("");
    $display("==========================================");
    $display("      JZ NOT-TAKEN / JMP TEST");
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
        "Carry Flag = %b",
        carry
    );

    $display(
        "PC         = %d",
        pc
    );

    $display(
        "Halted     = %b",
        halted
    );


    // ========================================================
    // AUTOMATED CHECKS
    // ========================================================

    $display("");
    $display("==========================================");
    $display("              TEST RESULTS");
    $display("==========================================");


    // --------------------------------------------------------
    // R1 should contain 5
    // --------------------------------------------------------

    if (dut.u_regfile.registers[1] == 8'd5)
        $display(
            "PASS: R1 contains 5"
        );
    else
        $display(
            "FAIL: R1 should contain 5, actual = %d",
            dut.u_regfile.registers[1]
        );


    // --------------------------------------------------------
    // R2 should contain 4
    // --------------------------------------------------------

    if (dut.u_regfile.registers[2] == 8'd4)
        $display(
            "PASS: R2 contains 4"
        );
    else
        $display(
            "FAIL: R2 should contain 4, actual = %d",
            dut.u_regfile.registers[2]
        );


    // --------------------------------------------------------
    // JZ must NOT be taken.
    //
    // R3 should therefore become 99.
    //
    // JMP must then skip:
    //
    // LDI R3, 42
    // --------------------------------------------------------

    if (dut.u_regfile.registers[3] == 8'd99)
        $display(
            "PASS: JZ not taken and JMP worked - R3 contains 99"
        );
    else
        $display(
            "FAIL: R3 should contain 99, actual = %d",
            dut.u_regfile.registers[3]
        );


    // --------------------------------------------------------
    // CMP 5,4 produces:
    //
    // 5 - 4 = 1
    //
    // Therefore Zero must be clear.
    // --------------------------------------------------------

    if (zero == 1'b0)
        $display(
            "PASS: Zero flag is clear"
        );
    else
        $display(
            "FAIL: Zero flag should be 0"
        );


    // --------------------------------------------------------
    // CPU must eventually reach HALT.
    // --------------------------------------------------------

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