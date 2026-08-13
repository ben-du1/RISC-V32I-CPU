module register_file(
    input clk,
    input write_enable,
    input reset,

    input [4:0] rs1,
    input [4:0] rs2,
    input [31:0] write_data,
    input [4:0] write_address,

    output [31:0] read_data1,
    output [31:0] read_data2,


    // debug
    output [31:0] debug_x1,
    output [31:0] debug_x2,
    output [31:0] debug_x3,
    output [31:0] debug_x4,
    output [31:0] debug_x5,
    output [31:0] debug_x6,
    output [31:0] debug_x7,
    output [31:0] debug_x8,
    output [31:0] debug_x9,
    output [31:0] debug_x10,
    output [31:0] debug_x11
);

    reg [31:0] registers [0:31];

    // double ternary to establish write-first 
    assign read_data1 = (rs1 == 5'h0) ? 32'h0 :  registers[rs1];
    assign read_data2 = (rs2 == 5'h0) ? 32'h0 :  registers[rs2];
    // assign read_data1 = (rs1 == 5'h0) ? 32'h0 : (write_enable && write_address == rs1) ? write_data : registers[rs1];
    // assign read_data2 = (rs2 == 5'h0) ? 32'h0 : (write_enable && write_address == rs2) ? write_data : registers[rs2];


    // debug
    assign debug_x1 = registers[1];
    assign debug_x2 = registers[2];
    assign debug_x3 = registers[3];
    assign debug_x4 = registers[4];
    assign debug_x5 = registers[5];
    assign debug_x6 = registers[6];
    assign debug_x7 = registers[7];
    assign debug_x8 = registers[8];
    assign debug_x9 = registers[9];
    assign debug_x10 = registers[10];
    assign debug_x11 = registers[11];

    integer i;

    always @(posedge clk) begin

        if (reset) begin
            for (i =0; i < 32; i = i+1) begin
                registers[i] <= 32'h0;
            end
        end

        else if (write_enable && write_address != 5'h00) begin
            registers[write_address] <= write_data;
        end
    end
endmodule