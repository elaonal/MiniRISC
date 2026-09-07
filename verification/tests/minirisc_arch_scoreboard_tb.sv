`timescale 1ns/1ps

module minirisc_arch_scoreboard_tb;

    // ========================================================
    // DUT SIGNALS
    // ========================================================

    logic clk;
    logic reset;

    logic [7:0]  pc;
    logic [15:0] instruction;
    logic [2:0]  state;

    logic zero;
    logic carry;
    logic halted;


    // ========================================================
    // REFERENCE ARCHITECTURAL STATE
    // ========================================================

    logic [7:0] ref_regs [0:7];
    logic [7:0] ref_mem  [0:255];

    logic ref_zero;
    logic ref_carry;


    // ========================================================
    // RETIRING INSTRUCTION
    // ========================================================

    logic [7:0]  retiring_pc;
    logic [15:0] retiring_instruction;

    logic [3:0] ref_opcode;
    logic [2:0] ref_rd;
    logic [2:0] ref_rs;
    logic [7:0] ref_immediate;

    logic [7:0] alu_result;
    logic [8:0] extended_result;


    // ========================================================
    // STATISTICS
    // ========================================================

    integer retire_count;

    integer pass_count;
    integer fail_count;

    integer timeout_cycles;

    integer i;


    // ========================================================
    // DUT
    // ========================================================

    minirisc_cpu #(
        .PROGRAM_FILE("programs/test_program.mem")
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


    // ========================================================
    // CLOCK
    // ========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ========================================================
    // OPCODE NAME
    // ========================================================

    function automatic string opcode_name(
        input logic [3:0] op
    );

        begin

            case (op)

                4'b0000: opcode_name = "NOP";
                4'b0001: opcode_name = "LDI";
                4'b0010: opcode_name = "MOV";
                4'b0011: opcode_name = "ADD";

                4'b0100: opcode_name = "SUB";
                4'b0101: opcode_name = "AND";
                4'b0110: opcode_name = "OR";
                4'b0111: opcode_name = "XOR";

                4'b1000: opcode_name = "LOAD";
                4'b1001: opcode_name = "STORE";
                4'b1010: opcode_name = "JMP";
                4'b1011: opcode_name = "JZ";

                4'b1100: opcode_name = "CMP";
                4'b1101: opcode_name = "RES1";
                4'b1110: opcode_name = "RES2";
                4'b1111: opcode_name = "HALT";

                default: opcode_name = "UNKNOWN";

            endcase

        end

    endfunction


    // ========================================================
    // INITIALISE REFERENCE MODEL
    // ========================================================

    task automatic initialise_reference_model;

        integer index;

        begin

            for (index = 0; index < 8; index = index + 1)
                ref_regs[index] = 8'd0;


            for (index = 0; index < 256; index = index + 1)
                ref_mem[index] = 8'd0;


            ref_zero  = 1'b0;
            ref_carry = 1'b0;

        end

    endtask


    // ========================================================
    // DECODE INSTRUCTION
    //
    // Independent of DUT decoder outputs.
    // ========================================================

    task automatic decode_reference_instruction;

        begin

            ref_opcode =
                retiring_instruction[15:12];

            ref_rd =
                retiring_instruction[11:9];

            ref_rs =
                retiring_instruction[8:6];

            ref_immediate =
                retiring_instruction[7:0];

        end

    endtask


    // ========================================================
    // EXECUTE REFERENCE INSTRUCTION
    // ========================================================

    task automatic execute_reference_instruction;

        begin

            alu_result      = 8'd0;
            extended_result = 9'd0;


            case (ref_opcode)

                // =================================================
                // NOP
                // =================================================

                4'b0000: begin

                end


                // =================================================
                // LDI
                // =================================================

                4'b0001: begin

                    ref_regs[ref_rd] =
                        ref_immediate;

                end


                // =================================================
                // MOV
                // =================================================

                4'b0010: begin

                    ref_regs[ref_rd] =
                        ref_regs[ref_rs];

                end


                // =================================================
                // ADD
                // =================================================

                4'b0011: begin

                    extended_result =
                        {1'b0, ref_regs[ref_rd]} +
                        {1'b0, ref_regs[ref_rs]};


                    alu_result =
                        extended_result[7:0];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        extended_result[8];

                end


                // =================================================
                // SUB
                // =================================================

                4'b0100: begin

                    alu_result =
                        ref_regs[ref_rd] -
                        ref_regs[ref_rs];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry = 1'b0;

                end


                // =================================================
                // AND
                // =================================================

                4'b0101: begin

                    alu_result =
                        ref_regs[ref_rd] &
                        ref_regs[ref_rs];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry = 1'b0;

                end


                // =================================================
                // OR
                // =================================================

                4'b0110: begin

                    alu_result =
                        ref_regs[ref_rd] |
                        ref_regs[ref_rs];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry = 1'b0;

                end


                // =================================================
                // XOR
                // =================================================

                4'b0111: begin

                    alu_result =
                        ref_regs[ref_rd] ^
                        ref_regs[ref_rs];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry = 1'b0;

                end


                // =================================================
                // LOAD
                // =================================================

                4'b1000: begin

                    ref_regs[ref_rd] =
                        ref_mem[ref_immediate];

                end


                // =================================================
                // STORE
                // =================================================

                4'b1001: begin

                    ref_mem[ref_immediate] =
                        ref_regs[ref_rd];

                end


                // =================================================
                // JMP
                // =================================================

                4'b1010: begin

                    // PC checked separately in Step 6.

                end


                // =================================================
                // JZ
                // =================================================

                4'b1011: begin

                    // PC checked separately in Step 6.

                end


                // =================================================
                // CMP
                // =================================================

                4'b1100: begin

                    alu_result =
                        ref_regs[ref_rd] -
                        ref_regs[ref_rs];


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry = 1'b0;

                end


                // =================================================
                // RESERVED
                // =================================================

                4'b1101: begin

                end


                4'b1110: begin

                end


                // =================================================
                // HALT
                // =================================================

                4'b1111: begin

                end


                default: begin

                end

            endcase

        end

    endtask


    // ========================================================
    // ARCHITECTURAL SCOREBOARD
    // ========================================================

    task automatic scoreboard_check;

        integer r;

        integer mismatch_count;

        begin

            mismatch_count = 0;


            // =================================================
            // REGISTER FILE
            // =================================================

            for (r = 0; r < 8; r = r + 1) begin

                if (
                    dut.u_regfile.registers[r]
                    !==
                    ref_regs[r]
                ) begin

                    mismatch_count =
                        mismatch_count + 1;


                    $display(
                        "    REG MISMATCH | R%0d DUT=%0d REF=%0d",
                        r,
                        dut.u_regfile.registers[r],
                        ref_regs[r]
                    );

                end

            end


            // =================================================
            // ZERO FLAG
            // =================================================

            if (zero !== ref_zero) begin

                mismatch_count =
                    mismatch_count + 1;


                $display(
                    "    ZERO MISMATCH | DUT=%b REF=%b",
                    zero,
                    ref_zero
                );

            end


            // =================================================
            // CARRY FLAG
            // =================================================

            if (carry !== ref_carry) begin

                mismatch_count =
                    mismatch_count + 1;


                $display(
                    "    CARRY MISMATCH | DUT=%b REF=%b",
                    carry,
                    ref_carry
                );

            end


            // =================================================
            // MEMORY CHECK
            //
            // For STORE, compare the affected location.
            // =================================================

            if (ref_opcode == 4'b1001) begin

                if (
                    dut.u_dmem.memory[ref_immediate]
                    !==
                    ref_mem[ref_immediate]
                ) begin

                    mismatch_count =
                        mismatch_count + 1;


                    $display(
                        "    MEMORY MISMATCH | MEM[%0d] DUT=%0d REF=%0d",
                        ref_immediate,
                        dut.u_dmem.memory[ref_immediate],
                        ref_mem[ref_immediate]
                    );

                end

            end


            // =================================================
            // PASS / FAIL FOR THIS RETIREMENT
            // =================================================

            if (mismatch_count == 0) begin

                pass_count = pass_count + 1;


                $display(
                    "PASS | RETIRE #%0d | PC=%0d | %-5s",
                    retire_count,
                    retiring_pc,
                    opcode_name(ref_opcode)
                );

            end


            else begin

                fail_count = fail_count + 1;


                $display(
                    "FAIL | RETIRE #%0d | PC=%0d | %-5s | mismatches=%0d",
                    retire_count,
                    retiring_pc,
                    opcode_name(ref_opcode),
                    mismatch_count
                );

            end

        end

    endtask


    // ========================================================
    // PROCESS RETIREMENT
    // ========================================================

    task automatic process_retirement;

        begin

            retire_count =
                retire_count + 1;


            decode_reference_instruction();


            // Update expected architectural state.
            execute_reference_instruction();


            // Compare expected state against real MiniRISC state.
            scoreboard_check();

        end

    endtask


    // ========================================================
    // RETIREMENT TRACKER
    // ========================================================

    initial begin

        retire_count = 0;


        forever begin

            @(posedge clk);


            if (!reset) begin

                // =================================================
                // NORMAL RETIREMENT
                // =================================================

                if (dut.writeback_state) begin

                    retiring_pc =
                        pc;

                    retiring_instruction =
                        dut.current_instruction;


                    // Allow DUT register / PC NBA updates.
                    #1;


                    process_retirement();

                end


                // =================================================
                // HALT RETIREMENT
                // =================================================

                else if (
                    dut.decode_state &&
                    dut.halt_req
                ) begin

                    retiring_pc =
                        pc;

                    retiring_instruction =
                        dut.current_instruction;


                    // Allow DECODE -> HALT FSM update.
                    #1;


                    process_retirement();

                end

            end

        end

    end


    // ========================================================
    // MAIN TEST
    // ========================================================

    initial begin

        reset = 1'b1;

        pass_count = 0;
        fail_count = 0;

        timeout_cycles = 0;


        initialise_reference_model();


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ARCHITECTURAL SCOREBOARD");
        $display("==============================================");
        $display("");


        // ====================================================
        // RESET
        // ====================================================

        repeat (2)
            @(posedge clk);


        reset = 1'b0;


        // ====================================================
        // RUN UNTIL HALT
        // ====================================================

        while (
            halted !== 1'b1 &&
            timeout_cycles < 100
        ) begin

            @(posedge clk);

            timeout_cycles =
                timeout_cycles + 1;

        end


        // Allow HALT retirement scoreboard event.
        #5;


        // ====================================================
        // FINAL CHECKS
        // ====================================================

        if (retire_count != 12) begin

            fail_count =
                fail_count + 1;


            $display(
                "FAIL | Retirement count expected=12 actual=%0d",
                retire_count
            );

        end


        if (halted !== 1'b1) begin

            fail_count =
                fail_count + 1;


            $display(
                "FAIL | CPU did not reach HALT"
            );

        end


        // ====================================================
        // SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" ARCHITECTURAL SCOREBOARD SUMMARY");
        $display("==============================================");

        $display(
            "Retirements = %0d",
            retire_count
        );

        $display(
            "PASS        = %0d",
            pass_count
        );

        $display(
            "FAIL        = %0d",
            fail_count
        );


        $display("");

        $display(
            "Final DUT: R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d",
            dut.u_regfile.registers[1],
            dut.u_regfile.registers[2],
            dut.u_regfile.registers[3],
            dut.u_regfile.registers[4],
            dut.u_regfile.registers[5]
        );


        $display(
            "Final REF: R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d",
            ref_regs[1],
            ref_regs[2],
            ref_regs[3],
            ref_regs[4],
            ref_regs[5]
        );


        $display(
            "Memory[20] DUT=%0d REF=%0d",
            dut.u_dmem.memory[20],
            ref_mem[20]
        );


        $display(
            "Flags DUT Z=%b C=%b | REF Z=%b C=%b",
            zero,
            carry,
            ref_zero,
            ref_carry
        );


        if (
            fail_count == 0 &&
            retire_count == 12
        ) begin

            $display("");
            $display(
                "ARCHITECTURAL SCOREBOARD: PASS"
            );

        end


        else begin

            $display("");
            $display(
                "ARCHITECTURAL SCOREBOARD: FAIL"
            );

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule