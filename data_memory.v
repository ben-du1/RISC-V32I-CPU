module data_memory(
    input clk,
    input reset,
    input mem_write,
    input mem_read,
    input [2:0] mem_size_bytes,
    input mem_load_signed,

    input [31:0] address,
    input [31:0] write_data,

    input [7:0] uart_rx_data,
    input uart_rx_ready,
    input gpio_in,

    output reg gpio_out,

    output wire uart_rx_read,

    output reg [7:0] uart_tx_data,
    output reg uart_tx_start,

    output reg [31:0] read_data,

    output reg [31:0] timer_count,

    output wire [31:0] debug_0x100,
    output wire [31:0] debug_0x104,
    output wire [31:0] debug_0x108,
    output wire [31:0] debug_0x10C,

    output wire [31:0] debug_0x110,
    output wire [31:0] debug_0x114,
    output wire [31:0] debug_0x118,
    output wire [31:0] debug_0x11C,

    output wire [7:0] debug_0x120,
    output wire [7:0] debug_0x121,

    output wire [15:0] debug_0x122,
    output wire [15:0] debug_0x124,

    output wire [31:0] debug_0x128,
    output wire [31:0] debug_0x12C
);

reg [7:0] memory [0:8192];


assign debug_0x100 = {
    memory[32'h103],
    memory[32'h102],
    memory[32'h101],
    memory[32'h100]
};

assign debug_0x104 = {
    memory[32'h107],
    memory[32'h106],
    memory[32'h105],
    memory[32'h104]
};

assign debug_0x108 = {
    memory[32'h10B],
    memory[32'h10A],
    memory[32'h109],
    memory[32'h108]
};

assign debug_0x10C = {
    memory[32'h10F],
    memory[32'h10E],
    memory[32'h10D],
    memory[32'h10C]
};


assign debug_0x110 = {
    memory[32'h113],
    memory[32'h112],
    memory[32'h111],
    memory[32'h110]
};

assign debug_0x114 = {
    memory[32'h117],
    memory[32'h116],
    memory[32'h115],
    memory[32'h114]
};

assign debug_0x118 = {
    memory[32'h11B],
    memory[32'h11A],
    memory[32'h119],
    memory[32'h118]
};

assign debug_0x11C = {
    memory[32'h11F],
    memory[32'h11E],
    memory[32'h11D],
    memory[32'h11C]
};


assign debug_0x128 = {
    memory[32'h12B],
    memory[32'h12A],
    memory[32'h129],
    memory[32'h128]
};

assign debug_0x12C = {
    memory[32'h12F],
    memory[32'h12E],
    memory[32'h12D],
    memory[32'h12C]
};

initial begin
    $readmemh("_data.bin",memory,32'h1000);
end

assign uart_rx_read = mem_read && (address == 32'h10000010);

always @(*) begin
    if (mem_read) begin
        if (address == 32'h10000010) begin
            read_data = {24'b0,uart_rx_data};
        end else if (address == 32'h10000014) begin
            read_data = {31'b0,uart_rx_ready};
        end else if (address == 32'h1000001c) begin
            read_data = {31'b0,gpio_in};
        end else if (address == 32'h10000024) begin
            read_data = timer_count;
        end else begin
            case (mem_size_bytes)
                3'b100: 
                    read_data =  {memory[address+3],memory[address+2],memory[address+1],memory[address]};

                3'b010:
                    read_data = {{16{mem_load_signed ? memory[address+1][7] : 1'b0}}, memory[address+1], memory[address]};

                3'b001:
                    read_data = {{24{mem_load_signed ? memory[address][7] : 1'b0}}, memory[address]};

                default:
                    read_data = 32'h0;

            endcase
        end
    end else 
        read_data = 32'h0;
end

always @(posedge clk) begin

    uart_tx_start <= 1'b0;

    if (reset)
        timer_count <= 32'd0;
    else
        timer_count <= timer_count + 32'd1;

    if (mem_write)  begin
        if (address == 32'h10000000) begin
            uart_tx_data <= write_data[7:0];
            uart_tx_start <= 1'b1;
        end else if (address == 32'h10000020) begin
            gpio_out <= write_data[0];
        end else begin
            case (mem_size_bytes)
                3'b100: begin
                    memory[address] <= write_data[7:0]; 
                    memory[address + 1] <= write_data[15:8];
                    memory[address + 2] <= write_data[23:16];
                    memory[address + 3] <= write_data[31:24];
                end

                3'b010: begin
                    memory[address] <= write_data[7:0]; 
                    memory[address + 1] <= write_data[15:8];
                end

                3'b001: begin
                    memory[address] <= write_data[7:0]; 
                end
            endcase
        end
    end
end

endmodule