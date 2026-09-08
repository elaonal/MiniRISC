module uart_tx #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BAUD_RATE   = 115200
)(
    input  wire       clk,
    input  wire       reset,

    input  wire [7:0] data_in,
    input  wire       start,

    output reg        tx,
    output reg        busy
);


    // ========================================================
    // UART PARAMETERS
    // ========================================================

    localparam integer CLKS_PER_BIT =
        CLK_FREQ_HZ / BAUD_RATE;


    // ========================================================
    // INTERNAL REGISTERS
    // ========================================================

    reg [31:0] clk_count;
    reg [3:0]  bit_index;
    reg [7:0]  data_reg;


    // ========================================================
    // UART TRANSMITTER
    // ========================================================
    //
    // Frame:
    //
    // idle = 1
    //
    // start bit = 0
    // data bits = 8 bits, LSB first
    // stop bit  = 1
    //
    // ========================================================

    always @(posedge clk) begin

        if (reset) begin

            tx        <= 1'b1;
            busy      <= 1'b0;

            clk_count <= 32'd0;
            bit_index <= 4'd0;

            data_reg  <= 8'd0;

        end

        else begin

            // ------------------------------------------------
            // IDLE
            // ------------------------------------------------

            if (!busy) begin

                tx        <= 1'b1;
                clk_count <= 32'd0;
                bit_index <= 4'd0;


                if (start) begin

                    data_reg <= data_in;

                    busy <= 1'b1;

                    // Start bit
                    tx <= 1'b0;

                end

            end


            // ------------------------------------------------
            // TRANSMITTING
            // ------------------------------------------------

            else begin

                if (clk_count == CLKS_PER_BIT - 1) begin

                    clk_count <= 32'd0;


                    case (bit_index)

                        // First data bit
                        4'd0: begin

                            tx <= data_reg[0];

                            bit_index <= 4'd1;

                        end


                        4'd1: begin

                            tx <= data_reg[1];

                            bit_index <= 4'd2;

                        end


                        4'd2: begin

                            tx <= data_reg[2];

                            bit_index <= 4'd3;

                        end


                        4'd3: begin

                            tx <= data_reg[3];

                            bit_index <= 4'd4;

                        end


                        4'd4: begin

                            tx <= data_reg[4];

                            bit_index <= 4'd5;

                        end


                        4'd5: begin

                            tx <= data_reg[5];

                            bit_index <= 4'd6;

                        end


                        4'd6: begin

                            tx <= data_reg[6];

                            bit_index <= 4'd7;

                        end


                        4'd7: begin

                            tx <= data_reg[7];

                            bit_index <= 4'd8;

                        end


                        // Stop bit
                        4'd8: begin

                            tx <= 1'b1;

                            bit_index <= 4'd9;

                        end


                        // Transmission finished
                        4'd9: begin

                            tx   <= 1'b1;
                            busy <= 1'b0;

                            bit_index <= 4'd0;

                        end


                        default: begin

                            tx   <= 1'b1;
                            busy <= 1'b0;

                        end

                    endcase

                end

                else begin

                    clk_count <= clk_count + 1;

                end

            end

        end

    end


endmodule