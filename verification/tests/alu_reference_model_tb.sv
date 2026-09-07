`timescale 1ns/1ps

module alu_reference_model_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;


    // ========================================================
    // DUT — REAL MINIRISC RTL
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
    // REFERENCE MODEL
    // ========================================================
    //
    // This function calculates what the ALU result SHOULD be.
    //
    // It is independent from the DUT output.
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


                // Unsupported / reserved ALU operation
                default:
                    alu_reference_result = 8'd0;

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
    // DISPLAY DUT VS REFERENCE MODEL
    // ========================================================

    task automatic compare_result;

        logic [7:0] expected_result;

        begin

            expected_result = alu_reference_result(
                a,
                b,
                op
            );


            $display(
                "A=%0d B=%0d OP=%b | DUT=%0d REF=%0d",
                a,
                b,
                op,
                result,
                expected_result
            );


            if (result === expected_result) begin

                $display("RESULT MATCH: PASS");

            end

            else begin

                $display("RESULT MATCH: FAIL");

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
        $display(" MINIRISC V2 - ALU REFERENCE MODEL");
        $display("==============================================");
        $display("");


        // ----------------------------------------------------
        // ADD
        // ----------------------------------------------------

        drive_alu(
            8'd5,
            8'd3,
            3'b000
        );

        compare_result();


        // ----------------------------------------------------
        // SUB
        // ----------------------------------------------------

        drive_alu(
            8'd10,
            8'd3,
            3'b001
        );

        compare_result();


        // ----------------------------------------------------
        // AND
        // ----------------------------------------------------

        drive_alu(
            8'hAA,
            8'hCC,
            3'b010
        );

        compare_result();


        // ----------------------------------------------------
        // OR
        // ----------------------------------------------------

        drive_alu(
            8'hAA,
            8'hCC,
            3'b011
        );

        compare_result();


        // ----------------------------------------------------
        // XOR
        // ----------------------------------------------------

        drive_alu(
            8'hAA,
            8'hCC,
            3'b100
        );

        compare_result();


        // ----------------------------------------------------
        // ZERO RESULT
        // ----------------------------------------------------

        drive_alu(
            8'd5,
            8'd5,
            3'b001
        );

        compare_result();


        // ----------------------------------------------------
        // OVERFLOW / WRAPAROUND
        // ----------------------------------------------------

        drive_alu(
            8'd255,
            8'd1,
            3'b000
        );

        compare_result();


        $display("==============================================");
        $display(" REFERENCE MODEL TEST COMPLETE");
        $display("==============================================");
        $display("");

        $finish;

    end

endmodule