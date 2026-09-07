`timescale 1ns/1ps

module alu_reference_flags_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;


    // ========================================================
    // DUT — REAL MINIRISC ALU
    // ========================================================

    alu dut (
        .a(a),
        .b(b),
        .op(op),

        .result(result),
        .zero(zero),
        .carry(carry)
    );


    // ========================================================
    // REFERENCE RESULT MODEL
    // ========================================================

    function automatic logic [7:0] alu_reference_result(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        begin

            case (ref_op)

                // ADD
                3'b000:
                    alu_reference_result = ref_a + ref_b;

                // SUB
                3'b001:
                    alu_reference_result = ref_a - ref_b;

                // AND
                3'b010:
                    alu_reference_result = ref_a & ref_b;

                // OR
                3'b011:
                    alu_reference_result = ref_a | ref_b;

                // XOR
                3'b100:
                    alu_reference_result = ref_a ^ ref_b;

                default:
                    alu_reference_result = 8'd0;

            endcase

        end

    endfunction


    // ========================================================
    // REFERENCE ZERO FLAG MODEL
    // ========================================================

    function automatic logic alu_reference_zero(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        logic [7:0] expected_result;

        begin

            expected_result = alu_reference_result(
                ref_a,
                ref_b,
                ref_op
            );

            alu_reference_zero = (expected_result == 8'd0);

        end

    endfunction


    // ========================================================
    // REFERENCE CARRY FLAG MODEL
    // ========================================================

    function automatic logic alu_reference_carry(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        logic [8:0] extended_result;

        begin

            extended_result = 9'd0;

            case (ref_op)

                // ADD
                //
                // Use 9 bits so that the overflow bit
                // is preserved as Carry.
                3'b000: begin

                    extended_result =
                        {1'b0, ref_a} +
                        {1'b0, ref_b};

                    alu_reference_carry =
                        extended_result[8];

                end


                // Current tested SUB / logic behaviour
                default: begin

                    alu_reference_carry = 1'b0;

                end

            endcase

        end

    endfunction


    // ========================================================
    // DRIVER
    // ========================================================

    task automatic drive_alu(
        input logic [7:0] test_a,
        input logic [7:0] test_b,
        input logic [2:0] test_op
    );

        begin

            a  = test_a;
            b  = test_b;
            op = test_op;

            #1;

        end

    endtask


    // ========================================================
    // COMPARE DUT AGAINST COMPLETE REFERENCE MODEL
    // ========================================================

    task automatic compare_alu;

        logic [7:0] expected_result;
        logic       expected_zero;
        logic       expected_carry;

        begin

            expected_result = alu_reference_result(
                a,
                b,
                op
            );

            expected_zero = alu_reference_zero(
                a,
                b,
                op
            );

            expected_carry = alu_reference_carry(
                a,
                b,
                op
            );


            $display(
                "A=%0d B=%0d OP=%b | DUT: R=%0d Z=%b C=%b | REF: R=%0d Z=%b C=%b",
                a,
                b,
                op,

                result,
                zero,
                carry,

                expected_result,
                expected_zero,
                expected_carry
            );


            if (
                result === expected_result &&
                zero   === expected_zero   &&
                carry  === expected_carry
            ) begin

                $display("COMPLETE MATCH: PASS");

            end

            else begin

                $display("COMPLETE MATCH: FAIL");

            end

            $display("");

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - REFERENCE RESULT + FLAGS");
        $display("==============================================");
        $display("");


        // ADD
        drive_alu(
            8'd5,
            8'd3,
            3'b000
        );

        compare_alu();


        // SUB
        drive_alu(
            8'd10,
            8'd3,
            3'b001
        );

        compare_alu();


        // AND
        drive_alu(
            8'hAA,
            8'hCC,
            3'b010
        );

        compare_alu();


        // OR
        drive_alu(
            8'hAA,
            8'hCC,
            3'b011
        );

        compare_alu();


        // XOR
        drive_alu(
            8'hAA,
            8'hCC,
            3'b100
        );

        compare_alu();


        // ZERO FLAG
        drive_alu(
            8'd5,
            8'd5,
            3'b001
        );

        compare_alu();


        // ZERO + CARRY
        drive_alu(
            8'd255,
            8'd1,
            3'b000
        );

        compare_alu();


        // Additional ADD carry case:
        // 200 + 100 = 300
        //
        // 300 - 256 = 44
        //
        // Expected:
        // result = 44
        // zero   = 0
        // carry  = 1
        drive_alu(
            8'd200,
            8'd100,
            3'b000
        );

        compare_alu();


        $display("==============================================");
        $display(" REFERENCE FLAG TEST COMPLETE");
        $display("==============================================");
        $display("");

        $finish;

    end

endmodule