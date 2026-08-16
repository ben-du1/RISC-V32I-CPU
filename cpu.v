module cpu (
    input wire clk,
    input wire reset,
    input wire rx,
    input wire gpio_in,

    output wire gpio_out,
    output wire tx
);

// control
wire ir_write;
wire pc_write;
wire pc_src_branch;
wire pc_src_jal;
wire pc_src_jalr;
wire a_write;
wire b_write;
wire alu_out_write;
wire mdr_write;
wire reg_write;
wire mem_read;
wire mem_format;
wire mem_write;

wire alu_src_imm;
wire [1:0] alu_src_a;

wire [2:0] writeback_src;

wire [3:0] alu_control;
wire [2:0] imm_type;
wire mem_load_signed;
wire [2:0] mem_size_bytes;
wire alu_zero;

wire branch;
wire branch_ne;
wire branch_lt;
wire branch_gte;
wire jal;
wire jalr;
wire auipc;
wire lui;

wire [31:0] ir_data;
wire [31:0] instruction_memory_data;
wire [31:0] data_memory_data;
wire [31:0] memory_address;
wire [31:0] memory_write_data;
wire [31:0] alu_result;
wire [31:0] pc;

wire [7:0] uart_tx_data;
wire uart_tx_start;
wire [7:0] uart_rx_data;
wire uart_rx_ready;
wire uart_rx_read;
wire uart_rx_read_enable;

wire [6:0] opcode;
assign opcode = ir_data[6:0];

controller controller_unit (
    .clk(clk),
    .reset(reset),

    .opcode(opcode),
    .alu_zero(alu_zero),

    .branch(branch),
    .branch_ne(branch_ne),
    .branch_lt(branch_lt),
    .branch_gte(branch_gte),

    .jal(jal),
    .jalr(jalr),

    .auipc(auipc),
    .lui(lui),

    .uart_rx_read_enable(uart_rx_read_enable),

    .ir_write(ir_write),
    .pc_write(pc_write),

    .pc_src_branch(pc_src_branch),
    .pc_src_jal(pc_src_jal),
    .pc_src_jalr(pc_src_jalr),

    .a_write(a_write),
    .b_write(b_write),

    .alu_out_write(alu_out_write),
    .mdr_write(mdr_write),

    .reg_write(reg_write),

    .mem_read(mem_read),
    .mem_format(mem_format),
    .mem_write(mem_write),

    .alu_src_imm(alu_src_imm),
    .alu_src_a(alu_src_a),

    .writeback_src(writeback_src)
);

decoder decoder_unit (
    .instruction(ir_data),

    .alu_control(alu_control),

    .imm_type(imm_type),

    .mem_load_signed(mem_load_signed),
    .mem_size_bytes(mem_size_bytes),

    .branch(branch),
    .branch_ne(branch_ne),
    .branch_lt(branch_lt),
    .branch_gte(branch_gte),

    .jal(jal),
    .jalr(jalr),

    .auipc(auipc),
    .lui(lui)
);

datapath datapath_unit (
    .clk(clk),
    .reset(reset),

    .ir_write(ir_write),

    .a_write(a_write),
    .b_write(b_write),

    .alu_out_write(alu_out_write),
    .mdr_write(mdr_write),

    .pc_write(pc_write),

    .pc_src_branch(pc_src_branch),
    .pc_src_jal(pc_src_jal),
    .pc_src_jalr(pc_src_jalr),

    .alu_src_imm(alu_src_imm),
    .alu_src_a(alu_src_a),

    .alu_control(alu_control),

    .reg_write(reg_write),

    .writeback_src(writeback_src),

    .imm_type(imm_type),

    .instruction_memory_data(instruction_memory_data),
    .ir_data(ir_data),
    .data_memory_data(data_memory_data),

    .memory_address(memory_address),
    .memory_write_data(memory_write_data),

    .alu_result(alu_result),
    .alu_zero(alu_zero),

    .pc(pc)
);

instruction_memory instruction_memory_unit (
    .address(pc),
    .instruction(instruction_memory_data)
);

data_memory data_memory_unit (
    .clk(clk),
    .reset(reset),

    .mem_write(mem_write),
    .mem_read(mem_read),
    .mem_format(mem_format),

    .address(memory_address),
    .write_data(memory_write_data),

    .read_data(data_memory_data),

    .mem_size_bytes(mem_size_bytes),
    .mem_load_signed(mem_load_signed),

    .uart_tx_data(uart_tx_data),
    .uart_tx_start(uart_tx_start),

    .uart_rx_ready(uart_rx_ready),
    .uart_rx_read(uart_rx_read),
    .uart_rx_data(uart_rx_data),
    .uart_rx_read_enable(uart_rx_read_enable),

    .gpio_in(gpio_in),
    .gpio_out(gpio_out)
);

uart uart_unit (
    .clk(clk),
    .reset(reset),

    .uart_tx_data(uart_tx_data),
    .uart_tx_start(uart_tx_start),

    .tx(tx),

    .uart_rx_ready(uart_rx_ready),
    .uart_rx_read(uart_rx_read),
    .uart_rx_data(uart_rx_data),

    .rx(rx)
);

endmodule