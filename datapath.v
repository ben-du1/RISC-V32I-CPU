module datapath (
    input clk,
    input reset,

    input ir_write,
    input a_write,
    input b_write,
    input alu_out_write,
    input mdr_write,
    input pc_write,
    input pc_src_branch,
    input pc_src_jal,
    input pc_src_jalr,
    input [2:0] imm_type,
    input alu_src_imm,
    input [1:0] alu_src_a,
    input [3:0] alu_control,
    input reg_write,
    input [2:0] writeback_src,
    input [31:0] instruction_memory_data,
    input[31:0] data_memory_data,

    output [31:0] ir_data,
    output [31:0] memory_address,
    output [31:0] memory_write_data,
    output [31:0] alu_result,
    output alu_zero,
    output [31:0] pc
);

reg [31:0] ir;
reg [31:0] A;
reg [31:0] B;
reg [31:0] alu_out;
reg [31:0] mdr;

wire [31:0] register_data1;
wire [31:0] register_data2;
reg [31:0] register_write_data;

wire [31:0] immediate;

reg [31:0] alu_input_A;
reg [31:0] alu_input_B;

reg [31:0] pc_reg;
reg [31:0] old_pc;
assign pc = pc_reg;

wire [31:0] pc_plus_4;
wire [31:0] pc_branch;
wire [31:0] pc_jal;
wire [31:0] jalr_target;
wire [31:0] pc_jalr;
reg  [31:0] pc_next;

assign pc_plus_4 = pc_reg + 32'd4;
assign pc_branch = old_pc + immediate;
assign pc_jal    = old_pc + immediate;
assign jalr_target = A + immediate;
assign pc_jalr   = {jalr_target[31:1],1'b0};

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

assign rs1 = ir[19:15];
assign rs2 = ir[24:20];
assign rd = ir[11:7];

assign ir_data = ir;


imm_gen imm_gen_unit (
    .instruction(ir_data),
    .imm_type(imm_type),
    .immediate(immediate)
);

register_file register_file_unit (
    .clk(clk),
    .reset(reset),
    .write_enable(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .write_data(register_write_data),
    .write_address(rd),
    .read_data1(register_data1),
    .read_data2(register_data2)
);

always @(*) begin
    case (writeback_src)
        3'b000: register_write_data = alu_out;
        3'b001: register_write_data = mdr;
        3'b010: register_write_data = old_pc + 32'd4;
        3'b011: register_write_data = immediate;
        3'b100: register_write_data = old_pc + immediate;
        default: register_write_data = 32'b0;
    endcase
end

always @(posedge clk) begin
    if (reset) begin
        ir     <= 32'b0;
        A      <= 32'b0;
        B      <= 32'b0;
        alu_out <= 32'b0;
        mdr    <= 32'b0;
        pc_reg <= 32'b0;
        old_pc <= 32'b0;
    end else begin 
        if (ir_write) begin
            ir <= instruction_memory_data;
            old_pc <= pc_reg;
        end
        if (a_write)
            A <= register_data1;
        if (b_write)
            B <= register_data2;
        if (alu_out_write)
            alu_out <= alu_result;
        if (mdr_write)
            mdr <= data_memory_data;
        if (pc_write)
            pc_reg <= pc_next;
    end
end

always @(*) begin
    case (alu_src_a)
        2'b00:
            alu_input_A = pc_reg;
        2'b01:
            alu_input_A = A;
        default:
            alu_input_A = 32'b0;
    endcase
end

always @(*) begin
    if (alu_src_imm)
        alu_input_B = immediate;
    else
        alu_input_B = B;
end

always @(*) begin
    if (pc_src_branch)
        pc_next = pc_branch;
    else if (pc_src_jal)
        pc_next = pc_jal;
    else if (pc_src_jalr)
        pc_next = pc_jalr;
    else
        pc_next = pc_plus_4;
end

alu alu_unit(
    .alu_control(alu_control),
    .A(alu_input_A),
    .B(alu_input_B),
    .result(alu_result),
    .zero(alu_zero)
);

assign memory_address = alu_out;
assign memory_write_data = B;


endmodule