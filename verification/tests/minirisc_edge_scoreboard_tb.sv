`timescale 1ns/1ps

module minirisc_edge_scoreboard_tb;

    // ========================================================
    // DUT
    // ========================================================

    logic clk;
    logic reset;

    logic [7:0]  pc;
    logic [15:0] instruction;
    logic [2:0]  state;

    logic zero;
    logic carry;
    logic halted;


    minirisc_cpu #(
        .PROGRAM_FILE(
            "programs/edge_cpu_test.mem"
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
    // REFERENCE STATE
    // ========================================================

    logic [7:0] ref_regs [0:7];

    logic ref_zero;
    logic ref_carry;


    logic [7:0]  retiring_pc;
    logic [15:0] retiring_instruction;

    logic [3:0] opcode;
    logic [2:0] rd;
    logic [2:0] rs;
    logic [7:0] immediate;

    logic [7:0] alu_result;
    logic [8:0] extended_result;


    // ========================================================
    // STATISTICS
    // ========================================================

    integer retire_count;
    integer pass_count;
    integer fail_count;

    integer timeout_cycles;


    // ========================================================
    // EDGE COVERAGE COUNTERS
    // ========================================================

    integer boundary_0_hits;
    integer boundary_1_hits;
    integer boundary_254_hits;
    integer boundary_255_hits;

    integer add_255_1_hits;
    integer add_255_255_hits;
    integer add_254_1_hits;

    integer sub_equal_hits;
    integer sub_underflow_hits;

    integer and_zero_hits;
    integer or_allones_hits;
    integer xor_self_hits;

    integer r0_write_hits;

    integer cmp_equal_hits;
    integer cmp_notequal_hits;


    // ========================================================
    // CLOCK
    // ========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ========================================================
    // INITIALISE REFERENCE
    // ========================================================

    task automatic initialise_reference;

        integer i;

        begin

            for (i = 0; i < 8; i = i + 1)
                ref_regs[i] = 8'd0;

            ref_zero  = 1'b0;
            ref_carry = 1'b0;

        end

    endtask


    // ========================================================
    // DECODE
    // ========================================================

    task automatic decode_instruction;

        begin

            opcode =
                retiring_instruction[15:12];

            rd =
                retiring_instruction[11:9];

            rs =
                retiring_instruction[8:6];

            immediate =
                retiring_instruction[7:0];

        end

    endtask


    // ========================================================
    // EDGE COVERAGE
    //
    // Called BEFORE reference execution so operands still
    // contain their original values.
    // ========================================================

    task automatic record_edge_coverage;

        logic [7:0] operand_a;
        logic [7:0] operand_b;

        begin

            operand_a = ref_regs[rd];
            operand_b = ref_regs[rs];


            // =================================================
            // BOUNDARY IMMEDIATES
            // =================================================

            if (opcode == 4'b0001) begin

                case (immediate)

                    8'd0:
                        boundary_0_hits++;

                    8'd1:
                        boundary_1_hits++;

                    8'd254:
                        boundary_254_hits++;

                    8'd255:
                        boundary_255_hits++;

                endcase

            end


            // =================================================
            // ADD EDGES
            // =================================================

            if (opcode == 4'b0011) begin

                if (
                    operand_a == 8'd255 &&
                    operand_b == 8'd1
                )
                    add_255_1_hits++;


                if (
                    operand_a == 8'd255 &&
                    operand_b == 8'd255
                )
                    add_255_255_hits++;


                if (
                    operand_a == 8'd254 &&
                    operand_b == 8'd1
                )
                    add_254_1_hits++;

            end


            // =================================================
            // SUB EDGES
            // =================================================

            if (opcode == 4'b0100) begin

                if (operand_a == operand_b)
                    sub_equal_hits++;


                if (operand_a < operand_b)
                    sub_underflow_hits++;

            end


            // =================================================
            // LOGIC EDGES
            // =================================================

            if (opcode == 4'b0101) begin

                if (
                    (operand_a & operand_b)
                    ==
                    8'd0
                )
                    and_zero_hits++;

            end


            if (opcode == 4'b0110) begin

                if (
                    (operand_a | operand_b)
                    ==
                    8'hFF
                )
                    or_allones_hits++;

            end


            if (opcode == 4'b0111) begin

                if (rd == rs)
                    xor_self_hits++;

            end


            // =================================================
            // R0 WRITES
            // =================================================

            if (rd == 3'd0) begin

                case (opcode)

                    4'b0001,
                    4'b0010,
                    4'b0011,
                    4'b0100,
                    4'b0101,
                    4'b0110,
                    4'b0111:
                        r0_write_hits++;

                endcase

            end


            // =================================================
            // CMP
            // =================================================

            if (opcode == 4'b1100) begin

                if (operand_a == operand_b)
                    cmp_equal_hits++;

                else
                    cmp_notequal_hits++;

            end

        end

    endtask


    // ========================================================
    // REFERENCE EXECUTION
    // ========================================================

    task automatic execute_reference;

        begin

            alu_result      = 8'd0;
            extended_result = 9'd0;


            case (opcode)

                // NOP
                4'b0000: begin

                end


                // LDI
                4'b0001: begin

                    ref_regs[rd] =
                        immediate;

                end


                // MOV
                4'b0010: begin

                    ref_regs[rd] =
                        ref_regs[rs];

                end


                // ADD
                4'b0011: begin

                    extended_result =
                        {1'b0, ref_regs[rd]}
                        +
                        {1'b0, ref_regs[rs]};


                    alu_result =
                        extended_result[7:0];


                    ref_regs[rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        extended_result[8];

                end


                // SUB
                4'b0100: begin

                    alu_result =
                        ref_regs[rd]
                        -
                        ref_regs[rs];


                    ref_regs[rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // AND
                4'b0101: begin

                    alu_result =
                        ref_regs[rd]
                        &
                        ref_regs[rs];


                    ref_regs[rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // OR
                4'b0110: begin

                    alu_result =
                        ref_regs[rd]
                        |
                        ref_regs[rs];


                    ref_regs[rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // XOR
                4'b0111: begin

                    alu_result =
                        ref_regs[rd]
                        ^
                        ref_regs[rs];


                    ref_regs[rd] =
                        alu_result;


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // CMP
                4'b1100: begin

                    alu_result =
                        ref_regs[rd]
                        -
                        ref_regs[rs];


                    ref_zero =
                        (alu_result == 8'd0);


                    ref_carry =
                        1'b0;

                end


                // HALT
                4'b1111: begin

                end

            endcase

        end

    endtask


    // ========================================================
    // SCOREBOARD
    // ========================================================

    task automatic check_architecture;

        integer i;
        integer mismatches;

        begin

            mismatches = 0;


            for (i = 0; i < 8; i = i + 1) begin

                if (
                    dut.u_regfile.registers[i]
                    !==
                    ref_regs[i]
                ) begin

                    mismatches++;

                    $display(
                        "    REG MISMATCH | R%0d DUT=%0d REF=%0d",
                        i,
                        dut.u_regfile.registers[i],
                        ref_regs[i]
                    );

                end

            end


            if (zero !== ref_zero) begin

                mismatches++;

                $display(
                    "    ZERO MISMATCH | DUT=%b REF=%b",
                    zero,
                    ref_zero
                );

            end


            if (carry !== ref_carry) begin

                mismatches++;

                $display(
                    "    CARRY MISMATCH | DUT=%b REF=%b",
                    carry,
                    ref_carry
                );

            end


            if (mismatches == 0) begin

                pass_count++;

                $display(
                    "PASS | RETIRE #%0d | PC=%0d | OP=%b",
                    retire_count,
                    retiring_pc,
                    opcode
                );

            end


            else begin

                fail_count++;

                $display(
                    "FAIL | RETIRE #%0d | PC=%0d | mismatches=%0d",
                    retire_count,
                    retiring_pc,
                    mismatches
                );

            end

        end

    endtask


    // ========================================================
    // PC CHECK
    // ========================================================

    task automatic check_pc;

        logic [7:0] expected_pc;

        begin

            if (opcode != 4'b1111) begin

                expected_pc =
                    retiring_pc + 8'd1;


                if (pc !== expected_pc) begin

                    fail_count++;

                    $display(
                        "FAIL | PC | DUT=%0d REF=%0d",
                        pc,
                        expected_pc
                    );

                end

            end

        end

    endtask


    // ========================================================
    // PROCESS RETIREMENT
    // ========================================================

    task automatic process_retirement;

        begin

            retire_count++;

            decode_instruction();

            record_edge_coverage();

            execute_reference();

            check_architecture();

            check_pc();

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

                // NORMAL
                if (dut.writeback_state) begin

                    retiring_pc =
                        pc;

                    retiring_instruction =
                        dut.current_instruction;


                    #1;

                    process_retirement();

                end


                // HALT
                else if (
                    dut.decode_state &&
                    dut.halt_req
                ) begin

                    retiring_pc =
                        pc;

                    retiring_instruction =
                        dut.current_instruction;


                    #1;

                    process_retirement();

                end

            end

        end

    end


    // ========================================================
    // MAIN
    // ========================================================

    initial begin

        reset = 1'b1;

        pass_count = 0;
        fail_count = 0;

        timeout_cycles = 0;


        boundary_0_hits   = 0;
        boundary_1_hits   = 0;
        boundary_254_hits = 0;
        boundary_255_hits = 0;

        add_255_1_hits   = 0;
        add_255_255_hits = 0;
        add_254_1_hits   = 0;

        sub_equal_hits     = 0;
        sub_underflow_hits = 0;

        and_zero_hits   = 0;
        or_allones_hits = 0;
        xor_self_hits   = 0;

        r0_write_hits = 0;

        cmp_equal_hits    = 0;
        cmp_notequal_hits = 0;


        initialise_reference();


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - EDGE / BOUNDARY SCOREBOARD");
        $display("==============================================");
        $display("");


        repeat (2)
            @(posedge clk);

        reset = 1'b0;


        while (
            halted !== 1'b1 &&
            timeout_cycles < 150
        ) begin

            @(posedge clk);

            timeout_cycles++;

        end


        #5;


        // ====================================================
        // STRUCTURAL CHECKS
        // ====================================================

        if (halted !== 1'b1) begin

            fail_count++;

            $display(
                "FAIL | CPU failed to HALT"
            );

        end


        if (retire_count != 28) begin

            fail_count++;

            $display(
                "FAIL | Retirement count=%0d expected=28",
                retire_count
            );

        end


        if (pc !== 8'd27) begin

            fail_count++;

            $display(
                "FAIL | Final PC=%0d expected=27",
                pc
            );

        end


        // ====================================================
        // COVERAGE CLOSURE CHECKS
        // ====================================================

        if (boundary_0_hits == 0)
            fail_count++;

        if (boundary_1_hits == 0)
            fail_count++;

        if (boundary_254_hits == 0)
            fail_count++;

        if (boundary_255_hits == 0)
            fail_count++;


        if (add_255_1_hits == 0)
            fail_count++;

        if (add_255_255_hits == 0)
            fail_count++;

        if (add_254_1_hits == 0)
            fail_count++;


        if (sub_equal_hits == 0)
            fail_count++;

        if (sub_underflow_hits == 0)
            fail_count++;


        if (and_zero_hits == 0)
            fail_count++;

        if (or_allones_hits == 0)
            fail_count++;

        if (xor_self_hits == 0)
            fail_count++;


        if (r0_write_hits == 0)
            fail_count++;


        if (cmp_equal_hits == 0)
            fail_count++;

        if (cmp_notequal_hits == 0)
            fail_count++;


        // ====================================================
        // REPORT
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" EDGE / BOUNDARY SUMMARY");
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
        $display("BOUNDARY VALUE HITS");

        $display(
            "0   = %0d",
            boundary_0_hits
        );

        $display(
            "1   = %0d",
            boundary_1_hits
        );

        $display(
            "254 = %0d",
            boundary_254_hits
        );

        $display(
            "255 = %0d",
            boundary_255_hits
        );


        $display("");
        $display("ARITHMETIC EDGE HITS");

        $display(
            "255 + 1   = %0d",
            add_255_1_hits
        );

        $display(
            "255 + 255 = %0d",
            add_255_255_hits
        );

        $display(
            "254 + 1   = %0d",
            add_254_1_hits
        );

        $display(
            "SUB equal = %0d",
            sub_equal_hits
        );

        $display(
            "SUB underflow = %0d",
            sub_underflow_hits
        );


        $display("");
        $display("LOGIC EDGE HITS");

        $display(
            "AND -> zero = %0d",
            and_zero_hits
        );

        $display(
            "OR -> 255 = %0d",
            or_allones_hits
        );

        $display(
            "XOR self = %0d",
            xor_self_hits
        );


        $display("");
        $display("ARCHITECTURAL EDGE HITS");

        $display(
            "R0 writes     = %0d",
            r0_write_hits
        );

        $display(
            "CMP equal     = %0d",
            cmp_equal_hits
        );

        $display(
            "CMP not equal = %0d",
            cmp_notequal_hits
        );


        $display("");

        $display(
            "Final flags DUT Z=%b C=%b | REF Z=%b C=%b",
            zero,
            carry,
            ref_zero,
            ref_carry
        );


        if (
            fail_count == 0 &&
            retire_count == 28 &&
            pass_count == 28
        ) begin

            $display("");
            $display(
                "EDGE / BOUNDARY SCOREBOARD: PASS"
            );

        end

        else begin

            $display("");
            $display(
                "EDGE / BOUNDARY SCOREBOARD: FAIL"
            );

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule