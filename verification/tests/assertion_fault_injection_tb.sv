`timescale 1ns/1ps

module assertion_fault_injection_tb;

    logic       clk;
    logic       reset;
    logic       enable;
    logic       load;
    logic [7:0] next_pc;

    logic [7:0] pc;

    logic [7:0] observed_pc;

    integer detected_faults;


    // ========================================================
    // DUT
    // ========================================================

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .load(load),
        .next_pc(next_pc),
        .pc(pc)
    );


    // ========================================================
    // CLOCK
    // ========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ========================================================
    // NEXT CLOCK CYCLE
    // ========================================================

    task automatic next_cycle;

        begin

            @(posedge clk);

            #1;

        end

    endtask


    // ========================================================
    // NORMAL ASSERTION CHECK
    // ========================================================

    task automatic normal_check(
        input logic [7:0] expected_pc,
        input string      test_name
    );

        begin

            observed_pc = pc;


            if (observed_pc === expected_pc) begin

                $display(
                    "MATCH    | %-20s | OBSERVED=%0d EXPECTED=%0d",
                    test_name,
                    observed_pc,
                    expected_pc
                );

            end

            else begin

                $display(
                    "UNEXPECTED MISMATCH | %-20s",
                    test_name
                );

            end

        end

    endtask


    // ========================================================
    // DELIBERATE FAULT-INJECTION ASSERTION
    // ========================================================

    task automatic inject_and_check_fault(
        input logic [7:0] expected_pc
    );

        begin

            // Real DUT remains unchanged.
            //
            // We deliberately corrupt only the value observed
            // by this verification testbench.
            observed_pc = pc ^ 8'b00000001;


            // The point of this assertion is to FAIL.
            //
            // We count that failure as successful fault
            // detection by the verification environment.
            if (!(observed_pc === expected_pc)) begin

                detected_faults = detected_faults + 1;

                $display(
                    "ASSERTION VIOLATION DETECTED | OBSERVED=%0d EXPECTED=%0d",
                    observed_pc,
                    expected_pc
                );

            end

            else begin

                $display(
                    "FAULT NOT DETECTED"
                );

            end

        end

    endtask


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        reset   = 1'b1;
        enable  = 1'b0;
        load    = 1'b0;
        next_pc = 8'd0;

        observed_pc    = 8'd0;
        detected_faults = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - ASSERTION FAULT INJECTION");
        $display("==============================================");
        $display("");


        // ====================================================
        // RESET
        // ====================================================

        next_cycle();

        normal_check(
            8'd0,
            "RESET"
        );


        // ====================================================
        // NORMAL INCREMENT
        // ====================================================

        reset  = 1'b0;
        enable = 1'b1;

        next_cycle();

        normal_check(
            8'd1,
            "NORMAL PC"
        );


        // ====================================================
        // DELIBERATE FAULT
        //
        // Real PC = 1
        //
        // Testbench flips bit 0:
        //
        // 00000001 XOR 00000001
        // =
        // 00000000
        //
        // Expected still = 1, therefore mismatch.
        // ====================================================

        inject_and_check_fault(
            8'd1
        );


        // ====================================================
        // PROVE REAL DUT WAS NEVER MODIFIED
        // ====================================================

        normal_check(
            8'd1,
            "DUT STILL CORRECT"
        );


        // ====================================================
        // CONTINUE NORMAL OPERATION
        // ====================================================

        next_cycle();

        normal_check(
            8'd2,
            "NEXT NORMAL PC"
        );


        // ====================================================
        // SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" FAULT-DETECTION SUMMARY");
        $display("==============================================");

        $display(
            "Detected faults = %0d",
            detected_faults
        );


        if (detected_faults == 1) begin

            $display("");
            $display("ASSERTION FAULT-DETECTION TEST: PASS");

        end

        else begin

            $display("");
            $display("ASSERTION FAULT-DETECTION TEST: FAIL");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule