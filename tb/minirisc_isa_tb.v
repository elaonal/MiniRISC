`timescale 1ns/1ps

module minirisc_isa_tb;

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

    minirisc_cpu dut (
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

        $dumpfile("sim/minirisc_isa.vcd");
        $dumpvars(0, minirisc_isa_tb);

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
        // RESET
        // ========================================================

        reset = 1;
        #12;
        reset = 0;


        // ========================================================
        // PROGRAM BEING TESTED
        // ========================================================

        // 0:  LDI   R1, 12
        // 1:  LDI   R2, 5
        // 2:  MOV   R3, R1
        // 3:  SUB   R3, R2
        // 4:  AND   R1, R2
        // 5:  OR    R1, R2
        // 6:  XOR   R1, R2
        // 7:  LDI   R4, 42
        // 8:  STORE R4, 20
        // 9:  LOAD  R5, 20
        // 10: NOP
        // 11: HALT

        // Give enough time for all instructions
        #500;


        // ========================================================
        // FINAL STATE
        // ========================================================

        $display("");
        $display("==========================================");
        $display("         MINIRISC ISA TEST");
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
            "R4         = %d",
            dut.u_regfile.registers[4]
        );

        $display(
            "R5         = %d",
            dut.u_regfile.registers[5]
        );

        $display(
            "Memory[20] = %d",
            dut.u_dmem.memory[20]
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


        // After AND, OR, XOR:
        //
        // 12 AND 5 = 4
        // 4 OR 5    = 5
        // 5 XOR 5   = 0
        if (dut.u_regfile.registers[1] == 8'd0)
            $display("PASS: AND/OR/XOR path worked - R1 = 0");
        else
            $display(
                "FAIL: R1 should be 0, actual = %d",
                dut.u_regfile.registers[1]
            );


        // R2 should remain unchanged
        if (dut.u_regfile.registers[2] == 8'd5)
            $display("PASS: R2 contains 5");
        else
            $display(
                "FAIL: R2 should contain 5, actual = %d",
                dut.u_regfile.registers[2]
            );


        // MOV R3,R1 gives 12
        // SUB R3,R2 gives 7
        if (dut.u_regfile.registers[3] == 8'd7)
            $display("PASS: MOV and SUB worked - R3 = 7");
        else
            $display(
                "FAIL: R3 should contain 7, actual = %d",
                dut.u_regfile.registers[3]
            );


        // LDI
        if (dut.u_regfile.registers[4] == 8'd42)
            $display("PASS: LDI worked - R4 = 42");
        else
            $display(
                "FAIL: R4 should contain 42, actual = %d",
                dut.u_regfile.registers[4]
            );


        // STORE
        if (dut.u_dmem.memory[20] == 8'd42)
            $display("PASS: STORE worked - Memory[20] = 42");
        else
            $display(
                "FAIL: Memory[20] should contain 42, actual = %d",
                dut.u_dmem.memory[20]
            );


        // LOAD
        if (dut.u_regfile.registers[5] == 8'd42)
            $display("PASS: LOAD worked - R5 = 42");
        else
            $display(
                "FAIL: R5 should contain 42, actual = %d",
                dut.u_regfile.registers[5]
            );


        // XOR produced zero
        if (zero == 1'b1)
            $display("PASS: Zero flag set after XOR result = 0");
        else
            $display("FAIL: Zero flag should be 1");


        // CPU should stop
        if (halted == 1'b1)
            $display("PASS: CPU halted");
        else
            $display("FAIL: CPU should be halted");


        $display("");
        $display("==========================================");

        $finish;

    end

endmodule