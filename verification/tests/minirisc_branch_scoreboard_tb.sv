`timescale 1ns/1ps


// ============================================================
// REUSABLE BRANCH CASE CHECKER
// ============================================================

module branch_case_checker #(
    parameter PROGRAM_FILE = "programs/branch_test.mem",
    parameter CASE_NAME    = "BRANCH CASE"
)(
    input logic clk,
    input logic reset,

    output logic done,

    output integer failures,
    output integer retire_count,

    output integer jmp_hits,
    output integer jz_taken_hits,
    output integer jz_not_taken_hits
);

    // ========================================================
    // CPU SIGNALS
    // ========================================================

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

    logic [7:0] ref_pc;


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

    integer timeout_cycles;


    // ========================================================
    // DUT
    // ========================================================

    minirisc_cpu #(
        .PROGRAM_FILE(PROGRAM_FILE)
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
    // INITIALISE REFERENCE STATE
    // ========================================================

    task automatic initialise_reference;

        integer i;

        begin

            for (i = 0; i < 8; i = i + 1)
                ref_regs[i] = 8'd0;

            ref_zero  = 1'b0;
            ref_carry = 1'b0;

            ref_pc = 8'd0;

        end

    endtask


    // ========================================================
    // DECODE RETIRED INSTRUCTION
    // ========================================================

    task automatic decode_instruction;

        begin

            // Decode directly from instruction bits.
            //
            // This avoids relying on the DUT decoder outputs.

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
    // CHECK RETIRING PC
    // ========================================================

    task automatic check_retiring_pc;

        begin

            if (retiring_pc !== ref_pc) begin

                failures = failures + 1;

                $display(
                    "FAIL | %-14s | RETIRE #%0d | PC DUT=%0d REF=%0d",
                    CASE_NAME,
                    retire_count,
                    retiring_pc,
                    ref_pc
                );

            end

        end

    endtask


    // ========================================================
    // EXECUTE REFERENCE INSTRUCTION
    // ========================================================

    task automatic execute_reference;

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
                //
                // Not needed by these branch programs.
                // =================================================

                4'b1000: begin

                end


                // =================================================
                // STORE
                //
                // Not needed by these branch programs.
                // =================================================

                4'b1001: begin

                end


                // =================================================
                // JMP
                //
                // PC handled separately.
                // =================================================

                4'b1010: begin

                end


                // =================================================
                // JZ
                //
                // PC handled separately.
                // =================================================

                4'b1011: begin

                end


                // =================================================
                // CMP
                //
                // Flags only.
                // No register write.
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
    // PREDICT NEXT PC
    // ========================================================

    task automatic predict_next_pc;

        begin

            case (ref_opcode)

                // =================================================
                // JMP
                // =================================================

                4'b1010: begin

                    ref_pc =
                        ref_immediate;


                    jmp_hits =
                        jmp_hits + 1;


                    $display(
                        "      JMP TAKEN       | target=%0d",
                        ref_immediate
                    );

                end


                // =================================================
                // JZ
                // =================================================

                4'b1011: begin

                    if (ref_zero == 1'b1) begin

                        ref_pc =
                            ref_immediate;


                        jz_taken_hits =
                            jz_taken_hits + 1;


                        $display(
                            "      JZ TAKEN        | target=%0d",
                            ref_immediate
                        );

                    end


                    else begin

                        ref_pc =
                            retiring_pc + 8'd1;


                        jz_not_taken_hits =
                            jz_not_taken_hits + 1;


                        $display(
                            "      JZ NOT TAKEN    | next=%0d",
                            ref_pc
                        );

                    end

                end


                // =================================================
                // NORMAL SEQUENTIAL INSTRUCTION
                // =================================================

                default: begin

                    ref_pc =
                        retiring_pc + 8'd1;

                end

            endcase

        end

    endtask


    // ========================================================
    // CHECK REGISTER STATE
    //
    // Useful because the branch programs also write R1/R2/R3.
    // ========================================================

    task automatic check_registers;

        integer r;

        begin

            for (r = 0; r < 8; r = r + 1) begin

                if (
                    dut.u_regfile.registers[r]
                    !==
                    ref_regs[r]
                ) begin

                    failures =
                        failures + 1;


                    $display(
                        "FAIL | %-14s | R%0d DUT=%0d REF=%0d",
                        CASE_NAME,
                        r,
                        dut.u_regfile.registers[r],
                        ref_regs[r]
                    );

                end

            end

        end

    endtask


    // ========================================================
    // PROCESS NORMAL RETIREMENT
    // ========================================================

    task automatic process_normal_retirement;

        begin

            retire_count =
                retire_count + 1;


            decode_instruction();


            $display("");
            $display(
                "RETIRE #%0d | %-14s | PC=%0d | %-5s",
                retire_count,
                CASE_NAME,
                retiring_pc,
                opcode_name(ref_opcode)
            );


            // =================================================
            // CHECK INSTRUCTION PC
            // =================================================

            check_retiring_pc();


            // =================================================
            // UPDATE REFERENCE ARCHITECTURE
            // =================================================

            execute_reference();


            // =================================================
            // CHECK REGISTER / FLAG STATE
            // =================================================

            check_registers();


            if (zero !== ref_zero) begin

                failures =
                    failures + 1;


                $display(
                    "FAIL | %-14s | ZERO DUT=%b REF=%b",
                    CASE_NAME,
                    zero,
                    ref_zero
                );

            end


            if (carry !== ref_carry) begin

                failures =
                    failures + 1;


                $display(
                    "FAIL | %-14s | CARRY DUT=%b REF=%b",
                    CASE_NAME,
                    carry,
                    ref_carry
                );

            end


            // =================================================
            // PREDICT NEXT PC
            // =================================================

            predict_next_pc();


            // =================================================
            // COMPARE ACTUAL NEXT PC
            // =================================================

            if (pc !== ref_pc) begin

                failures =
                    failures + 1;


                $display(
                    "FAIL | %-14s | NEXT PC DUT=%0d REF=%0d",
                    CASE_NAME,
                    pc,
                    ref_pc
                );

            end


            else begin

                $display(
                    "      PC MATCH         | DUT=%0d REF=%0d",
                    pc,
                    ref_pc
                );

            end

        end

    endtask


    // ========================================================
    // PROCESS HALT RETIREMENT
    // ========================================================

    task automatic process_halt_retirement;

        begin

            retire_count =
                retire_count + 1;


            decode_instruction();


            $display("");
            $display(
                "RETIRE #%0d | %-14s | PC=%0d | HALT",
                retire_count,
                CASE_NAME,
                retiring_pc
            );


            // =================================================
            // EXPECTED INSTRUCTION PC
            // =================================================

            check_retiring_pc();


            // =================================================
            // OPCODE MUST BE HALT
            // =================================================

            if (ref_opcode !== 4'b1111) begin

                failures =
                    failures + 1;


                $display(
                    "FAIL | %-14s | HALT opcode incorrect: %b",
                    CASE_NAME,
                    ref_opcode
                );

            end


            // =================================================
            // HALT MUST NOT ADVANCE PC
            // =================================================

            if (pc !== retiring_pc) begin

                failures =
                    failures + 1;


                $display(
                    "FAIL | %-14s | HALT changed PC DUT=%0d EXPECTED=%0d",
                    CASE_NAME,
                    pc,
                    retiring_pc
                );

            end


            // =================================================
            // CPU MUST ENTER HALT
            // =================================================

            if (halted !== 1'b1) begin

                failures =
                    failures + 1;


                $display(
                    "FAIL | %-14s | halted should be 1",
                    CASE_NAME
                );

            end


            else begin

                $display(
                    "      HALT CONFIRMED    | PC=%0d",
                    pc
                );

            end


            done = 1'b1;

        end

    endtask


    // ========================================================
    // RETIREMENT MONITOR
    // ========================================================

    initial begin

        forever begin

            @(posedge clk);


            if (
                !reset &&
                !done
            ) begin

                // =================================================
                // NORMAL RETIREMENT
                // =================================================

                if (dut.writeback_state) begin

                    retiring_pc =
                        pc;


                    retiring_instruction =
                        dut.current_instruction;


                    // Allow architectural state / PC updates.
                    #1;


                    process_normal_retirement();

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


                    // Allow DECODE -> HALT transition.
                    #1;


                    process_halt_retirement();

                end

            end

        end

    end


    // ========================================================
    // INITIAL / TIMEOUT PROCESS
    // ========================================================

    initial begin

        done = 1'b0;

        failures     = 0;
        retire_count = 0;

        jmp_hits          = 0;
        jz_taken_hits     = 0;
        jz_not_taken_hits = 0;

        timeout_cycles = 0;


        initialise_reference();


        // Wait until shared reset is released.
        wait (reset === 1'b0);


        while (
            done !== 1'b1 &&
            timeout_cycles < 100
        ) begin

            @(posedge clk);

            timeout_cycles =
                timeout_cycles + 1;

        end


        if (done !== 1'b1) begin

            failures =
                failures + 1;


            done =
                1'b1;


            $display(
                "FAIL | %-14s | TIMEOUT",
                CASE_NAME
            );

        end

    end

endmodule



// ============================================================
// TOP-LEVEL BRANCH / PC SCOREBOARD
// ============================================================

module minirisc_branch_scoreboard_tb;

    logic clk;
    logic reset;


    // ========================================================
    // CASE 1 RESULTS
    //
    // JZ NOT TAKEN + JMP
    // ========================================================

    logic nt_done;

    integer nt_failures;
    integer nt_retire_count;

    integer nt_jmp_hits;
    integer nt_jz_taken_hits;
    integer nt_jz_not_taken_hits;


    // ========================================================
    // CASE 2 RESULTS
    //
    // JZ TAKEN
    // ========================================================

    logic taken_done;

    integer taken_failures;
    integer taken_retire_count;

    integer taken_jmp_hits;
    integer taken_jz_taken_hits;
    integer taken_jz_not_taken_hits;


    // ========================================================
    // TOP-LEVEL CHECK FAILURES
    //
    // IMPORTANT:
    //
    // We do NOT modify nt_failures or taken_failures here.
    //
    // Those variables are driven by the child checker modules.
    // ========================================================

    integer top_failures;


    // ========================================================
    // CLOCK
    // ========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ========================================================
    // CASE 1
    //
    // branch_test.mem
    //
    // 0 LDI R1,5
    // 1 LDI R2,4
    // 2 CMP R1,R2       -> Z=0
    // 3 JZ 6            -> NOT TAKEN
    // 4 LDI R3,99
    // 5 JMP 7           -> TAKEN
    // 7 HALT
    //
    // Expected retired PCs:
    //
    // 0,1,2,3,4,5,7
    // ========================================================

    branch_case_checker #(
        .PROGRAM_FILE(
            "programs/branch_test.mem"
        ),

        .CASE_NAME(
            "JZ NOT TAKEN"
        )
    ) not_taken_case (

        .clk(clk),
        .reset(reset),

        .done(nt_done),

        .failures(nt_failures),
        .retire_count(nt_retire_count),

        .jmp_hits(nt_jmp_hits),

        .jz_taken_hits(
            nt_jz_taken_hits
        ),

        .jz_not_taken_hits(
            nt_jz_not_taken_hits
        )
    );


    // ========================================================
    // CASE 2
    //
    // jz_taken_test.mem
    //
    // 0 LDI R1,5
    // 1 LDI R2,5
    // 2 CMP R1,R2       -> Z=1
    // 3 JZ 6            -> TAKEN
    // 6 LDI R3,42
    // 7 HALT
    //
    // Expected retired PCs:
    //
    // 0,1,2,3,6,7
    // ========================================================

    branch_case_checker #(
        .PROGRAM_FILE(
            "programs/jz_taken_test.mem"
        ),

        .CASE_NAME(
            "JZ TAKEN"
        )
    ) taken_case (

        .clk(clk),
        .reset(reset),

        .done(taken_done),

        .failures(taken_failures),
        .retire_count(taken_retire_count),

        .jmp_hits(taken_jmp_hits),

        .jz_taken_hits(
            taken_jz_taken_hits
        ),

        .jz_not_taken_hits(
            taken_jz_not_taken_hits
        )
    );


    // ========================================================
    // MAIN TEST
    // ========================================================

    initial begin

        reset =
            1'b1;


        top_failures =
            0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - BRANCH / PC SCOREBOARD");
        $display("==============================================");
        $display("");


        // ====================================================
        // RESET BOTH CPUs
        // ====================================================

        repeat (2)
            @(posedge clk);


        reset =
            1'b0;


        // ====================================================
        // WAIT FOR BOTH PROGRAMS
        // ====================================================

        wait (
            nt_done === 1'b1 &&
            taken_done === 1'b1
        );


        #5;


        // ====================================================
        // TOP-LEVEL EXPECTED-PATH CHECKS
        // ====================================================


        // ----------------------------------------------------
        // NOT-TAKEN CASE:
        // one JZ NOT TAKEN
        // ----------------------------------------------------

        if (nt_jz_not_taken_hits != 1) begin

            top_failures =
                top_failures + 1;


            $display(
                "FAIL | NOT-TAKEN program should exercise exactly one JZ not taken"
            );

        end


        // ----------------------------------------------------
        // NOT-TAKEN CASE:
        // zero JZ TAKEN
        // ----------------------------------------------------

        if (nt_jz_taken_hits != 0) begin

            top_failures =
                top_failures + 1;


            $display(
                "FAIL | NOT-TAKEN program unexpectedly exercised JZ taken"
            );

        end


        // ----------------------------------------------------
        // NOT-TAKEN CASE:
        // one JMP
        // ----------------------------------------------------

        if (nt_jmp_hits != 1) begin

            top_failures =
                top_failures + 1;


            $display(
                "FAIL | NOT-TAKEN program should exercise exactly one JMP"
            );

        end


        // ----------------------------------------------------
        // NOT-TAKEN expected retirements = 7
        // ----------------------------------------------------

        if (nt_retire_count != 7) begin

            top_failures =
                top_failures + 1;


            $display(
                "FAIL | NOT-TAKEN retire count DUT=%0d EXPECTED=7",
                nt_retire_count
            );

        end


        // ----------------------------------------------------
        // TAKEN CASE:
        // one JZ TAKEN
        // ----------------------------------------------------

        if (taken_jz_taken_hits != 1) begin

            top_failures =
                top_failures + 1;


            $display(
                "FAIL | TAKEN program should exercise exactly one JZ taken"
            );

        end


        // ----------------------------------------------------
        // TAKEN CASE:
        // zero JZ NOT TAKEN
        // ----------------------------------------------------

        if (taken_jz_not_taken_hits != 0) begin

            top_failures =
                top_failures + 1;


            $display(
                "FAIL | TAKEN program unexpectedly exercised JZ not taken"
            );

        end


        // ----------------------------------------------------
        // TAKEN program has no executed JMP
        // ----------------------------------------------------

        if (taken_jmp_hits != 0) begin

            top_failures =
                top_failures + 1;


            $display(
                "FAIL | TAKEN program unexpectedly executed JMP"
            );

        end


        // ----------------------------------------------------
        // TAKEN expected retirements = 6
        // ----------------------------------------------------

        if (taken_retire_count != 6) begin

            top_failures =
                top_failures + 1;


            $display(
                "FAIL | TAKEN retire count DUT=%0d EXPECTED=6",
                taken_retire_count
            );

        end


        // ====================================================
        // FINAL SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" BRANCH / PC SCOREBOARD SUMMARY");
        $display("==============================================");


        $display("");
        $display("CASE 1 - JZ NOT TAKEN + JMP");

        $display(
            "Retirements       = %0d",
            nt_retire_count
        );

        $display(
            "JZ not taken hits = %0d",
            nt_jz_not_taken_hits
        );

        $display(
            "JZ taken hits     = %0d",
            nt_jz_taken_hits
        );

        $display(
            "JMP hits          = %0d",
            nt_jmp_hits
        );

        $display(
            "Child failures    = %0d",
            nt_failures
        );


        $display("");
        $display("CASE 2 - JZ TAKEN");

        $display(
            "Retirements       = %0d",
            taken_retire_count
        );

        $display(
            "JZ taken hits     = %0d",
            taken_jz_taken_hits
        );

        $display(
            "JZ not taken hits = %0d",
            taken_jz_not_taken_hits
        );

        $display(
            "JMP hits          = %0d",
            taken_jmp_hits
        );

        $display(
            "Child failures    = %0d",
            taken_failures
        );


        $display("");

        $display(
            "Top-level check failures = %0d",
            top_failures
        );


        // ====================================================
        // OVERALL RESULT
        // ====================================================

        if (
            nt_failures == 0 &&
            taken_failures == 0 &&
            top_failures == 0 &&

            nt_retire_count == 7 &&
            taken_retire_count == 6 &&

            nt_jz_not_taken_hits == 1 &&
            nt_jz_taken_hits == 0 &&
            nt_jmp_hits == 1 &&

            taken_jz_taken_hits == 1 &&
            taken_jz_not_taken_hits == 0 &&
            taken_jmp_hits == 0
        ) begin

            $display("");
            $display(
                "BRANCH / PC SCOREBOARD: PASS"
            );

        end


        else begin

            $display("");
            $display(
                "BRANCH / PC SCOREBOARD: FAIL"
            );

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule