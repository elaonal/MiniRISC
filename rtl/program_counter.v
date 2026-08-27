module program_counter (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire       load,
    input  wire [7:0] next_pc,
    output reg  [7:0] pc
);

    always @(posedge clk) begin

        if (reset) begin
            pc <= 8'b00000000;
        end

        else if (enable) begin

            if (load) begin
                pc <= next_pc;
            end

            else begin
                pc <= pc + 8'd1;
            end

        end

    end

endmodule