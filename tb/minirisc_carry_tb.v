`timescale 1ns/1ps

module minirisc_carry_tb;

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
        .PROGRAM_FILE("programs/carry_test.mem")
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

        $dumpfile("sim/minirisc_carry.vcd");
        $dumpvars(0, minirisc_carry_tb);

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


        // Program:
        //
        // LDI R1,255
        // LDI R2,1
        // ADD R1,R2
        // HALT
        //
        // Expected:
        //
        // 255 + 1 = 256
        //
        // But R1 is only 8 bits:
        //
        // result = 00000000
        // carry  = 1
        // zero   = 1

        #220;


        // ========================================================
        // FINAL STATE
        // ========================================================

        $display("");
        $display("==========================================");
        $display("       MINIRISC CARRY TEST");
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


        // 255 + 1 wraps to zero in an 8-bit result
        if (dut.u_regfile.registers[1] == 8'd0)
            $display(
                "PASS: 255 + 1 wrapped to 0"
            );
        else
            $display(
                "FAIL: R1 should be 0, actual = %d",
                dut.u_regfile.registers[1]
            );


        // R2 should remain unchanged
        if (dut.u_regfile.registers[2] == 8'd1)
            $display(
                "PASS: R2 remains 1"
            );
        else
            $display(
                "FAIL: R2 should be 1, actual = %d",
                dut.u_regfile.registers[2]
            );


        // Result is zero
        if (zero == 1'b1)
            $display(
                "PASS: Zero flag is set"
            );
        else
            $display(
                "FAIL: Zero flag should be 1"
            );


        // Addition produced a ninth bit
        if (carry == 1'b1)
            $display(
                "PASS: Carry flag is set"
            );
        else
            $display(
                "FAIL: Carry flag should be 1"
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