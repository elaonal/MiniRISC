module instruction_memory #(
    parameter MEM_FILE = "programs/test_program_synth.mem"
)(
    input  wire [7:0]  address,
    output wire [15:0] instruction
);

    reg [15:0] memory [0:255];

    initial begin
        $readmemb(MEM_FILE, memory);
    end

    assign instruction = memory[address];

endmodule
