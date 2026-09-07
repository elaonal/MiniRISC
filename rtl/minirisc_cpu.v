module minirisc_cpu #(
    parameter PROGRAM_FILE = "programs/test_program_synth.mem"
)(
    input  wire        clk,
    input  wire        reset,

    // Debug outputs
    output wire [7:0]  pc_debug,
    output wire [15:0] instruction_debug,
    output wire [2:0]  state_debug,
    output wire        zero_debug,
    output wire        carry_debug,
    output wire        halted
);


    // ============================================================
    // PROGRAM COUNTER SIGNALS
    // ============================================================

    wire [7:0] pc;

    wire       pc_enable;
    wire       pc_load;
    wire [7:0] next_pc;


    // ============================================================
    // INSTRUCTION MEMORY / INSTRUCTION REGISTER
    // ============================================================

    wire [15:0] instruction_from_memory;
    wire [15:0] current_instruction;


    // ============================================================
    // INSTRUCTION DECODER SIGNALS
    // ============================================================

    wire [3:0] opcode;
    wire [2:0] rd;
    wire [2:0] rs;
    wire [7:0] immediate;


    // ============================================================
    // CONTROL UNIT SIGNALS
    // ============================================================

    wire [2:0] alu_op;
    wire [1:0] wb_sel;

    wire reg_write_req;
    wire flag_write_req;

    wire mem_read_req;
    wire mem_write_req;

    wire jump;
    wire jump_zero;

    wire halt_req;


    // ============================================================
    // FSM SIGNALS
    // ============================================================

    wire [2:0] state;

    wire fetch_state;
    wire decode_state;
    wire execute_state;
    wire writeback_state;


    // ============================================================
    // REGISTER FILE SIGNALS
    // ============================================================

    wire [7:0] rd_value;
    wire [7:0] rs_value;

    wire       register_write_enable;

    reg [7:0] writeback_data;


    // ============================================================
    // ALU SIGNALS
    // ============================================================

    wire [7:0] alu_result;

    wire alu_zero;
    wire alu_carry;


    // ============================================================
    // STATUS REGISTER SIGNALS
    // ============================================================

    wire zero_flag;
    wire carry_flag;

    wire flag_write_enable;


    // ============================================================
    // DATA MEMORY SIGNALS
    // ============================================================

    wire [7:0] memory_read_data;

    wire memory_write_enable;


    // ============================================================
    // PROGRAM COUNTER
    // ============================================================

    program_counter u_pc (
        .clk(clk),
        .reset(reset),

        .enable(pc_enable),
        .load(pc_load),
        .next_pc(next_pc),

        .pc(pc)
    );


    // ============================================================
    // INSTRUCTION MEMORY
    // ============================================================

    instruction_memory #(
        .MEM_FILE(PROGRAM_FILE)
    ) u_imem (
        .address(pc),
        .instruction(instruction_from_memory)
    );


    // ============================================================
    // INSTRUCTION REGISTER
    // ============================================================

    instruction_register u_ir (
        .clk(clk),
        .reset(reset),

        .load(fetch_state),

        .instruction_in(instruction_from_memory),
        .instruction_out(current_instruction)
    );


    // ============================================================
    // INSTRUCTION DECODER
    // ============================================================

    instruction_decoder u_decoder (
        .instruction(current_instruction),

        .opcode(opcode),
        .rd(rd),
        .rs(rs),
        .immediate(immediate)
    );


    // ============================================================
    // CONTROL UNIT
    // ============================================================

    control_unit u_control (
        .opcode(opcode),

        .alu_op(alu_op),
        .wb_sel(wb_sel),

        .reg_write_req(reg_write_req),
        .flag_write_req(flag_write_req),

        .mem_read_req(mem_read_req),
        .mem_write_req(mem_write_req),

        .jump(jump),
        .jump_zero(jump_zero),

        .halt(halt_req)
    );


    // ============================================================
    // CONTROL FSM
    // ============================================================

    control_fsm u_fsm (
        .clk(clk),
        .reset(reset),

        .halt_req(halt_req),

        .state(state),

        .fetch_state(fetch_state),
        .decode_state(decode_state),
        .execute_state(execute_state),
        .writeback_state(writeback_state),

        .halted(halted)
    );


    // ============================================================
    // REGISTER FILE
    // ============================================================

    register_file u_regfile (
        .clk(clk),
        .reset(reset),

        // Rd is operand A
        .read_addr1(rd),

        // Rs is operand B
        .read_addr2(rs),

        // Destination register
        .write_addr(rd),

        // Data selected by writeback MUX
        .write_data(writeback_data),

        // Physical register write enable
        .write_enable(register_write_enable),

        .read_data1(rd_value),
        .read_data2(rs_value)
    );


    // ============================================================
    // ALU
    // ============================================================

    alu u_alu (
        .a(rd_value),
        .b(rs_value),

        .op(alu_op),

        .result(alu_result),

        .zero(alu_zero),
        .carry(alu_carry)
    );


    // ============================================================
    // STATUS REGISTER
    // ============================================================

    status_register u_status (
        .clk(clk),
        .reset(reset),

        .write_enable(flag_write_enable),

        .zero_in(alu_zero),
        .carry_in(alu_carry),

        .zero_flag(zero_flag),
        .carry_flag(carry_flag)
    );


    // ============================================================
    // DATA MEMORY
    // ============================================================

    data_memory u_dmem (
        .clk(clk),

        .mem_read(mem_read_req),
        .mem_write(memory_write_enable),

        .address(immediate),

        // STORE Rd,address
        .write_data(rd_value),

        .read_data(memory_read_data)
    );


    // ============================================================
    // WRITEBACK MULTIPLEXER
    // ============================================================

    always @(*) begin

        case (wb_sel)

            // ALU result
            2'b00: begin
                writeback_data = alu_result;
            end


            // Immediate value
            2'b01: begin
                writeback_data = immediate;
            end


            // Data Memory
            2'b10: begin
                writeback_data = memory_read_data;
            end


            // Rs register value
            2'b11: begin
                writeback_data = rs_value;
            end


            default: begin
                writeback_data = 8'b00000000;
            end

        endcase

    end


    // ============================================================
    // REGISTER WRITE CONTROL
    // ============================================================

    // An instruction may request a register write,
    // but the actual write is only allowed during WRITEBACK.

    assign register_write_enable =
        writeback_state &&
        reg_write_req;


    // ============================================================
    // STATUS FLAG WRITE CONTROL
    // ============================================================

    // ADD, SUB, AND, OR, XOR and CMP can request
    // flag updates.
    //
    // The actual flags are captured during EXECUTE.

    assign flag_write_enable =
        execute_state &&
        flag_write_req;


    // ============================================================
    // DATA MEMORY WRITE CONTROL
    // ============================================================

    // STORE writes Data Memory during EXECUTE.

    assign memory_write_enable =
        execute_state &&
        mem_write_req;


    // ============================================================
    // PROGRAM COUNTER CONTROL
    // ============================================================

    // PC changes only once the current instruction
    // reaches WRITEBACK.

    assign pc_enable =
        writeback_state;


    // JMP:
    //     jump = 1
    //
    // JZ:
    //     jump_zero = 1
    //     AND stored Zero Flag = 1

    assign pc_load =
        writeback_state &&
        (
            jump ||
            (jump_zero && zero_flag)
        );


    // JMP/JZ destination comes from
    // instruction bits [7:0].

    assign next_pc =
        immediate;


    // ============================================================
    // DEBUG OUTPUTS
    // ============================================================

    assign pc_debug =
        pc;

    assign instruction_debug =
        current_instruction;

    assign state_debug =
        state;

    assign zero_debug =
        zero_flag;

    assign carry_debug =
        carry_flag;


endmodule