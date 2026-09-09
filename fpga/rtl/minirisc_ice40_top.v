module minirisc_ice40_top #(
    parameter PROGRAM_FILE = "programs/test_program.mem",

    // Virtual implementation timing target.
    // This is NOT a claim about a physical board.
    parameter integer CLK_FREQ_HZ = 50_000_000,

    parameter integer UART_BAUD = 115200
)(
    input wire clk,
    input wire reset,

    output wire [7:0] led,
    output wire       uart_tx_pin
);


    // ========================================================
    // INTERNAL DEBUG SIGNALS
    // ========================================================
    //
    // These signals remain available inside the design,
    // but are deliberately NOT exposed as physical FPGA pins.
    // ========================================================

    wire [7:0]  pc_debug;
    wire [15:0] instruction_debug;
    wire [2:0]  state_debug;

    wire zero_debug;
    wire carry_debug;
    wire halted;


    // ========================================================
    // GENERIC MINIRISC FPGA INTEGRATION
    // ========================================================

    minirisc_fpga_top #(
        .PROGRAM_FILE(PROGRAM_FILE),
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .UART_BAUD(UART_BAUD)
    ) fpga_core (
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


endmodule