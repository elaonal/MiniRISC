module instruction_decoder (
    input  wire [15:0] instruction,

    output wire [3:0] opcode,
    output wire [2:0] rd,
    output wire [2:0] rs,
    output wire [7:0] immediate
);

    assign opcode    = instruction[15:12];
    assign rd        = instruction[11:9];
    assign rs        = instruction[8:6];
    assign immediate = instruction[7:0];

endmodule