// module singlecycle_cpu(
//     input clk,
//     input reset,
//     input rx,
//     input gpio_in,
//     output gpio_out,
//     output wire tx
// );

// wire [31:0] pc;
// wire [31:0] next_pc;
// wire [31:0] instruction;
// wire [4:0] rs1;
// wire [4:0] rs2;
// wire [4:0] rd;

// wire [3:0] alu_control;

// wire reg_write;
// wire alu_src;

// wire [2:0] imm_type;

// wire mem_to_reg;

// wire [31:0] read_data1;
// wire [31:0] read_data2;

// wire [31:0] write_data;

// // debug
// wire [31:0] debug_x1;
// wire [31:0] debug_x2;
// wire [31:0] debug_x3;
// wire [31:0] debug_x4;
// wire [31:0] debug_x5;
// wire [31:0] debug_x6;
// wire [31:0] debug_x7;
// wire [31:0] debug_x8;
// wire [31:0] debug_x9;
// wire [31:0] debug_x10;
// wire [31:0] debug_x11;

// wire [31:0] debug_0x100;
// wire [31:0] debug_0x104;
// wire [31:0] debug_0x108;
// wire [31:0] debug_0x10C;

// wire [31:0] debug_0x110;
// wire [31:0] debug_0x114;
// wire [31:0] debug_0x118;
// wire [31:0] debug_0x11C;

// wire [7:0] debug_0x120;
// wire [7:0] debug_0x121;

// wire [15:0] debug_0x122;
// wire [15:0] debug_0x124;

// wire [31:0] debug_0x128;
// wire [31:0] debug_0x12C;

// wire [31:0] immediate;

// wire mem_write;
// wire mem_read;
// wire [31:0] mem_address;
// wire [31:0] mem_write_data;
// wire [31:0] mem_read_data;
// wire [2:0] mem_size_bytes;
// wire mem_load_signed;

// wire [31:0] timer_count;

// wire [31:0] alu_input_A;
// wire [31:0] alu_input_B;
// wire [31:0] alu_result;
// wire alu_zero;

// wire branch;
// wire branch_ne;
// wire branch_lt;
// wire branch_gte;
// wire take_branch;
// wire [31:0] branch_target;

// wire jal;
// wire [31:0] jal_target;

// wire jalr;

// wire auipc;
// wire lui;

// wire [7:0] uart_tx_data;
// wire uart_tx_start;
// // wire tx;
// wire [7:0] uart_rx_data;
// wire uart_rx_ready;
// wire uart_rx_read;

// // crazy logical statement to determine if we should branch
// assign take_branch = branch && ((alu_zero && !(branch_ne || branch_lt || branch_gte)) || (!alu_zero && branch_ne) || (!alu_zero && branch_lt) || (alu_zero && branch_gte));
// assign branch_target = pc + immediate;

// assign jal_target = pc + immediate;

// // drop the last bit of jalr address to satisfy riscv requirement
// assign next_pc = jalr ? {alu_result[31:1],1'b0} : jal ? jal_target : take_branch ? branch_target : pc + 32'd4;

// pc pc_unit(
//     .clk(clk),
//     .reset(reset),
//     .next_pc(next_pc),
//     .pc(pc)
// );

// uart uart_unit(
//     .clk(clk),
//     .reset(reset),
//     .uart_tx_data(uart_tx_data),
//     .uart_tx_start(uart_tx_start),
//     .tx(tx),
//     .uart_rx_ready(uart_rx_ready),
//     .uart_rx_read(uart_rx_read),
//     .uart_rx_data(uart_rx_data),
//     .rx(rx)
// );


// instruction_memory instruction_memory_unit(
//     .address(pc),
//     .instruction(instruction)
// );

// decoder decoder_unit(
//     .instruction(instruction),
//     .rs1(rs1),
//     .rs2(rs2),
//     .rd(rd),
//     .alu_control(alu_control),
//     .reg_write(reg_write),
//     .alu_src(alu_src),
//     .imm_type(imm_type),
//     .mem_to_reg(mem_to_reg),
//     .mem_write(mem_write),
//     .mem_read(mem_read),
//     .mem_load_signed(mem_load_signed),
//     .mem_size_bytes(mem_size_bytes),
//     .branch(branch),
//     .branch_ne(branch_ne),
//     .branch_lt(branch_lt),
//     .branch_gte(branch_gte),
//     .jal(jal),
//     .jalr(jalr),
//     .auipc(auipc),
//     .lui(lui)
// );


// register_file registers_unit(
//     .clk(clk),
//     .reset(reset),
//     .write_enable(reg_write),
//     .rs1(rs1),
//     .rs2(rs2),

//     .write_data(write_data),
//     .write_address(rd),

//     .read_data1(read_data1),
//     .read_data2(read_data2),
//     .debug_x1(debug_x1),
//     .debug_x2(debug_x2),
//     .debug_x3(debug_x3),
//     .debug_x4(debug_x4),
//     .debug_x5(debug_x5),
//     .debug_x6(debug_x6),
//     .debug_x7(debug_x7),
//     .debug_x8(debug_x8),
//     .debug_x9(debug_x9),
//     .debug_x10(debug_x10),
//     .debug_x11(debug_x11)
// );


// imm_gen imm_gen_unit(
//     .instruction(instruction),
//     .imm_type(imm_type),
//     .immediate(immediate)
// );


// data_memory data_memory_unit(
//     .clk(clk),
//     .reset(reset),
//     .mem_write(mem_write),
//     .mem_read(mem_read),
//     .address(mem_address),
//     .write_data(mem_write_data),
//     .read_data(mem_read_data),
//     .mem_size_bytes(mem_size_bytes),
//     .mem_load_signed(mem_load_signed),

//     .uart_tx_data(uart_tx_data),
//     .uart_tx_start(uart_tx_start),
//     .uart_rx_ready(uart_rx_ready),
//     .uart_rx_read(uart_rx_read),
//     .uart_rx_data(uart_rx_data),

//     .gpio_in(gpio_in),
//     .gpio_out(gpio_out),

//     .timer_count(timer_count),

//     .debug_0x100(debug_0x100),
//     .debug_0x104(debug_0x104),
//     .debug_0x108(debug_0x108),
//     .debug_0x10C(debug_0x10C),

//     .debug_0x110(debug_0x110),
//     .debug_0x114(debug_0x114),
//     .debug_0x118(debug_0x118),
//     .debug_0x11C(debug_0x11C),

//     .debug_0x120(debug_0x120),
//     .debug_0x121(debug_0x121),

//     .debug_0x122(debug_0x122),
//     .debug_0x124(debug_0x124),

//     .debug_0x128(debug_0x128),
//     .debug_0x12C(debug_0x12C)
// );

// assign alu_input_A = auipc ? pc : read_data1;
// assign alu_input_B = alu_src ? immediate : read_data2;

// alu alu_unit(
//     .alu_control(alu_control),
//     .A(alu_input_A),
//     .B(alu_input_B),
//     .result(alu_result),
//     .zero(alu_zero)
// );

// assign mem_address = alu_result;
// assign mem_write_data = read_data2;

// // goofy ternary mux from hell
// assign write_data = lui ? immediate :
//                     auipc ? pc + immediate : 
//                     (jal || jalr) ? (pc + 32'd4) : 
//                     mem_to_reg ? mem_read_data : 
//                     alu_result ; // if reading from memory, send the value at memaddress + immediate

// endmodule