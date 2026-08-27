module status_register (
    input  wire clk,
    input  wire reset,
    input  wire write_enable,

    input  wire zero_in,
    input  wire carry_in,

    output reg  zero_flag,
    output reg  carry_flag
);

    always @(posedge clk) begin

        if (reset) begin
            zero_flag  <= 1'b0;
            carry_flag <= 1'b0;
        end

        else if (write_enable) begin
            zero_flag  <= zero_in;
            carry_flag <= carry_in;
        end

    end

endmodule