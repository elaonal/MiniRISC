`timescale 1ns/1ps

module sv_enum_test;

    typedef enum logic [2:0] {
        FETCH     = 3'd0,
        DECODE    = 3'd1,
        EXECUTE   = 3'd2,
        WRITEBACK = 3'd3,
        HALT      = 3'd4
    } state_t;

    state_t state;

    initial begin

        $display("");
        $display("MINIRISC SYSTEMVERILOG ENUM TEST");

        state = FETCH;
        #10;
        $display("State value = %b", state);

        state = DECODE;
        #10;
        $display("State value = %b", state);

        state = EXECUTE;
        #10;
        $display("State value = %b", state);

        state = WRITEBACK;
        #10;
        $display("State value = %b", state);

        state = HALT;
        #10;
        $display("State value = %b", state);

        $finish;

    end

endmodule