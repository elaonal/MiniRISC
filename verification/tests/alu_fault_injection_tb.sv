`timescale 1ns/1ps

module alu_fault_injection_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;

    logic [7:0] result;
    logic       zero;
    logic       carry;

    integer detected_faults;


    // ========================================================
    // DUT
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

    function automatic logic [7:0] ref_result(
        input logic [7:0] ref_a,
        input logic [7:0] ref_b,
        input logic [2:0] ref_op
    );

        begin
            case (ref_op)

                3'b000:
                    ref_result = ref_a + ref_b;

                3'b001:
                    ref_result = ref_a - ref_b;

                3'b010:
                    ref_result = ref_a & ref_b;

                3'b011:
                    ref_result = ref_a | ref_b;

                3'b100:
                    ref_result = ref_a ^ ref_b;

                default:
                    ref_result = 8'd0;

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
    // SCOREBOARD WITH OPTIONAL FAULT INJECTION
    // ========================================================

    task automatic scoreboard_check(
        input logic inject_fault,
        input string test_name
    );

        logic [7:0] expected_result;
        logic [7:0] observed_result;

        begin

            expected_result = ref_result(
                a,
                b,
                op
            );


            // Normally observe the real DUT result.
            observed_result = result;


            // Deliberately corrupt bit 0 when requested.
            if (inject_fault)
                observed_result = result ^ 8'b00000001;


            if (observed_result === expected_result) begin

                $display(
                    "MATCH    | %-20s | DUT=%0d REF=%0d",
                    test_name,
                    observed_result,
                    expected_result
                );

            end

            else begin

                detected_faults = detected_faults + 1;

                $display(
                    "MISMATCH | %-20s | DUT=%0d REF=%0d",
                    test_name,
                    observed_result,
                    expected_result
                );

            end

        end

    endtask


    // ========================================================
    // TEST
    // ========================================================

    initial begin

        detected_faults = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - SCOREBOARD FAULT INJECTION");
        $display("==============================================");
        $display("");


        // ----------------------------------------------------
        // Normal transaction
        // ----------------------------------------------------

        drive_alu(
            8'd5,
            8'd3,
            3'b000
        );

        scoreboard_check(
            1'b0,
            "NORMAL ADD"
        );


        // ----------------------------------------------------
        // Same transaction with deliberate corruption
        // ----------------------------------------------------

        drive_alu(
            8'd5,
            8'd3,
            3'b000
        );

        scoreboard_check(
            1'b1,
            "INJECTED FAULT"
        );


        // ----------------------------------------------------
        // Normal transaction again
        // ----------------------------------------------------

        drive_alu(
            8'd10,
            8'd3,
            3'b001
        );

        scoreboard_check(
            1'b0,
            "NORMAL SUB"
        );


        $display("");
        $display("==============================================");
        $display(" FAULT-INJECTION SUMMARY");
        $display("==============================================");

        $display(
            "Detected faults = %0d",
            detected_faults
        );


        if (detected_faults == 1) begin

            $display("");
            $display("FAULT DETECTION TEST: PASS");

        end

        else begin

            $display("");
            $display("FAULT DETECTION TEST: FAIL");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule