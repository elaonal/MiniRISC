module control_unit (
    input  wire [3:0] opcode,

    output reg  [2:0] alu_op,
    output reg  [1:0] wb_sel,

    output reg        reg_write_req,
    output reg        flag_write_req,

    output reg        mem_read_req,
    output reg        mem_write_req,

    output reg        jump,
    output reg        jump_zero,

    output reg        halt
);

    always @(*) begin

        // Default values
        alu_op         = 3'b000;
        wb_sel         = 2'b00;

        reg_write_req  = 1'b0;
        flag_write_req = 1'b0;

        mem_read_req   = 1'b0;
        mem_write_req  = 1'b0;

        jump            = 1'b0;
        jump_zero       = 1'b0;

        halt            = 1'b0;


        case (opcode)

            // NOP
            4'b0000: begin
            end


            // LDI Rd, immediate
            4'b0001: begin
                reg_write_req = 1'b1;
                wb_sel        = 2'b01;
            end


            // MOV Rd, Rs
            4'b0010: begin
                reg_write_req = 1'b1;
                wb_sel        = 2'b11;
            end


            // ADD Rd, Rs
            4'b0011: begin
                alu_op         = 3'b000;
                reg_write_req  = 1'b1;
                flag_write_req = 1'b1;
                wb_sel         = 2'b00;
            end


            // SUB Rd, Rs
            4'b0100: begin
                alu_op         = 3'b001;
                reg_write_req  = 1'b1;
                flag_write_req = 1'b1;
                wb_sel         = 2'b00;
            end


            // AND Rd, Rs
            4'b0101: begin
                alu_op         = 3'b010;
                reg_write_req  = 1'b1;
                flag_write_req = 1'b1;
                wb_sel         = 2'b00;
            end


            // OR Rd, Rs
            4'b0110: begin
                alu_op         = 3'b011;
                reg_write_req  = 1'b1;
                flag_write_req = 1'b1;
                wb_sel         = 2'b00;
            end


            // XOR Rd, Rs
            4'b0111: begin
                alu_op         = 3'b100;
                reg_write_req  = 1'b1;
                flag_write_req = 1'b1;
                wb_sel         = 2'b00;
            end


            // LOAD Rd, address
            4'b1000: begin
                reg_write_req = 1'b1;
                mem_read_req  = 1'b1;
                wb_sel        = 2'b10;
            end


            // STORE Rd, address
            4'b1001: begin
                mem_write_req = 1'b1;
            end


            // JMP address
            4'b1010: begin
                jump = 1'b1;
            end


            // JZ address
            4'b1011: begin
                jump_zero = 1'b1;
            end


            // CMP Rd, Rs
            4'b1100: begin
                alu_op         = 3'b001;
                flag_write_req = 1'b1;
            end


            // Reserved
            4'b1101: begin
            end


            // Reserved
            4'b1110: begin
            end


            // HALT
            4'b1111: begin
                halt = 1'b1;
            end


        endcase

    end

endmodule