module data_memory (
    input  wire       clk,

    input  wire       mem_read,
    input  wire       mem_write,

    input  wire [7:0] address,
    input  wire [7:0] write_data,

    output wire [7:0] read_data
);

    reg [7:0] memory [0:255];

    integer i;


    // Initialise memory to zero for simulation
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'b00000000;
        end
    end


    // Combinational read
    assign read_data =
        mem_read ? memory[address] : 8'b00000000;


    // Clocked write
    always @(posedge clk) begin

        if (mem_write) begin
            memory[address] <= write_data;
        end

    end

endmodule