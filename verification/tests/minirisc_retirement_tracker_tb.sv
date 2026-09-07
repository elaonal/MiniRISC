`timescale 1ns/1ps

module minirisc_retirement_tracker_tb;

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
    // RETIREMENT TRACKING
    // ========================================================

    integer retire_count;
    integer normal_retire_count;
    integer halt_retire_count;

    integer assertion_checks;
    integer assertion_failures;

    integer timeout_cycles;

    logic [7:0] expected_pc;

    logic [7:0]  retiring_pc;
    logic [15:0] retiring_instruction;
    logic [3:0]  retiring_opcode;


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
    // CHECK RETIREMENT PC
    // ========================================================

    task automatic check_retirement_pc;

        begin

            assertion_checks = assertion_checks + 1;

            assert (retiring_pc === expected_pc)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "RETIREMENT PC FAILED | retire=%0d actual_PC=%0d expected_PC=%0d",
                    retire_count,
                    retiring_pc,
                    expected_pc
                );

            end

        end

    endtask


    // ========================================================
    // NORMAL RETIREMENT
    // ========================================================

    task automatic retire_normal_instruction;

        begin

            retire_count        = retire_count + 1;
            normal_retire_count = normal_retire_count + 1;


            $display(
                "RETIRE #%0d | PC=%0d | %-5s | INSTR=%b",
                retire_count,
                retiring_pc,
                opcode_name(retiring_opcode),
                retiring_instruction
            );


            check_retirement_pc();


            // This specific test program is linear:
            //
            // PC 0,1,2,3,...,10
            expected_pc = expected_pc + 8'd1;

        end

    endtask


    // ========================================================
    // HALT RETIREMENT
    // ========================================================

    task automatic retire_halt_instruction;

        begin

            retire_count      = retire_count + 1;
            halt_retire_count = halt_retire_count + 1;


            $display(
                "RETIRE #%0d | PC=%0d | HALT  | INSTR=%b",
                retire_count,
                retiring_pc,
                retiring_instruction
            );


            check_retirement_pc();


            // HALT opcode must really be 1111.
            assertion_checks = assertion_checks + 1;

            assert (retiring_opcode === 4'b1111)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "HALT RETIREMENT OPCODE FAILED | opcode=%b",
                    retiring_opcode
                );

            end


            // FSM must have entered HALT.
            assertion_checks = assertion_checks + 1;

            assert (halted === 1'b1)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "HALT RETIREMENT FAILED | halted=%b",
                    halted
                );

            end

        end

    endtask


    // ========================================================
    // RETIREMENT EVENT TRACKER
    // ========================================================

    initial begin

        retire_count        = 0;
        normal_retire_count = 0;
        halt_retire_count   = 0;

        expected_pc = 8'd0;


        forever begin

            @(posedge clk);


            if (!reset) begin

                // =================================================
                // NORMAL INSTRUCTION COMPLETION
                //
                // register/PC updates occur when OLD state
                // is WRITEBACK.
                // =================================================

                if (dut.writeback_state) begin

                    retiring_pc          = pc;
                    retiring_instruction = dut.current_instruction;
                    retiring_opcode      = dut.opcode;


                    // Allow architectural NBA updates to occur.
                    #1;


                    retire_normal_instruction();

                end


                // =================================================
                // HALT COMPLETION
                //
                // HALT transitions directly:
                //
                // DECODE -> HALT
                //
                // Therefore HALT never reaches WRITEBACK.
                // =================================================

                else if (
                    dut.decode_state &&
                    dut.halt_req
                ) begin

                    retiring_pc          = pc;
                    retiring_instruction = dut.current_instruction;
                    retiring_opcode      = dut.opcode;


                    // Allow FSM DECODE -> HALT update.
                    #1;


                    retire_halt_instruction();

                end

            end

        end

    end


    // ========================================================
    // MAIN TEST
    // ========================================================

    initial begin

        reset = 1'b1;

        assertion_checks   = 0;
        assertion_failures = 0;

        timeout_cycles = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - RETIREMENT TRACKER");
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


        // Give tracker time to finish its HALT event.
        #5;


        // ====================================================
        // FINAL RETIREMENT ASSERTIONS
        // ====================================================

        assertion_checks = assertion_checks + 1;

        assert (normal_retire_count == 11)

        else begin

            assertion_failures = assertion_failures + 1;

            $error(
                "NORMAL RETIRE COUNT FAILED | actual=%0d expected=11",
                normal_retire_count
            );

        end


        assertion_checks = assertion_checks + 1;

        assert (halt_retire_count == 1)

        else begin

            assertion_failures = assertion_failures + 1;

            $error(
                "HALT RETIRE COUNT FAILED | actual=%0d expected=1",
                halt_retire_count
            );

        end


        assertion_checks = assertion_checks + 1;

        assert (retire_count == 12)

        else begin

            assertion_failures = assertion_failures + 1;

            $error(
                "TOTAL RETIRE COUNT FAILED | actual=%0d expected=12",
                retire_count
            );

        end


        // ====================================================
        // SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" RETIREMENT TRACKING SUMMARY");
        $display("==============================================");

        $display(
            "Normal retirements = %0d",
            normal_retire_count
        );

        $display(
            "HALT retirements   = %0d",
            halt_retire_count
        );

        $display(
            "Total retirements  = %0d",
            retire_count
        );

        $display("");

        $display(
            "Assertion checks   = %0d",
            assertion_checks
        );

        $display(
            "Assertion failures = %0d",
            assertion_failures
        );


        if (
            retire_count == 12 &&
            assertion_failures == 0
        ) begin

            $display("");
            $display("RETIREMENT TRACKING: PASS");

        end

        else begin

            $display("");
            $display("RETIREMENT TRACKING: FAIL");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule