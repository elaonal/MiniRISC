`timescale 1ns/1ps

module program_counter_assertion_tb;

    logic       clk;
    logic       reset;
    logic       enable;
    logic       load;
    logic [7:0] next_pc;

    logic [7:0] pc;

    integer assertion_checks;
    integer assertion_failures;


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
    // NEXT CLOCK
    // ========================================================

    task automatic next_cycle;

        begin

            @(posedge clk);

            // Allow non-blocking assignments to complete.
            #1;

        end

    endtask


    // ========================================================
    // ASSERT EXPECTED PC
    // ========================================================

    task automatic check_pc(
        input logic [7:0] expected_pc,
        input string      test_name
    );

        begin

            assertion_checks = assertion_checks + 1;


            $display(
                "CHECK | %-28s | PC=%0d EXPECTED=%0d",
                test_name,
                pc,
                expected_pc
            );


            assert (pc === expected_pc)

            else begin

                assertion_failures = assertion_failures + 1;

                $error(
                    "PC ASSERTION FAILED | %s | actual=%0d expected=%0d",
                    test_name,
                    pc,
                    expected_pc
                );

            end

        end

    endtask


    // ========================================================
    // TEST
    // ========================================================

    initial begin

        reset   = 1'b1;
        enable  = 1'b0;
        load    = 1'b0;
        next_pc = 8'd0;

        assertion_checks   = 0;
        assertion_failures = 0;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - PROGRAM COUNTER ASSERTIONS");
        $display("==============================================");
        $display("");


        // ====================================================
        // RESET -> 0
        // ====================================================

        next_cycle();

        check_pc(
            8'd0,
            "RESET -> PC 0"
        );


        // ====================================================
        // ENABLE = 0 -> HOLD
        // ====================================================

        reset  = 1'b0;
        enable = 1'b0;
        load   = 1'b0;

        next_cycle();

        check_pc(
            8'd0,
            "DISABLED -> HOLD"
        );


        // ====================================================
        // NORMAL INCREMENT
        // ====================================================

        enable = 1'b1;
        load   = 1'b0;

        next_cycle();

        check_pc(
            8'd1,
            "INCREMENT 0 -> 1"
        );


        next_cycle();

        check_pc(
            8'd2,
            "INCREMENT 1 -> 2"
        );


        next_cycle();

        check_pc(
            8'd3,
            "INCREMENT 2 -> 3"
        );


        // ====================================================
        // LOAD NEXT_PC
        // ====================================================

        enable  = 1'b1;
        load    = 1'b1;
        next_pc = 8'd20;

        next_cycle();

        check_pc(
            8'd20,
            "LOAD PC = 20"
        );


        // ====================================================
        // CONTINUE AFTER LOAD
        // ====================================================

        load = 1'b0;

        next_cycle();

        check_pc(
            8'd21,
            "INCREMENT 20 -> 21"
        );


        next_cycle();

        check_pc(
            8'd22,
            "INCREMENT 21 -> 22"
        );


        // ====================================================
        // ENABLE=0 MUST HOLD EVEN IF LOAD=1
        // ====================================================

        enable  = 1'b0;
        load    = 1'b1;
        next_pc = 8'd100;

        next_cycle();

        check_pc(
            8'd22,
            "DISABLED LOAD -> HOLD"
        );


        // ====================================================
        // ENABLE LOAD AGAIN
        // ====================================================

        enable  = 1'b1;
        load    = 1'b1;
        next_pc = 8'd255;

        next_cycle();

        check_pc(
            8'd255,
            "LOAD PC = 255"
        );


        // ====================================================
        // 8-BIT WRAPAROUND
        //
        // 255 + 1 -> 0
        // ====================================================

        load = 1'b0;

        next_cycle();

        check_pc(
            8'd0,
            "WRAP 255 -> 0"
        );


        // ====================================================
        // RESET PRIORITY
        //
        // Even if enable=1 and load=1,
        // reset must force PC to zero.
        // ====================================================

        reset   = 1'b1;
        enable  = 1'b1;
        load    = 1'b1;
        next_pc = 8'd200;

        next_cycle();

        check_pc(
            8'd0,
            "RESET PRIORITY"
        );


        // ====================================================
        // HOLD WHILE RESET REMAINS ACTIVE
        // ====================================================

        next_pc = 8'd123;

        next_cycle();

        check_pc(
            8'd0,
            "RESET REMAINS PC 0"
        );


        // ====================================================
        // RECOVERY AFTER RESET
        // ====================================================

        reset  = 1'b0;
        enable = 1'b1;
        load   = 1'b0;

        next_cycle();

        check_pc(
            8'd1,
            "POST-RESET INCREMENT"
        );


        // ====================================================
        // FINAL SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" PROGRAM COUNTER ASSERTION SUMMARY");
        $display("==============================================");

        $display(
            "Assertion checks   = %0d",
            assertion_checks
        );

        $display(
            "Assertion failures = %0d",
            assertion_failures
        );


        if (assertion_failures == 0) begin

            $display("");
            $display("PROGRAM COUNTER ASSERTIONS: PASS");

        end

        else begin

            $display("");
            $display("PROGRAM COUNTER ASSERTIONS: FAIL");

        end


        $display("==============================================");
        $display("");

        $finish;

    end

endmodule