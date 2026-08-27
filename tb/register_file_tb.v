`timescale 1ns/1ps

module register_file_tb;

    reg        clk;
    reg        reset;

    reg  [2:0] read_addr1;
    reg  [2:0] read_addr2;

    reg  [2:0] write_addr;
    reg  [7:0] write_data;
    reg        write_enable;

    wire [7:0] read_data1;
    wire [7:0] read_data2;


    register_file dut (
        .clk(clk),
        .reset(reset),

        .read_addr1(read_addr1),
        .read_addr2(read_addr2),

        .write_addr(write_addr),
        .write_data(write_data),
        .write_enable(write_enable),

        .read_data1(read_data1),
        .read_data2(read_data2)
    );


    // Clock generator
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end


    initial begin

        $dumpfile("sim/register_file.vcd");
        $dumpvars(0, register_file_tb);

        $display("TIME CLK RESET WE WA WD | RA1 RD1 | RA2 RD2");

        $monitor(
            "%4t   %b    %b   %b  %b %d | %b  %d | %b  %d",
            $time,
            clk,
            reset,
            write_enable,
            write_addr,
            write_data,
            read_addr1,
            read_data1,
            read_addr2,
            read_data2
        );


        // Initial values
        reset        = 1;
        write_enable = 0;

        write_addr   = 3'b000;
        write_data   = 8'd0;

        read_addr1   = 3'b010; // R2
        read_addr2   = 3'b011; // R3


        // Wait for a clock rising edge while reset is active
        #10;

        // Disable reset
        reset = 0;


        // Prepare to write 5 into R2
        write_addr   = 3'b010;
        write_data   = 8'd5;
        write_enable = 1;

        // At this moment R2 should STILL be 0
        #3;

        // Wait long enough for next rising clock edge
        #7;


        // Stop writing
        write_enable = 0;


        // Now prepare to write 9 into R3
        write_addr   = 3'b011;
        write_data   = 8'd9;
        write_enable = 1;

        #10;

        write_enable = 0;

        #10;

        $finish;

    end

endmodule 