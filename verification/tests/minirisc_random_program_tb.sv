`timescale 1ns/1ps

module minirisc_random_program_tb;

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
    // STATISTICS
    // ========================================================

    integer normal_retirements;
    integer halt_retirements;
    integer total_retirements;

    integer timeout_cycles;
    integer failures;

    logic halt_seen;


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
        input logic [3:0] opcode
    );

        begin

            case (opcode)

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
    // RETIREMENT MONITOR
    // ========================================================

    initial begin

        normal_retirements = 0;
        halt_retirements   = 0;
        total_retirements  = 0;

        halt_seen = 1'b0;


        forever begin

            @(posedge clk);


            if (!reset) begin

                // =================================================
                // NORMAL INSTRUCTION RETIREMENT
                // =================================================

                if (dut.writeback_state) begin

                    // Save values before PC advances.
                    $display(
                        "RETIRE #%0d | PC=%0d | %-5s | INSTR=%b",
                        total_retirements + 1,
                        pc,
                        opcode_name(
                            dut.current_instruction[15:12]
                        ),
                        dut.current_instruction
                    );


                    normal_retirements =
                        normal_retirements + 1;


                    total_retirements =
                        total_retirements + 1;

                end


                // =================================================
                // HALT RETIREMENT
                // =================================================

                else if (
                    dut.decode_state &&
                    dut.halt_req &&
                    !halt_seen
                ) begin

                    halt_seen = 1'b1;


                    // Allow FSM to enter HALT.
                    #1;


                    halt_retirements =
                        halt_retirements + 1;


                    total_retirements =
                        total_retirements + 1;


                    $display(
                        "RETIRE #%0d | PC=%0d | HALT  | INSTR=%b",
                        total_retirements,
                        pc,
                        dut.current_instruction
                    );

                end

            end

        end

    end


    // ========================================================
    // MAIN TEST
    // ========================================================

    initial begin

        reset = 1'b1;

        failures      = 0;
        timeout_cycles = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - RANDOM CPU PROGRAM");
        $display("==============================================");
        $display("");


        // ====================================================
        // RESET
        // ====================================================

        repeat (2)
            @(posedge clk);


        reset = 1'b0;


        // ====================================================
        // RUN PROGRAM
        // ====================================================

        while (
            halted !== 1'b1 &&
            timeout_cycles < 200
        ) begin

            @(posedge clk);

            timeout_cycles =
                timeout_cycles + 1;

        end


        // Allow HALT tracker to finish.
        #5;


        // ====================================================
        // TIMEOUT CHECK
        // ====================================================

        if (halted !== 1'b1) begin

            failures =
                failures + 1;


            $display(
                "FAIL | CPU did not reach HALT before timeout"
            );

        end


        // ====================================================
        // RETIREMENT COUNT
        //
        // 8 initial LDI
        // +25 random
        // +1 HALT
        // =34
        // ====================================================

        if (total_retirements != 34) begin

            failures =
                failures + 1;


            $display(
                "FAIL | Total retirements actual=%0d expected=34",
                total_retirements
            );

        end


        if (normal_retirements != 33) begin

            failures =
                failures + 1;


            $display(
                "FAIL | Normal retirements actual=%0d expected=33",
                normal_retirements
            );

        end


        if (halt_retirements != 1) begin

            failures =
                failures + 1;


            $display(
                "FAIL | HALT retirements actual=%0d expected=1",
                halt_retirements
            );

        end


        // ====================================================
        // FINAL PC
        //
        // HALT is instruction 33.
        // HALT does not increment PC.
        // ====================================================

        if (pc !== 8'd33) begin

            failures =
                failures + 1;


            $display(
                "FAIL | Final PC actual=%0d expected=33",
                pc
            );

        end


        // ====================================================
        // FINAL FSM STATE
        // ====================================================

        if (state !== 3'd4) begin

            failures =
                failures + 1;


            $display(
                "FAIL | Final FSM state actual=%0d expected=4",
                state
            );

        end


        // ====================================================
        // UNKNOWN STATE CHECK
        // ====================================================

        if (
            $isunknown(pc)     ||
            $isunknown(state)  ||
            $isunknown(zero)   ||
            $isunknown(carry)  ||
            $isunknown(halted)
        ) begin

            failures =
                failures + 1;


            $display(
                "FAIL | Unknown X/Z detected in final CPU state"
            );

        end


        // ====================================================
        // SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" RANDOM CPU EXECUTION SUMMARY");
        $display("==============================================");

        $display(
            "Normal retirements = %0d",
            normal_retirements
        );

        $display(
            "HALT retirements   = %0d",
            halt_retirements
        );

        $display(
            "Total retirements  = %0d",
            total_retirements
        );

        $display(
            "Final PC           = %0d",
            pc
        );

        $display(
            "Final state        = %0d",
            state
        );

        $display(
            "Zero               = %b",
            zero
        );

        $display(
            "Carry              = %b",
            carry
        );

        $display(
            "Failures           = %0d",
            failures
        );


        $display("");
        $display("FINAL REGISTERS:");

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


        if (failures == 0) begin

            $display("");
            $display(
                "RANDOM CPU PROGRAM EXECUTION: PASS"
            );

        end

        else begin

            $display("");
            $display(
                "RANDOM CPU PROGRAM EXECUTION: FAIL"
            );

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule