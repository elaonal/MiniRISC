`timescale 1ns/1ps

module minirisc_fpga_top_tb;


    // ========================================================
    // SIMULATION PARAMETERS
    // ========================================================
    //
    // We intentionally use a much smaller clock/baud ratio
    // than real hardware so UART simulation finishes quickly.
    //
    // 1 MHz / 100 kbaud = 10 clocks per UART bit.
    // ========================================================

    localparam integer CLK_FREQ_HZ = 1_000_000;
    localparam integer UART_BAUD   = 100_000;

    localparam integer CLK_PERIOD_NS = 10;
    localparam integer CLKS_PER_BIT =
        CLK_FREQ_HZ / UART_BAUD;

    localparam integer UART_BIT_TIME_NS =
        CLK_PERIOD_NS * CLKS_PER_BIT;


    // ========================================================
    // TESTBENCH SIGNALS
    // ========================================================

    logic clk;
    logic reset;

    wire [7:0] led;

    wire uart_tx_pin;

    wire [7:0]  pc_debug;
    wire [15:0] instruction_debug;
    wire [2:0]  state_debug;

    wire zero_debug;
    wire carry_debug;
    wire halted;


    integer pass_count;
    integer fail_count;

    logic [7:0] received_uart_byte;


    // ========================================================
    // DUT
    // ========================================================

    minirisc_fpga_top #(

        .PROGRAM_FILE("programs/test_program.mem"),

        .CLK_FREQ_HZ(CLK_FREQ_HZ),

        .UART_BAUD(UART_BAUD)

    ) dut (

        .clk(clk),

        .reset(reset),

        .led(led),

        .uart_tx_pin(uart_tx_pin),

        .pc_debug(pc_debug),

        .instruction_debug(instruction_debug),

        .state_debug(state_debug),

        .zero_debug(zero_debug),

        .carry_debug(carry_debug),

        .halted(halted)

    );


    // ========================================================
    // CLOCK GENERATION
    // ========================================================

    initial begin

        clk = 1'b0;

        forever begin

            #(CLK_PERIOD_NS / 2);

            clk = ~clk;

        end

    end


    // ========================================================
    // UART RECEIVER TASK
    // ========================================================
    //
    // Wait for the UART start bit, then sample each data bit
    // in the middle of its bit period.
    //
    // UART transmits:
    //
    // start
    // D0
    // D1
    // ...
    // D7
    // stop
    //
    // Data is LSB first.
    // ========================================================

    task automatic receive_uart_byte(
        output logic [7:0] received_data
    );

        integer bit_number;

        begin

            // Wait for start-bit falling edge.
            @(negedge uart_tx_pin);


            // Move to centre of first DATA bit.
            //
            // 1 start bit
            // +
            // half a data-bit time
            //
            #(UART_BIT_TIME_NS +
              (UART_BIT_TIME_NS / 2));


            for (
                bit_number = 0;
                bit_number < 8;
                bit_number = bit_number + 1
            ) begin

                received_data[bit_number] =
                    uart_tx_pin;

                #(UART_BIT_TIME_NS);

            end


            // We should now be around the middle
            // of the UART stop bit.

            if (uart_tx_pin !== 1'b1) begin

                $display(
                    "FAIL: UART stop bit is not HIGH"
                );

                fail_count = fail_count + 1;

            end

            else begin

                $display(
                    "PASS: UART stop bit detected"
                );

                pass_count = pass_count + 1;

            end

        end

    endtask


    // ========================================================
    // MAIN TEST
    // ========================================================

    initial begin

        pass_count = 0;

        fail_count = 0;

        received_uart_byte = 8'd0;


        // ====================================================
        // INITIAL RESET
        // ====================================================

        reset = 1'b1;


        $display("");
        $display("==============================================");
        $display(" MINIRISC V2 - FPGA WRAPPER SIMULATION");
        $display("==============================================");
        $display("");

        $display(
            "Applying external FPGA reset..."
        );


        // Keep external reset active for several clocks.

        repeat (4)
            @(posedge clk);


        reset = 1'b0;


        $display(
            "External reset released."
        );

        $display(
            "Waiting for MiniRISC program execution..."
        );


        // ====================================================
        // WAIT FOR CPU HALT
        // ====================================================

        wait (halted === 1'b1);


        // Allow combinational debug signals to settle.

        #1;


        $display("");
        $display("----------------------------------------------");
        $display(" CPU REACHED HALT");
        $display("----------------------------------------------");

        $display(
            "PC          = %0d",
            pc_debug
        );

        $display(
            "Instruction = %h",
            instruction_debug
        );

        $display(
            "State       = %b",
            state_debug
        );

        $display(
            "Zero        = %b",
            zero_debug
        );

        $display(
            "Carry       = %b",
            carry_debug
        );

        $display(
            "LED         = %b",
            led
        );

        $display("----------------------------------------------");


        // ====================================================
        // CPU FINAL STATE CHECKS
        // ====================================================
        //
        // Existing MiniRISC test_program.mem baseline:
        //
        // PC    = 11
        // Z     = 1
        // C     = 0
        // STATE = HALT = 100
        //
        // ====================================================


        if (pc_debug === 8'd11) begin

            $display(
                "PASS: Final PC = 11"
            );

            pass_count = pass_count + 1;

        end

        else begin

            $display(
                "FAIL: Final PC expected 11, got %0d",
                pc_debug
            );

            fail_count = fail_count + 1;

        end


        if (state_debug === 3'b100) begin

            $display(
                "PASS: CPU state = HALT"
            );

            pass_count = pass_count + 1;

        end

        else begin

            $display(
                "FAIL: CPU state expected 100, got %b",
                state_debug
            );

            fail_count = fail_count + 1;

        end


        if (
            zero_debug  === 1'b1 &&
            carry_debug === 1'b0
        ) begin

            $display(
                "PASS: Final flags Z=1 C=0"
            );

            pass_count = pass_count + 1;

        end

        else begin

            $display(
                "FAIL: Final flags expected Z=1 C=0, got Z=%b C=%b",
                zero_debug,
                carry_debug
            );

            fail_count = fail_count + 1;

        end


        // ====================================================
        // LED CHECK
        // ====================================================
        //
        // LED layout:
        //
        // [7:6] = PC[1:0]
        // [5:3] = state
        // [2]   = Carry
        // [1]   = Zero
        // [0]   = HALT
        //
        // PC=11   -> PC[1:0] = 11
        // state   -> 100
        // C       -> 0
        // Z       -> 1
        // HALT    -> 1
        //
        // Expected:
        //
        // 11_100_0_1_1 = 11100011
        //
        // ====================================================

        if (led === 8'b1110_0011) begin

            $display(
                "PASS: FPGA LED mapping = %b",
                led
            );

            pass_count = pass_count + 1;

        end

        else begin

            $display(
                "FAIL: LED expected 11100011, got %b",
                led
            );

            fail_count = fail_count + 1;

        end


        // ====================================================
        // UART RECEIVE
        // ====================================================

        $display("");
        $display(
            "Waiting for UART debug transmission..."
        );


        receive_uart_byte(
            received_uart_byte
        );


        $display(
            "UART received byte = %b (0x%02h)",
            received_uart_byte,
            received_uart_byte
        );


        // ====================================================
        // UART DEBUG BYTE CHECK
        // ====================================================
        //
        // UART byte layout:
        //
        // [7]   = HALT = 1
        // [6]   = Zero = 1
        // [5]   = Carry = 0
        // [4:2] = state = 100
        // [1:0] = PC = 11
        //
        // Expected:
        //
        // 1_1_0_100_11
        //
        // = 11010011
        //
        // = 0xD3
        //
        // ====================================================

        if (
            received_uart_byte ===
            8'b1101_0011
        ) begin

            $display(
                "PASS: UART debug byte = 0xD3"
            );

            pass_count = pass_count + 1;

        end

        else begin

            $display(
                "FAIL: UART expected 0xD3, got 0x%02h",
                received_uart_byte
            );

            fail_count = fail_count + 1;

        end


        // ====================================================
        // FINAL SUMMARY
        // ====================================================

        $display("");
        $display("==============================================");
        $display(" FPGA WRAPPER TEST SUMMARY");
        $display("==============================================");

        $display(
            "PASS = %0d",
            pass_count
        );

        $display(
            "FAIL = %0d",
            fail_count
        );


        if (fail_count == 0) begin

            $display("");
            $display(
                "OVERALL RESULT: PASS"
            );

            $display(
                "CPU + RESET + LEDs + UART VERIFIED"
            );

            $display("==============================================");
            $display("");

            $finish;

        end

        else begin

            $display("");
            $display(
                "OVERALL RESULT: FAIL"
            );

            $display("==============================================");
            $display("");

            // Unlike our early testbenches, use $fatal here.
            // That gives regression tools a non-zero failure.
            $fatal(
                1,
                "FPGA wrapper verification failed"
            );

        end

    end


    // ========================================================
    // TIMEOUT PROTECTION
    // ========================================================

    initial begin

        #100000;

        $fatal(
            1,
            "TIMEOUT: FPGA wrapper simulation did not finish"
        );

    end


endmodule