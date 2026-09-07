`timescale 1ns/1ps

module control_unit_assertion_tb;

    logic [3:0] opcode;

    logic [2:0] alu_op;
    logic [1:0] wb_sel;

    logic reg_write_req;
    logic flag_write_req;

    logic mem_read_req;
    logic mem_write_req;

    logic jump;
    logic jump_zero;

    logic halt;

    integer total_tests;
    integer assertion_failures;


    // ========================================================
    // DUT
    // ========================================================

    control_unit dut (
        .opcode(opcode),

        .alu_op(alu_op),
        .wb_sel(wb_sel),

        .reg_write_req(reg_write_req),
        .flag_write_req(flag_write_req),

        .mem_read_req(mem_read_req),
        .mem_write_req(mem_write_req),

        .jump(jump),
        .jump_zero(jump_zero),

        .halt(halt)
    );


    // ========================================================
    // GLOBAL CONTROL ASSERTIONS
    // ========================================================

    task automatic check_global_assertions;

        begin

            // ------------------------------------------------
            // Memory cannot be read and written simultaneously
            // ------------------------------------------------

            assert (!(mem_read_req && mem_write_req))

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "MEMORY CONFLICT | opcode=%b read=%b write=%b",
                    opcode,
                    mem_read_req,
                    mem_write_req
                );

            end


            // ------------------------------------------------
            // JMP and JZ must never both be active
            // ------------------------------------------------

            assert (!(jump && jump_zero))

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "JUMP CONFLICT | opcode=%b jump=%b jump_zero=%b",
                    opcode,
                    jump,
                    jump_zero
                );

            end


            // ------------------------------------------------
            // HALT must not request architectural writes
            // ------------------------------------------------

            if (halt) begin

                assert (
                    !reg_write_req  &&
                    !flag_write_req &&
                    !mem_read_req   &&
                    !mem_write_req  &&
                    !jump           &&
                    !jump_zero
                )

                else begin

                    assertion_failures = assertion_failures + 1;

                    $error(
                        "HALT SIDE-EFFECT ASSERTION FAILED | opcode=%b",
                        opcode
                    );

                end

            end

        end

    endtask


    // ========================================================
    // OPCODE-SPECIFIC ASSERTIONS
    // ========================================================

    task automatic check_opcode_assertions;

        begin

            case (opcode)

                // =================================================
                // NOP
                // =================================================

                4'b0000: begin

                    assert (
                        !reg_write_req  &&
                        !flag_write_req &&
                        !mem_read_req   &&
                        !mem_write_req  &&
                        !jump           &&
                        !jump_zero      &&
                        !halt
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("NOP ASSERTION FAILED");

                    end

                end


                // =================================================
                // LDI
                // =================================================

                4'b0001: begin

                    assert (
                        reg_write_req &&
                        wb_sel == 2'b01 &&
                        !flag_write_req &&
                        !mem_read_req &&
                        !mem_write_req
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("LDI ASSERTION FAILED");

                    end

                end


                // =================================================
                // MOV
                // =================================================

                4'b0010: begin

                    assert (
                        reg_write_req &&
                        wb_sel == 2'b11 &&
                        !flag_write_req &&
                        !mem_read_req &&
                        !mem_write_req
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("MOV ASSERTION FAILED");

                    end

                end


                // =================================================
                // ADD
                // =================================================

                4'b0011: begin

                    assert (
                        alu_op == 3'b000 &&
                        reg_write_req &&
                        flag_write_req &&
                        wb_sel == 2'b00
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("ADD CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // SUB
                // =================================================

                4'b0100: begin

                    assert (
                        alu_op == 3'b001 &&
                        reg_write_req &&
                        flag_write_req &&
                        wb_sel == 2'b00
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("SUB CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // AND
                // =================================================

                4'b0101: begin

                    assert (
                        alu_op == 3'b010 &&
                        reg_write_req &&
                        flag_write_req &&
                        wb_sel == 2'b00
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("AND CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // OR
                // =================================================

                4'b0110: begin

                    assert (
                        alu_op == 3'b011 &&
                        reg_write_req &&
                        flag_write_req &&
                        wb_sel == 2'b00
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("OR CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // XOR
                // =================================================

                4'b0111: begin

                    assert (
                        alu_op == 3'b100 &&
                        reg_write_req &&
                        flag_write_req &&
                        wb_sel == 2'b00
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("XOR CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // LOAD
                // =================================================

                4'b1000: begin

                    assert (
                        reg_write_req &&
                        mem_read_req &&
                        !mem_write_req &&
                        wb_sel == 2'b10
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("LOAD CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // STORE
                // =================================================

                4'b1001: begin

                    assert (
                        mem_write_req &&
                        !mem_read_req &&
                        !reg_write_req &&
                        !flag_write_req
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("STORE CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // JMP
                // =================================================

                4'b1010: begin

                    assert (
                        jump &&
                        !jump_zero &&
                        !reg_write_req &&
                        !mem_write_req
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("JMP CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // JZ
                // =================================================

                4'b1011: begin

                    assert (
                        jump_zero &&
                        !jump &&
                        !reg_write_req &&
                        !mem_write_req
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("JZ CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // CMP
                // =================================================

                4'b1100: begin

                    assert (
                        alu_op == 3'b001 &&
                        flag_write_req &&
                        !reg_write_req &&
                        !mem_read_req &&
                        !mem_write_req
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("CMP CONTROL ASSERTION FAILED");

                    end

                end


                // =================================================
                // RESERVED 1101
                // =================================================

                4'b1101: begin

                    assert (
                        !reg_write_req &&
                        !flag_write_req &&
                        !mem_read_req &&
                        !mem_write_req &&
                        !jump &&
                        !jump_zero &&
                        !halt
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("RESERVED 1101 ASSERTION FAILED");

                    end

                end


                // =================================================
                // RESERVED 1110
                // =================================================

                4'b1110: begin

                    assert (
                        !reg_write_req &&
                        !flag_write_req &&
                        !mem_read_req &&
                        !mem_write_req &&
                        !jump &&
                        !jump_zero &&
                        !halt
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("RESERVED 1110 ASSERTION FAILED");

                    end

                end


                // =================================================
                // HALT
                // =================================================

                4'b1111: begin

                    assert (
                        halt &&
                        !reg_write_req &&
                        !flag_write_req &&
                        !mem_read_req &&
                        !mem_write_req &&
                        !jump &&
                        !jump_zero
                    )

                    else begin

                        assertion_failures = assertion_failures + 1;
                        $error("HALT CONTROL ASSERTION FAILED");

                    end

                end

            endcase

        end

    endtask


    // ========================================================
    // RUN ONE OPCODE
    // ========================================================

    task automatic run_opcode(
        input logic [3:0] test_opcode,
        input string      opcode_name
    );

        begin

            opcode = test_opcode;

            #1;

            total_tests = total_tests + 1;


            $display(
                "CHECK | %-10s | OPCODE=%b | RW=%b FW=%b MR=%b MW=%b J=%b JZ=%b H=%b",
                opcode_name,
                opcode,
                reg_write_req,
                flag_write_req,
                mem_read_req,
                mem_write_req,
                jump,
                jump_zero,
                halt
            );


            check_global_assertions();

            check_opcode_assertions();

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        total_tests        = 0;
        assertion_failures = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - CONTROL UNIT ASSERTIONS");
        $display("==============================================");
        $display("");


        run_opcode(4'b0000, "NOP");
        run_opcode(4'b0001, "LDI");
        run_opcode(4'b0010, "MOV");
        run_opcode(4'b0011, "ADD");

        run_opcode(4'b0100, "SUB");
        run_opcode(4'b0101, "AND");
        run_opcode(4'b0110, "OR");
        run_opcode(4'b0111, "XOR");

        run_opcode(4'b1000, "LOAD");
        run_opcode(4'b1001, "STORE");
        run_opcode(4'b1010, "JMP");
        run_opcode(4'b1011, "JZ");

        run_opcode(4'b1100, "CMP");
        run_opcode(4'b1101, "RESERVED");
        run_opcode(4'b1110, "RESERVED");
        run_opcode(4'b1111, "HALT");


        // ====================================================
        // FINAL SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" CONTROL ASSERTION SUMMARY");
        $display("==============================================");

        $display(
            "Opcodes checked     = %0d",
            total_tests
        );

        $display(
            "Assertion failures  = %0d",
            assertion_failures
        );


        if (assertion_failures == 0) begin

            $display("");
            $display("CONTROL ASSERTIONS: PASS");

        end

        else begin

            $display("");
            $display("CONTROL ASSERTIONS: FAIL");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule