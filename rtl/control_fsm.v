module control_fsm (
    input  wire       clk,
    input  wire       reset,
    input  wire       halt_req,

    output reg  [2:0] state,

    output wire       fetch_state,
    output wire       decode_state,
    output wire       execute_state,
    output wire       writeback_state,
    output wire       halted
);

    reg [2:0] next_state;


    localparam FETCH     = 3'd0;
    localparam DECODE    = 3'd1;
    localparam EXECUTE   = 3'd2;
    localparam WRITEBACK = 3'd3;
    localparam HALT      = 3'd4;


    // State register
    always @(posedge clk) begin

        if (reset) begin
            state <= FETCH;
        end

        else begin
            state <= next_state;
        end

    end


    // Next-state logic
    always @(*) begin

        // Default: remain in current state
        next_state = state;

        case (state)

            FETCH: begin
                next_state = DECODE;
            end


            DECODE: begin

                if (halt_req) begin
                    next_state = HALT;
                end

                else begin
                    next_state = EXECUTE;
                end

            end


            EXECUTE: begin
                next_state = WRITEBACK;
            end


            WRITEBACK: begin
                next_state = FETCH;
            end


            HALT: begin
                next_state = HALT;
            end


            default: begin
                next_state = FETCH;
            end

        endcase

    end


    assign fetch_state     = (state == FETCH);
    assign decode_state    = (state == DECODE);
    assign execute_state   = (state == EXECUTE);
    assign writeback_state = (state == WRITEBACK);
    assign halted          = (state == HALT);


endmodule