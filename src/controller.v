module controller(
    input clk,
    input reset,

    input [6:0] opcode,

    input alu_zero,

    input branch,
    input branch_ne,
    input branch_lt,
    input branch_gte,
    input jal,
    input jalr,
    input auipc,
    input lui,

    output reg uart_rx_read_enable,
    output reg ir_write,
    output reg pc_write,
    output reg pc_src_branch,
    output reg pc_src_jal,
    output reg pc_src_jalr,
    output reg a_write,
    output reg b_write,
    output reg alu_out_write,
    output reg mdr_write,
    output reg reg_write,
    output reg instruction_read,
    output reg mem_read,
    output reg mem_write,
    output reg alu_src_imm,
    output reg [1:0] alu_src_a,
    output reg [2:0] writeback_src
);

localparam OP_RTYPE = 7'b0110011;
localparam OP_ITYPE = 7'b0010011;
localparam OP_LOAD = 7'b0000011;
localparam OP_STORE = 7'b0100011;
localparam OP_BRANCH = 7'b1100011;
localparam OP_JAL = 7'b1101111;
localparam OP_JALR = 7'b1100111;
localparam OP_LUI = 7'b0110111;
localparam OP_AUIPC = 7'b0010111;

localparam FETCH = 5'd0;
localparam FETCH_WAIT = 5'd16;
localparam DECODE = 5'd1;
localparam R_EXECUTE = 5'd2;
localparam R_WRITEBACK = 5'd3;
localparam I_EXECUTE = 5'd4;
localparam I_WRITEBACK = 5'd5;
localparam MEM_ADDRESS = 5'd6;
localparam MEM_READ = 5'd7;
localparam MEM_WRITEBACK = 5'd8;
localparam MEM_WAIT = 5'd15;
localparam MEM_WRITE = 5'd9;
localparam BRANCH = 5'd10;
localparam JAL = 5'd11;
localparam JALR = 5'd12;
localparam LUI = 5'd13;
localparam AUIPC = 5'd14;

reg [4:0] state;
reg [4:0] next_state;

wire take_branch;

// logical statement from hell
assign take_branch = branch && 
                    ((alu_zero && !(branch_ne || branch_lt || branch_gte)) || 
                    (!alu_zero && branch_ne) || (!alu_zero && branch_lt) || 
                    (alu_zero && branch_gte));

always @(posedge clk) begin
    if (reset)
        state <= FETCH;
    else
        state <= next_state;
end

always @(*) begin
    next_state = FETCH;
    case (state)

        FETCH:
            next_state = FETCH_WAIT;

        FETCH_WAIT:
            next_state = DECODE;

        DECODE: begin

            case (opcode)

                OP_RTYPE:
                    next_state = R_EXECUTE;

                OP_ITYPE:
                    next_state = I_EXECUTE;

                OP_LOAD:
                    next_state = MEM_ADDRESS;

                OP_STORE:
                    next_state = MEM_ADDRESS;

                OP_BRANCH:
                    next_state = BRANCH;

                OP_JAL:
                    next_state = JAL;

                OP_JALR:
                    next_state = JALR;

                OP_LUI:
                    next_state = LUI;

                OP_AUIPC:
                    next_state = AUIPC;

                default:
                    next_state = FETCH;

            endcase

        end

        R_EXECUTE:
            next_state = R_WRITEBACK;

        R_WRITEBACK:
            next_state = FETCH;

        I_EXECUTE:
            next_state = I_WRITEBACK;

        I_WRITEBACK:
            next_state = FETCH;

        MEM_ADDRESS: begin

            next_state = MEM_READ;

        end

        MEM_READ:
            if (opcode == OP_LOAD)
                next_state = MEM_WAIT;
            else
                next_state = MEM_WRITE;

        MEM_WAIT:
            next_state = MEM_WRITEBACK;

        MEM_WRITEBACK:
            next_state = FETCH;

        MEM_WRITE:
            next_state = FETCH;

        BRANCH:
            next_state = FETCH;

        JAL:
            next_state = FETCH;

        JALR:
            next_state = FETCH;

        LUI:
            next_state = FETCH;

        AUIPC:
            next_state = FETCH;

        default:
            next_state = FETCH;

    endcase
end

always @(*) begin

    uart_rx_read_enable = 1'b0;
    ir_write = 1'b0;
    pc_write = 1'b0;
    pc_src_branch = 1'b0;
    pc_src_jal = 1'b0;
    pc_src_jalr = 1'b0;
    a_write = 1'b0;
    b_write = 1'b0;
    alu_out_write = 1'b0;
    mdr_write = 1'b0;
    reg_write = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    alu_src_imm = 1'b0;
    alu_src_a = 2'b00;
    writeback_src = 3'b000;
    instruction_read = 1'b0;

    case (state)

        FETCH: begin

            instruction_read = 1'b1;

        end

        FETCH_WAIT: begin

            ir_write = 1'b1;
            pc_write = 1'b1;

        end

        DECODE: begin

            a_write = 1'b1;
            b_write = 1'b1;

        end

        R_EXECUTE: begin

            alu_src_a = 2'b01;

            alu_out_write = 1'b1;

        end

        R_WRITEBACK: begin

            reg_write = 1'b1;

            writeback_src = 3'b000;

        end


        I_EXECUTE: begin

            alu_src_a = 2'b01;

            alu_src_imm = 1'b1;

            alu_out_write = 1'b1;

        end

        I_WRITEBACK: begin

            reg_write = 1'b1;

            writeback_src = 3'b000;

        end


        MEM_ADDRESS: begin

            alu_src_a = 2'b01;

            alu_src_imm = 1'b1;

            alu_out_write = 1'b1;

        end

        MEM_READ: begin

            mem_read = 1'b1;
            uart_rx_read_enable = 1'b1;

        end

        MEM_WAIT: begin

            mdr_write = 1'b1;

        end

        MEM_WRITEBACK: begin

            reg_write = 1'b1;

            writeback_src = 3'b001;

        end

        MEM_WRITE: begin

            mem_write = 1'b1;

        end

        BRANCH: begin

            if (take_branch)
                pc_write = 1'b1;
            
            alu_src_a = 2'b01;

            pc_src_branch = 1'b1;

        end

        JAL: begin

            pc_write = 1'b1;

            pc_src_jal = 1'b1;

            reg_write = 1'b1;

            writeback_src = 3'b010;

        end

        JALR: begin

            pc_write = 1'b1;

            pc_src_jalr = 1'b1;

            reg_write = 1'b1;

            writeback_src = 3'b010;

        end

        LUI: begin

            reg_write = 1'b1;

            writeback_src = 3'b011;

        end

        AUIPC: begin

            reg_write = 1'b1;

            writeback_src = 3'b100;

        end

    endcase
end

endmodule