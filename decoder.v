module decoder(
    input [31:0] instruction,

    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,

    output reg [3:0] alu_control,

    output reg reg_write,
    output reg alu_src,
    output reg [2:0] imm_type,

    output reg mem_to_reg,
    output reg mem_read,
    output reg mem_write,
    output reg mem_load_signed,
    output reg [2:0] mem_size_bytes,

    output reg branch,
    output reg branch_ne,
    output reg branch_lt,
    output reg branch_gte,

    output reg jal,
    output reg jalr,

    output reg auipc,
    output reg lui
);

wire[6:0] opcode;
wire[2:0] funct3;
wire[6:0] funct7;

assign funct7 = instruction[31:25];
assign rs2 = instruction[24:20];
assign rs1 = instruction[19:15];
assign funct3 = instruction[14:12];
assign rd = instruction[11:7];
assign opcode = instruction[6:0];

always @(*) begin
    alu_control = 4'b0000;
    reg_write = 1'b0;
    alu_src = 1'b0;
    imm_type = 3'b000;
    mem_to_reg = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    mem_load_signed = 1'b0;
    mem_size_bytes = 3'b000;
    branch = 1'b0;
    branch_ne = 1'b0;
    branch_lt = 1'b0;
    branch_gte = 1'b0;
    jal = 1'b0;
    jalr = 1'b0;
    auipc = 1'b0;
    lui = 1'b0;


    case (opcode)
        // register arithmetic
        7'b0110011: begin

            // set alu_src LOW for R-type
            alu_src = 1'b0;
            reg_write = 1'b1;
            imm_type = 3'b000;


            case (funct3)
                
                3'b000: begin
                    if (funct7 == 7'h20)
                        // sub 
                        alu_control = 4'b0001;
                    else
                        // add
                        alu_control = 4'b0000;
                end

                // sll
                3'b001:
                        alu_control = 4'b0101;

                // slt
                3'b010:
                    alu_control = 4'b1000;

                // sltu
                3'b011:
                    alu_control = 4'b1001;

                // xor
                3'b100:
                    alu_control = 4'b0100;

                3'b101: begin
                    if (funct7 == 7'b0100000)
                        // sra
                        alu_control = 4'b0111; 
                    else
                        // srl
                        alu_control = 4'b0110;
                end
                
                // or
                3'b110:
                    alu_control = 4'b0011;

                // and
                3'b111:
                    alu_control = 4'b0010;

                default:
                    alu_control = 4'b0000;
            
            endcase
        end

        // immediate arithmetic
        7'b0010011: begin

            // set alu_src HIGH for i-type
            alu_src = 1'b1;
            reg_write = 1'b1;
            imm_type = 3'b000;


            case(funct3) 
                // addi
                3'b000:
                    alu_control = 4'b0000;

                // slli
                3'b001:
                    alu_control = 4'b0101;

                // slti
                3'b010:
                    alu_control = 4'b1000;

                // sltiu
                3'b011:
                    alu_control = 4'b1001;

                // xori
                3'b100:
                    alu_control = 4'b0100;

                3'b101: begin
                    if (funct7 == 7'b0100000)
                        // srai
                        alu_control = 4'b0111; 
                    else
                        // srli
                        alu_control = 4'b0110; 
                end

                // ori
                3'b110:
                    alu_control = 4'b0011;

                // andi
                3'b111:
                    alu_control = 4'b0010;

                default:
                    alu_control = 4'b0000;


            endcase
        end

        // immediate loads

        7'b0000011: begin

            alu_src = 1'b1;
            reg_write = 1'b1;
            // i-type
            imm_type = 3'b000;


            case (funct3) 

                // lb
                3'b000: begin
                    mem_to_reg = 1'b1;
                    mem_read = 1'b1;
                    alu_control = 4'b0000;
                    mem_size_bytes = 3'b001;
                    mem_load_signed = 1'b1;
                end

                // lh
                3'b001: begin
                    mem_to_reg = 1'b1;
                    mem_read = 1'b1;
                    alu_control = 4'b0000;
                    mem_size_bytes = 3'b010;
                    mem_load_signed = 1'b1;
                end


                // lw
                3'b010: begin
                    mem_to_reg = 1'b1;
                    mem_read = 1'b1;
                    alu_control = 4'b0000;
                    mem_size_bytes = 3'b100;
                    mem_load_signed = 1'b1;
                end
                
                // lbu
                3'b100: begin
                    mem_to_reg = 1'b1;
                    mem_read = 1'b1;
                    alu_control = 4'b0000;
                    mem_size_bytes = 3'b001;
                    mem_load_signed = 1'b0;
                end

                // lhu
                3'b101: begin
                    mem_to_reg = 1'b1;
                    mem_read = 1'b1;
                    alu_control = 4'b0000;
                    mem_size_bytes = 3'b010;
                    mem_load_signed = 1'b0;
                end

                default:
                    alu_control = 4'b0000;
            endcase

        end

        // immediate stores
        7'b0100011: begin
            
            alu_src = 1'b1;
            // s-type immediate
            imm_type = 3'b001;


            case (funct3) 

                // sw
                3'b010: begin
                    mem_write = 1'b1;
                    mem_read = 1'b0;
                    alu_control = 4'b0000;
                    mem_size_bytes = 3'b100;
                end

                // sh
                3'b001: begin
                    mem_write = 1'b1;
                    mem_read = 1'b0;
                    alu_control = 4'b0000;
                    mem_size_bytes = 3'b010;
                end

                // sb
                3'b000: begin
                    mem_write = 1'b1;
                    mem_read = 1'b0;
                    alu_control = 4'b0000;
                    mem_size_bytes = 3'b001;
                end

                default:
                    alu_control = 4'b0000;
            endcase
        end


        // branch
        7'b1100011: begin
            
            // alu_src is false because we need to compare rs1 and rs2
            alu_src = 1'b0;
            // b-type
            imm_type = 3'b010;
            // branch = 1'b1;

            case (funct3)
                // BEQ
                3'b000: begin
                    alu_control = 4'b0001;
                    branch = 1'b1;
                    branch_ne = 1'b0;
                end

                // BNE
                3'b001: begin
                    alu_control = 4'b0001;
                    branch = 1'b1;
                    branch_ne = 1'b1;
                end

                // blt
                3'b100: begin
                    alu_control = 4'b1000;
                    branch = 1'b1;
                    branch_lt = 1'b1;
                end

                // bge
                3'b101: begin
                    alu_control = 4'b1000;
                    branch = 1'b1;
                    branch_gte = 1'b1;
                end

                // bltu
                3'b110: begin
                    alu_control = 4'b1001;
                    branch = 1'b1;
                    branch_lt = 1'b1;
                end

                // bgeu
                3'b111: begin
                    alu_control = 4'b1001;
                    branch = 1'b1;
                    branch_gte = 1'b1;
                end

                default:
                    alu_control = 4'b0000;
            endcase
        end

        7'b1101111: begin
            alu_src = 1'b0;
            // j-type
            imm_type = 3'b100;
            reg_write = 1'b1;

            // JAL is the only j-type instruction

            // set alu to ADD but we aren't doing anything with it
            alu_control = 4'b0000;
            jal = 1'b1;

            
        end

        // JALR
        7'b1100111: begin
            alu_src = 1'b1;
            // i-type
            imm_type = 3'b000;
            reg_write = 1'b1;

            alu_control = 4'b0000;
            jalr = 1'b1;
        end

        // AUIPC
        7'b0010111: begin
            alu_src = 1'b1;
            // u-type
            imm_type = 3'b011;
            reg_write = 1'b1;
            
            // addition doesnt do anything;
            alu_control = 4'b0000;
            auipc = 1'b1;
        end

        // LUI
        7'b0110111: begin
            alu_src = 1'b1;
            // u-type
            imm_type = 3'b011;
            reg_write = 1'b1;

            alu_control = 4'b0000;
            lui = 1'b1;
        end    


        default: begin
            alu_control = 4'b0000;
            reg_write = 1'b0;
            alu_src = 1'b0;
            imm_type = 3'b000;

        end


    endcase
end

endmodule