`timescale 1ns/1ps

module data_memory_tb;

    reg        clk;

    reg        mem_read;
    reg        mem_write;

    reg  [7:0] address;
    reg  [7:0] write_data;

    wire [7:0] read_data;


    data_memory dut (
        .clk(clk),

        .mem_read(mem_read),
        .mem_write(mem_write),

        .address(address),
        .write_data(write_data),

        .read_data(read_data)
    );


    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin

        $dumpfile("sim/data_memory.vcd");
        $dumpvars(0, data_memory_tb);

        $display(
            "TIME CLK MR MW ADDRESS WRITE_DATA READ_DATA"
        );

        $monitor(
            "%4t  %b   %b  %b    %d       %d        %d",
            $time,
            clk,
            mem_read,
            mem_write,
            address,
            write_data,
            read_data
        );


        // Initial state
        mem_read   = 1;
        mem_write  = 0;
        address    = 8'd10;
        write_data = 8'd0;

        #10;


        // Prepare to write 42 to address 10
        write_data = 8'd42;
        mem_write  = 1;

        // Before rising edge, old value should remain
        #3;


        // Allow rising clock edge to occur
        #7;


        // Stop writing
        mem_write = 0;

        #10;


        // Disable reading
        mem_read = 0;

        #10;


        // Enable reading again
        mem_read = 1;

        #10;


        $finish;

    end

endmodule