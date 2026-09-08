module minirisc_fpga_top #(
    parameter PROGRAM_FILE = "programs/test_program.mem",

    // These can later be changed for the actual FPGA board.
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer UART_BAUD   = 115200
)(
    input wire clk,

    // Physical asynchronous reset
    input wire reset,


    // ========================================================
    // FPGA OUTPUTS
    // ========================================================

    output wire [7:0] led,

    output wire       uart_tx_pin,


    // ========================================================
    // DEBUG OUTPUTS
    // ========================================================

    output wire [7:0]  pc_debug,
    output wire [15:0] instruction_debug,
    output wire [2:0]  state_debug,
    output wire        zero_debug,
    output wire        carry_debug,
    output wire        halted
);


    // ========================================================
    // INTERNAL RESET
    // ========================================================

    wire internal_reset;


    // ========================================================
    // UART SIGNALS
    // ========================================================

    wire [7:0] uart_debug_byte;

    reg        uart_start;

    wire       uart_busy;

    reg        halted_previous;


    // ========================================================
    // RESET SYNCHRONISER
    // ========================================================

    reset_sync reset_sync_inst (
        .clk(clk),
        .async_reset(reset),
        .sync_reset(internal_reset)
    );


    // ========================================================
    // MINIRISC CPU
    // ========================================================

    minirisc_cpu #(
        .PROGRAM_FILE(PROGRAM_FILE)
    ) cpu_inst (
        .clk(clk),
        .reset(internal_reset),

        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug),
        .state_debug(state_debug),
        .zero_debug(zero_debug),
        .carry_debug(carry_debug),
        .halted(halted)
    );


    // ========================================================
    // LED DEBUG MAPPING
    // ========================================================

    assign led[0] = halted;

    assign led[1] = zero_debug;

    assign led[2] = carry_debug;

    assign led[5:3] = state_debug;

    assign led[7:6] = pc_debug[1:0];


    // ========================================================
    // UART DEBUG BYTE
    // ========================================================
    //
    // Bit layout:
    //
    // [7]   HALT
    // [6]   Zero
    // [5]   Carry
    // [4:2] FSM state
    // [1:0] PC lower bits
    //
    // ========================================================

    assign uart_debug_byte = {
        halted,
        zero_debug,
        carry_debug,
        state_debug,
        pc_debug[1:0]
    };


    // ========================================================
    // HALT EDGE DETECTION
    // ========================================================
    //
    // Send exactly one UART byte when the CPU enters HALT.
    //
    // halted_previous remembers the previous clock-cycle state.
    //
    // halted = 1 and halted_previous = 0
    //
    // means:
    //
    //        rising edge of HALT
    //
    // ========================================================

    always @(posedge clk) begin

        if (internal_reset) begin

            halted_previous <= 1'b0;

            uart_start <= 1'b0;

        end

        else begin

            // uart_start is a one-clock pulse.
            uart_start <= 1'b0;


            if (
                halted &&
                !halted_previous &&
                !uart_busy
            ) begin

                uart_start <= 1'b1;

            end


            halted_previous <= halted;

        end

    end


    // ========================================================
    // UART TRANSMITTER
    // ========================================================

    uart_tx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(UART_BAUD)
    ) uart_tx_inst (
        .clk(clk),
        .reset(internal_reset),

        .data_in(uart_debug_byte),
        .start(uart_start),

        .tx(uart_tx_pin),
        .busy(uart_busy)
    );


endmodule