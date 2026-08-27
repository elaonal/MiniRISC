module instruction_memory #(
    parameter MEM_FILE = "programs/test_program.mem"
)(
    input  wire [7:0]  address,
    output wire [15:0] instruction
);

    reg [15:0] memory [0:255];

    integer i;

    initial begin

        // Fill unused instruction locations with NOP
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 16'b0000000000000000;
        end

        // Load selected MiniRISC program
        $readmemb(MEM_FILE, memory);

    end

    assign instruction = memory[address];

endmodule