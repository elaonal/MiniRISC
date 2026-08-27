module register_file (
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] read_addr1,
    input  wire [2:0] read_addr2,

    input  wire [2:0] write_addr,
    input  wire [7:0] write_data,
    input  wire       write_enable,

    output wire [7:0] read_data1,
    output wire [7:0] read_data2
);

    reg [7:0] registers [0:7];

    integer i;

    assign read_data1 = registers[read_addr1];
    assign read_data2 = registers[read_addr2];

    always @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < 8; i = i + 1) begin
                registers[i] <= 8'b00000000;
            end

        end
        else if (write_enable) begin

            registers[write_addr] <= write_data;

        end

    end

endmodule