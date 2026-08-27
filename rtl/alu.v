module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] op,
    output reg  [7:0] result,
    output reg        zero,
    output reg        carry
);

always @(*) begin

    carry = 1'b0;

    case (op)

        3'b000: begin
            {carry, result} = a + b;
        end

        3'b001: begin
            result = a - b;
        end

        3'b010: begin
            result = a & b;
        end

        3'b011: begin
            result = a | b;
        end

        3'b100: begin
            result = a ^ b;
        end

        default: begin
            result = 8'b00000000;
        end

    endcase

    zero = (result == 8'b00000000);

end

endmodule