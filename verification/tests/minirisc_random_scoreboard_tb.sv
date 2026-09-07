`timescale 1ns/1ps

module minirisc_random_scoreboard_tb;

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
    // INSTRUCTION HIT COUNTERS
    // ========================================================

    integer nop_hits;
    integer ldi_hits;
    integer mov_hits;
    integer add_hits;
    integer sub_hits;
    integer and_hits;
    integer or_hits;
    integer xor_hits;
    integer cmp_hits;
    integer halt_hits;


    // ========================================================
    // DUT
    // ========================================================

    minirisc_cpu #(
        .PROGRAM_FILE(
            "programs/random_cpu_test.mem"
        )
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

        integer r;

        begin

            for (r = 0; r < 8; r = r + 1)
                ref_regs[r] = 8'd0;


            ref_zero  = 1'b0;
            ref_carry = 1'b0;

        end

    endtask


    // ========================================================
    // DECODE INSTRUCTION
    //
    // Independent from DUT decoder outputs.
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
    // RECORD OPCODE COVERAGE
    // ========================================================

    task automatic record_opcode_hit;

        begin

            case (ref_opcode)

                4'b0000:
                    nop_hits = nop_hits + 1;

                4'b0001:
                    ldi_hits = ldi_hits + 1;

                4'b0010:
                    mov_hits = mov_hits + 1;

                4'b0011:
                    add_hits = add_hits + 1;

                4'b0100:
                    sub_hits = sub_hits + 1;

                4'b0101:
                    and_hits = and_hits + 1;

                4'b0110:
                    or_hits = or_hits + 1;

                4'b0111:
                    xor_hits = xor_hits + 1;

                4'b1100:
                    cmp_hits = cmp_hits + 1;

                4'b1111:
                    halt_hits = halt_hits + 1;

            endcase

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

                    // No architectural effect.

                end


                // =================================================
                // LDI Rd, immediate
                // =================================================

                4'b0001: begin

                    ref_regs[ref_rd] =
                        ref_immediate;

                end


                // =================================================
                // MOV Rd, Rs
                // =================================================

                4'b0010: begin

                    ref_regs[ref_rd] =
                        ref_regs[ref_rs];

                end


                // =================================================
                // ADD Rd, Rs
                // =================================================

                4'b0011: begin

                    extended_result =
                        {1'b0, ref_regs[ref_rd]}
                        +
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
                // SUB Rd, Rs
                // =================================================

                4'b0100: begin

                    alu_result =
                        ref_regs[ref_rd]
                        -
                        ref_regs[ref_rs];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // =================================================
                // AND Rd, Rs
                // =================================================

                4'b0101: begin

                    alu_result =
                        ref_regs[ref_rd]
                        &
                        ref_regs[ref_rs];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // =================================================
                // OR Rd, Rs
                // =================================================

                4'b0110: begin

                    alu_result =
                        ref_regs[ref_rd]
                        |
                        ref_regs[ref_rs];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // =================================================
                // XOR Rd, Rs
                // =================================================

                4'b0111: begin

                    alu_result =
                        ref_regs[ref_rd]
                        ^
                        ref_regs[ref_rs];


                    ref_regs[ref_rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // =================================================
                // CMP Rd, Rs
                //
                // Flags change.
                // Register file does NOT change.
                // =================================================

                4'b1100: begin

                    alu_result =
                        ref_regs[ref_rd]
                        -
                        ref_regs[ref_rs];


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // =================================================
                // HALT
                // =================================================

                4'b1111: begin

                    // No register / flag change.

                end


                // =================================================
                // THESE SHOULD NOT APPEAR IN THIS RANDOM TEST
                // =================================================

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
        integer mismatches;

        begin

            mismatches = 0;


            // =================================================
            // REGISTER FILE
            // =================================================

            for (r = 0; r < 8; r = r + 1) begin

                if (
                    dut.u_regfile.registers[r]
                    !==
                    ref_regs[r]
                ) begin

                    mismatches =
                        mismatches + 1;


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

                mismatches =
                    mismatches + 1;


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

                mismatches =
                    mismatches + 1;


                $display(
                    "    CARRY MISMATCH | DUT=%b REF=%b",
                    carry,
                    ref_carry
                );

            end


            // =================================================
            // RETIREMENT PASS / FAIL
            // =================================================

            if (mismatches == 0) begin

                pass_count =
                    pass_count + 1;


                $display(
                    "PASS | RETIRE #%0d | PC=%0d | %-5s",
                    retire_count,
                    retiring_pc,
                    opcode_name(ref_opcode)
                );

            end


            else begin

                fail_count =
                    fail_count + 1;


                $display(
                    "FAIL | RETIRE #%0d | PC=%0d | %-5s | mismatches=%0d",
                    retire_count,
                    retiring_pc,
                    opcode_name(ref_opcode),
                    mismatches
                );

            end

        end

    endtask


    // ========================================================
    // CHECK SEQUENTIAL PC
    //
    // This random program contains no JMP/JZ.
    // ========================================================

    task automatic check_next_pc;

        logic [7:0] expected_next_pc;

        begin

            if (ref_opcode != 4'b1111) begin

                expected_next_pc =
                    retiring_pc + 8'd1;


                if (pc !== expected_next_pc) begin

                    fail_count =
                        fail_count + 1;


                    $display(
                        "FAIL | PC MISMATCH | RETIRE #%0d DUT=%0d REF=%0d",
                        retire_count,
                        pc,
                        expected_next_pc
                    );

                end

            end

        end

    endtask


    // ========================================================
    // CHECK LEGAL RANDOM OPCODE
    // ========================================================

    task automatic check_random_opcode;

        begin

            case (ref_opcode)

                4'b0000,
                4'b0001,
                4'b0010,
                4'b0011,
                4'b0100,
                4'b0101,
                4'b0110,
                4'b0111,
                4'b1100,
                4'b1111: begin

                    // Legal for this generated test.

                end


                default: begin

                    fail_count =
                        fail_count + 1;


                    $display(
                        "FAIL | ILLEGAL OPCODE FOR RANDOM TEST | PC=%0d OP=%b",
                        retiring_pc,
                        ref_opcode
                    );

                end

            endcase

        end

    endtask


    // ========================================================
    // PROCESS ONE RETIREMENT
    // ========================================================

    task automatic process_retirement;

        begin

            retire_count =
                retire_count + 1;


            decode_reference_instruction();


            record_opcode_hit();


            check_random_opcode();


            // -------------------------------------------------
            // Update expected architecture.
            // -------------------------------------------------

            execute_reference_instruction();


            // -------------------------------------------------
            // Compare real CPU against expected architecture.
            // -------------------------------------------------

            scoreboard_check();


            // -------------------------------------------------
            // PC checking.
            //
            // HALT is excluded because HALT keeps PC stable.
            // -------------------------------------------------

            check_next_pc();

        end

    endtask


    // ========================================================
    // RETIREMENT MONITOR
    // ========================================================

    initial begin

        retire_count = 0;


        forever begin

            @(posedge clk);


            if (!reset) begin

                // =================================================
                // NORMAL INSTRUCTION RETIREMENT
                // =================================================

                if (dut.writeback_state) begin

                    // Save identity before PC/register NBA changes.

                    retiring_pc =
                        pc;


                    retiring_instruction =
                        dut.current_instruction;


                    // Allow architectural state updates.
                    #1;


                    process_retirement();

                end


                // =================================================
                // HALT RETIREMENT
                //
                // HALT does not go through WRITEBACK.
                // =================================================

                else if (
                    dut.decode_state &&
                    dut.halt_req
                ) begin

                    retiring_pc =
                        pc;


                    retiring_instruction =
                        dut.current_instruction;


                    // Allow DECODE -> HALT transition.
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


        nop_hits  = 0;
        ldi_hits  = 0;
        mov_hits  = 0;
        add_hits  = 0;
        sub_hits  = 0;
        and_hits  = 0;
        or_hits   = 0;
        xor_hits  = 0;
        cmp_hits  = 0;
        halt_hits = 0;


        initialise_reference_model();


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - RANDOM CPU SCOREBOARD");
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
            timeout_cycles < 200
        ) begin

            @(posedge clk);


            timeout_cycles =
                timeout_cycles + 1;

        end


        // Allow HALT retirement scoreboard event to complete.
        #5;


        // ====================================================
        // FINAL STRUCTURAL CHECKS
        // ====================================================


        // ----------------------------------------------------
        // CPU must halt.
        // ----------------------------------------------------

        if (halted !== 1'b1) begin

            fail_count =
                fail_count + 1;


            $display(
                "FAIL | CPU did not reach HALT"
            );

        end


        // ----------------------------------------------------
        // 34 total instructions.
        // ----------------------------------------------------

        if (retire_count != 34) begin

            fail_count =
                fail_count + 1;


            $display(
                "FAIL | RETIRE COUNT actual=%0d expected=34",
                retire_count
            );

        end


        // ----------------------------------------------------
        // One HALT only.
        // ----------------------------------------------------

        if (halt_hits != 1) begin

            fail_count =
                fail_count + 1;


            $display(
                "FAIL | HALT count actual=%0d expected=1",
                halt_hits
            );

        end


        // ----------------------------------------------------
        // Final PC should be 33.
        // ----------------------------------------------------

        if (pc !== 8'd33) begin

            fail_count =
                fail_count + 1;


            $display(
                "FAIL | FINAL PC actual=%0d expected=33",
                pc
            );

        end


        // ----------------------------------------------------
        // Final FSM state = HALT = 4.
        // ----------------------------------------------------

        if (state !== 3'd4) begin

            fail_count =
                fail_count + 1;


            $display(
                "FAIL | FINAL STATE actual=%0d expected=4",
                state
            );

        end


        // ====================================================
        // FINAL REPORT
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" RANDOM ARCHITECTURAL SCOREBOARD SUMMARY");
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
        $display("INSTRUCTION HITS:");

        $display(
            "NOP  = %0d",
            nop_hits
        );

        $display(
            "LDI  = %0d",
            ldi_hits
        );

        $display(
            "MOV  = %0d",
            mov_hits
        );

        $display(
            "ADD  = %0d",
            add_hits
        );

        $display(
            "SUB  = %0d",
            sub_hits
        );

        $display(
            "AND  = %0d",
            and_hits
        );

        $display(
            "OR   = %0d",
            or_hits
        );

        $display(
            "XOR  = %0d",
            xor_hits
        );

        $display(
            "CMP  = %0d",
            cmp_hits
        );

        $display(
            "HALT = %0d",
            halt_hits
        );


        $display("");
        $display("FINAL DUT REGISTERS:");

        $display(
            "R0=%0d R1=%0d R2=%0d R3=%0d",
            dut.u_regfile.registers[0],
            dut.u_regfile.registers[1],
            dut.u_regfile.registers[2],
            dut.u_regfile.registers[3]
        );

        $display(
            "R4=%0d R5=%0d R6=%0d R7=%0d",
            dut.u_regfile.registers[4],
            dut.u_regfile.registers[5],
            dut.u_regfile.registers[6],
            dut.u_regfile.registers[7]
        );


        $display("");
        $display("FINAL REF REGISTERS:");

        $display(
            "R0=%0d R1=%0d R2=%0d R3=%0d",
            ref_regs[0],
            ref_regs[1],
            ref_regs[2],
            ref_regs[3]
        );

        $display(
            "R4=%0d R5=%0d R6=%0d R7=%0d",
            ref_regs[4],
            ref_regs[5],
            ref_regs[6],
            ref_regs[7]
        );


        $display("");

        $display(
            "FLAGS DUT Z=%b C=%b | REF Z=%b C=%b",
            zero,
            carry,
            ref_zero,
            ref_carry
        );


        $display(
            "Final PC    = %0d",
            pc
        );


        $display(
            "Final State = %0d",
            state
        );


        // ====================================================
        // RESULT
        // ====================================================

        if (
            fail_count == 0 &&
            retire_count == 34 &&
            pass_count == 34
        ) begin

            $display("");
            $display(
                "RANDOM ARCHITECTURAL SCOREBOARD: PASS"
            );

        end


        else begin

            $display("");
            $display(
                "RANDOM ARCHITECTURAL SCOREBOARD: FAIL"
            );

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule