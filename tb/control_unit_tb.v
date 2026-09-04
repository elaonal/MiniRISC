`timescale 1ns/1ps

module control_unit_tb;

reg [3:0] opcode;

wire [2:0] alu_op;
wire [1:0] wb_sel;

wire reg_write_req;
wire flag_write_req;

wire mem_read_req;
wire mem_write_req;

wire jump;
wire jump_zero;

wire halt;


control_unit dut (
    .opcode(opcode),

    .alu_op(alu_op),
    .wb_sel(wb_sel),

    .reg_write_req(reg_write_req),
    .flag_write_req(flag_write_req),

    .mem_read_req(mem_read_req),
    .mem_write_req(mem_write_req),

    .jump(jump),
    .jump_zero(jump_zero),

    .halt(halt)
);


initial begin

    $dumpfile("sim/control_unit.vcd");
    $dumpvars(0, control_unit_tb);

    $display(
        "OPCODE | ALU WB | RW FW MR MW | JMP JZ HALT"
    );

    $monitor(
        " %b   | %b  %b |  %b  %b  %b  %b |  %b   %b   %b",
        opcode,
        alu_op,
        wb_sel,
        reg_write_req,
        flag_write_req,
        mem_read_req,
        mem_write_req,
        jump,
        jump_zero,
        halt
    );


    // NOP
    opcode = 4'b0000;
    #10;

    // LDI
    opcode = 4'b0001;
    #10;

    // MOV
    opcode = 4'b0010;
    #10;

    // ADD
    opcode = 4'b0011;
    #10;

    // SUB
    opcode = 4'b0100;
    #10;

    // AND
    opcode = 4'b0101;
    #10;

    // OR
    opcode = 4'b0110;
    #10;

    // XOR
    opcode = 4'b0111;
    #10;

    // LOAD
    opcode = 4'b1000;
    #10;

    // STORE
    opcode = 4'b1001;
    #10;

    // JMP
    opcode = 4'b1010;
    #10;

    // JZ
    opcode = 4'b1011;
    #10;

    // CMP
    opcode = 4'b1100;
    #10;

    // Reserved opcode
    opcode = 4'b1101;
    #10;

    // Reserved opcode
    opcode = 4'b1110;
    #10;

    // HALT
    opcode = 4'b1111;
    #10;


    $finish;

end

endmodule