module reset_sync (
    input  wire clk,
    input  wire async_reset,
    output wire sync_reset
);

    // Two-stage synchroniser.
    //
    // Reset assertion is immediate.
    // Reset release is synchronised to the FPGA clock.

    reg [1:0] reset_ff;

    always @(posedge clk or posedge async_reset) begin

        if (async_reset) begin

            reset_ff <= 2'b11;

        end

        else begin

            reset_ff <= {
                reset_ff[0],
                1'b0
            };

        end

    end


    assign sync_reset = reset_ff[1];

endmodule