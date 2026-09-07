`timescale 1ns/1ps

module minirisc_cpu_monitor_tb;

    // ========================================================
    // SIGNALS
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
    // MONITOR STATE
    // ========================================================

    integer retired_count;
    integer timeout_cycles;

    logic halt_seen;

    logic [7:0]  saved_pc;
    logic [15:0] saved_instruction;

    logic [3:0] saved_opcode;
    logic [2:0] saved_rd;
    logic [2:0] saved_rs;
    logic [7:0] saved_immediate;


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
    // PRINT ARCHITECTURAL STATE
    // ========================================================

    task automatic print_architectural_state;

        begin

            $display(
                "          REGS | R0=%0d R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d R6=%0d R7=%0d",
                dut.u_regfile.registers[0],
                dut.u_regfile.registers[1],
                dut.u_regfile.registers[2],
                dut.u_regfile.registers[3],
                dut.u_regfile.registers[4],
                dut.u_regfile.registers[5],
                dut.u_regfile.registers[6],
                dut.u_regfile.registers[7]
            );

            $display(
                "          FLAGS | Z=%b C=%b",
                zero,
                carry
            );

        end

    endtask


    // ========================================================
    // PRINT RETIRED INSTRUCTION
    // ========================================================

    task automatic print_retirement;

        begin

            $display("");
            $display(
                "RETIRE #%0d | PC=%0d | %-5s | INSTR=%b",
                retired_count,
                saved_pc,
                opcode_name(saved_opcode),
                saved_instruction
            );


            $display(
                "          DECODE | Rd=R%0d Rs=R%0d IMM=%0d",
                saved_rd,
                saved_rs,
                saved_immediate
            );


            // ------------------------------------------------
            // Extra information for STORE
            // ------------------------------------------------

            if (saved_opcode == 4'b1001) begin

                $display(
                    "          MEMORY | MEM[%0d]=%0d",
                    saved_immediate,
                    dut.u_dmem.memory[saved_immediate]
                );

            end


            // ------------------------------------------------
            // Extra information for LOAD
            // ------------------------------------------------

            if (saved_opcode == 4'b1000) begin

                $display(
                    "          LOAD | R%0d=%0d FROM MEM[%0d]",
                    saved_rd,
                    dut.u_regfile.registers[saved_rd],
                    saved_immediate
                );

            end


            print_architectural_state();

        end

    endtask


    // ========================================================
    // RETIREMENT MONITOR
    // ========================================================
    //
    // IMPORTANT:
    //
    // At the rising edge where the OLD state is WRITEBACK:
    //
    // - register write occurs
    // - PC update occurs
    // - FSM transitions back to FETCH
    //
    // We therefore:
    //
    // 1. Save instruction/PC before NBA updates.
    // 2. Wait #1.
    // 3. Observe the updated architectural state.
    // ========================================================

    initial begin

        retired_count = 0;
        halt_seen     = 1'b0;


        forever begin

            @(posedge clk);


            if (reset) begin

                halt_seen = 1'b0;

            end


            else begin

                // =================================================
                // NORMAL INSTRUCTION RETIREMENT
                // =================================================

                if (dut.writeback_state) begin

                    // Save identity of instruction being retired.
                    saved_pc          = pc;
                    saved_instruction = dut.current_instruction;

                    saved_opcode      = dut.opcode;
                    saved_rd          = dut.rd;
                    saved_rs          = dut.rs;
                    saved_immediate   = dut.immediate;


                    // Allow register/PC non-blocking updates.
                    #1;


                    retired_count = retired_count + 1;


                    print_retirement();

                end


                // =================================================
                // HALT DETECTION
                // =================================================

                else begin

                    // Allow FSM state update to complete.
                    #1;


                    if (
                        halted === 1'b1 &&
                        halt_seen === 1'b0
                    ) begin

                        halt_seen = 1'b1;

                        $display("");
                        $display("==============================================");
                        $display(
                            "HALT DETECTED | PC=%0d | INSTR=%b",
                            pc,
                            dut.current_instruction
                        );

                        $display(
                            "              | OPCODE=%s",
                            opcode_name(dut.opcode)
                        );

                        print_architectural_state();

                        $display("==============================================");

                    end

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


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - WHOLE CPU RETIREMENT MONITOR");
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


        // Give monitor process time to print HALT.
        #5;


        // ====================================================
        // FINAL SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" CPU MONITOR SUMMARY");
        $display("==============================================");

        $display(
            "Retired non-HALT instructions = %0d",
            retired_count
        );

        $display(
            "Final PC                      = %0d",
            pc
        );

        $display(
            "Final State                   = %0d",
            state
        );

        $display(
            "Halted                        = %b",
            halted
        );


        $display("");
        $display("FINAL REGISTER STATE:");

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


        $display(
            "Memory[20]                    = %0d",
            dut.u_dmem.memory[20]
        );


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule