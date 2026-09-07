`timescale 1ns/1ps

module minirisc_reference_model_tb;

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

    integer retired_count;
    integer timeout_cycles;

    integer i;


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
    // DECODE RETIRED INSTRUCTION
    // ========================================================

    task automatic decode_reference_instruction;

        begin

            // Decode directly from the 16-bit instruction.
            //
            // We deliberately do NOT use dut.opcode/dut.rd/etc.
            // This keeps the reference model more independent
            // from the DUT decoder.

            ref_opcode    = retiring_instruction[15:12];
            ref_rd        = retiring_instruction[11:9];
            ref_rs        = retiring_instruction[8:6];
            ref_immediate = retiring_instruction[7:0];

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

                    // No architectural state change.

                end


                // =================================================
                // LDI Rd, immediate
                // =================================================

                4'b0001: begin

                    ref_regs[ref_rd] = ref_immediate;

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
                // SUB Rd, Rs
                // =================================================

                4'b0100: begin

                    alu_result =
                        ref_regs[ref_rd] -
                        ref_regs[ref_rs];

                    ref_regs[ref_rd] =
                        alu_result;

                    ref_zero =
                        (alu_result == 8'd0);

                    // Current MiniRISC ALU behavior:
                    // Carry is only generated by ADD.
                    ref_carry = 1'b0;

                end


                // =================================================
                // AND Rd, Rs
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
                // OR Rd, Rs
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
                // XOR Rd, Rs
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
                // LOAD Rd, address
                // =================================================

                4'b1000: begin

                    ref_regs[ref_rd] =
                        ref_mem[ref_immediate];

                end


                // =================================================
                // STORE Rd, address
                // =================================================

                4'b1001: begin

                    ref_mem[ref_immediate] =
                        ref_regs[ref_rd];

                end


                // =================================================
                // JMP
                // =================================================

                4'b1010: begin

                    // PC behavior handled separately in Step 6.

                end


                // =================================================
                // JZ
                // =================================================

                4'b1011: begin

                    // PC behavior handled separately in Step 6.

                end


                // =================================================
                // CMP Rd, Rs
                //
                // SUBTRACT FOR FLAGS ONLY.
                // Register file must NOT change.
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

                    // No architectural effect.

                end


                4'b1110: begin

                    // No architectural effect.

                end


                // =================================================
                // HALT
                // =================================================

                4'b1111: begin

                    // No register/memory/flag change.

                end


                default: begin

                    // No architectural effect.

                end

            endcase

        end

    endtask


    // ========================================================
    // PRINT REFERENCE STATE
    // ========================================================

    task automatic print_reference_state;

        begin

            $display(
                "REF REGS | R0=%0d R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d R6=%0d R7=%0d",
                ref_regs[0],
                ref_regs[1],
                ref_regs[2],
                ref_regs[3],
                ref_regs[4],
                ref_regs[5],
                ref_regs[6],
                ref_regs[7]
            );


            $display(
                "REF FLAGS | Z=%b C=%b",
                ref_zero,
                ref_carry
            );

        end

    endtask


    // ========================================================
    // PROCESS ONE RETIRED INSTRUCTION
    // ========================================================

    task automatic process_retirement;

        begin

            decode_reference_instruction();

            retired_count = retired_count + 1;


            $display("");
            $display(
                "REFERENCE #%0d | PC=%0d | %-5s | INSTR=%b",
                retired_count,
                retiring_pc,
                opcode_name(ref_opcode),
                retiring_instruction
            );


            execute_reference_instruction();


            if (ref_opcode == 4'b1001) begin

                $display(
                    "REF MEMORY | MEM[%0d]=%0d",
                    ref_immediate,
                    ref_mem[ref_immediate]
                );

            end


            print_reference_state();

        end

    endtask


    // ========================================================
    // RETIREMENT TRACKER
    // ========================================================

    initial begin

        retired_count = 0;


        forever begin

            @(posedge clk);


            if (!reset) begin

                // =================================================
                // NORMAL WRITEBACK RETIREMENT
                // =================================================

                if (dut.writeback_state) begin

                    retiring_pc          = pc;
                    retiring_instruction = dut.current_instruction;


                    // Wait for DUT architectural updates.
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

                    retiring_pc          = pc;
                    retiring_instruction = dut.current_instruction;


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

        timeout_cycles = 0;


        initialise_reference_model();


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - CPU REFERENCE MODEL");
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

            timeout_cycles = timeout_cycles + 1;

        end


        // Allow HALT retirement processing.
        #5;


        // ====================================================
        // VALIDATE REFERENCE MODEL AGAINST PROGRAM SPEC
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" REFERENCE MODEL FINAL CHECK");
        $display("==============================================");


        // ----------------------------------------------------
        // R1
        // ----------------------------------------------------

        assert (ref_regs[1] === 8'd0)

        else
            $error(
                "REFERENCE R1 FAILED | expected=0 actual=%0d",
                ref_regs[1]
            );


        // ----------------------------------------------------
        // R2
        // ----------------------------------------------------

        assert (ref_regs[2] === 8'd5)

        else
            $error(
                "REFERENCE R2 FAILED | expected=5 actual=%0d",
                ref_regs[2]
            );


        // ----------------------------------------------------
        // R3
        // ----------------------------------------------------

        assert (ref_regs[3] === 8'd7)

        else
            $error(
                "REFERENCE R3 FAILED | expected=7 actual=%0d",
                ref_regs[3]
            );


        // ----------------------------------------------------
        // R4
        // ----------------------------------------------------

        assert (ref_regs[4] === 8'd42)

        else
            $error(
                "REFERENCE R4 FAILED | expected=42 actual=%0d",
                ref_regs[4]
            );


        // ----------------------------------------------------
        // R5
        // ----------------------------------------------------

        assert (ref_regs[5] === 8'd42)

        else
            $error(
                "REFERENCE R5 FAILED | expected=42 actual=%0d",
                ref_regs[5]
            );


        // ----------------------------------------------------
        // MEMORY
        // ----------------------------------------------------

        assert (ref_mem[20] === 8'd42)

        else
            $error(
                "REFERENCE MEMORY FAILED | expected=42 actual=%0d",
                ref_mem[20]
            );


        // ----------------------------------------------------
        // FLAGS
        // ----------------------------------------------------

        assert (ref_zero === 1'b1)

        else
            $error(
                "REFERENCE ZERO FLAG FAILED | expected=1 actual=%b",
                ref_zero
            );


        assert (ref_carry === 1'b0)

        else
            $error(
                "REFERENCE CARRY FLAG FAILED | expected=0 actual=%b",
                ref_carry
            );


        // ----------------------------------------------------
        // RETIREMENT COUNT
        // ----------------------------------------------------

        assert (retired_count == 12)

        else
            $error(
                "REFERENCE RETIREMENT COUNT FAILED | expected=12 actual=%0d",
                retired_count
            );


        // ====================================================
        // FINAL REPORT
        // ====================================================

        $display("");
        $display("REFERENCE FINAL STATE:");

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

        $display(
            "Memory[20] = %0d",
            ref_mem[20]
        );

        $display(
            "Zero       = %b",
            ref_zero
        );

        $display(
            "Carry      = %b",
            ref_carry
        );

        $display(
            "Retirements = %0d",
            retired_count
        );


        $display("");
        $display("CPU REFERENCE MODEL: PASS");

        $display("==============================================");
        $display("");

        $finish;

    end

endmodule