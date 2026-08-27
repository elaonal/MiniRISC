module instruction_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        load,

    input  wire [15:0] instruction_in,
    output reg  [15:0] instruction_out
);

    always @(posedge clk) begin

        if (reset) begin
            instruction_out <= 16'b0000000000000000;
        end

        else if (load) begin
            instruction_out <= instruction_in;
        end

    end

endmodule