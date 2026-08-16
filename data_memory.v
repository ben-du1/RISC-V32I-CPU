module data_memory(
    input clk,
    input reset,
    input mem_write,
    input mem_read,
    input mem_format,
    input [2:0] mem_size_bytes,
    input mem_load_signed,

    input [31:0] address,
    input [31:0] write_data,

    input uart_rx_read_enable,
    input [7:0] uart_rx_data,
    input uart_rx_ready,
    input gpio_in,

    output reg gpio_out,

    output wire uart_rx_read,

    output reg [7:0] uart_tx_data,
    output reg uart_tx_start,

    output reg [31:0] read_data,

    output reg [31:0] timer_count
);

reg [31:0] memory [0:255];
reg [31:0] memory_read_data;
reg [31:0] assembled_word;


initial begin
    $readmemh("_data.bin",memory,32'h80);
end


assign uart_rx_read = uart_rx_read_enable && (address == 32'h10000010);

always @(posedge clk) begin
    if (mem_read)
        memory_read_data <= memory[address[9:2]];
end

always @(*) begin


    //if (mem_format) begin
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
                    read_data =  memory_read_data;

                3'b010:
                    if (address[1] == 1'b0) begin
                        read_data = {{16{mem_load_signed ? memory_read_data[15] : 1'b0}},memory_read_data[15:0]};
                    end else begin
                        read_data = {{16{mem_load_signed ? memory_read_data[31] : 1'b0}},memory_read_data[31:16]};
                    end

                3'b001: begin
                    case (address[1:0])
                        2'b00:
                            read_data = {{24{mem_load_signed ? memory_read_data[7]  : 1'b0}},
                                        memory_read_data[7:0]};

                        2'b01:
                            read_data = {{24{mem_load_signed ? memory_read_data[15] : 1'b0}},
                                        memory_read_data[15:8]};

                        2'b10:
                            read_data = {{24{mem_load_signed ? memory_read_data[23] : 1'b0}},
                                        memory_read_data[23:16]};

                        2'b11:
                            read_data = {{24{mem_load_signed ? memory_read_data[31] : 1'b0}},
                                        memory_read_data[31:24]};
                    endcase
                end

                default:
                    read_data = 32'h0;

            endcase
        end
    //end else 
        //read_data = 32'h0;
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
                    memory[address[9:2]] <= write_data; 
                end

                // 3'b010: begin
                //     if (address[1:0] == 2'b00) begin
                //         memory[address[9:2]][15:0] <= write_data[15:0];
                //     end else if (address[1:0] == 2'b10) begin
                //         memory[address[9:2]][31:16] <= write_data[15:0];
                //     end
                // end

3'b010: begin
    case (address[1:0])

        2'b00: begin
            assembled_word = {
                memory_read_data[31:16],
                write_data[15:0]
            };
        end

        2'b10: begin
            assembled_word = {
                write_data[15:0],
                memory_read_data[15:0]
            };
        end

    endcase
    memory[address[9:2]] <= assembled_word; 
end

                // 3'b001: begin
                //     case (address[1:0])
                //         2'b00: memory[address[9:2]][7:0]   <= write_data[7:0];
                //         2'b01: memory[address[9:2]][15:8]  <= write_data[7:0];
                //         2'b10: memory[address[9:2]][23:16] <= write_data[7:0];
                //         2'b11: memory[address[9:2]][31:24] <= write_data[7:0];
                //     endcase
                // end
    3'b001: begin
        case (address[1:0])
            2'b00:
                assembled_word <=
                    {memory_read_data[31:8], write_data[7:0]};

            2'b01:
                assembled_word <=
                    {memory_read_data[31:16],
                     write_data[7:0],
                     memory_read_data[7:0]};

            2'b10:
                assembled_word <=
                    {memory_read_data[31:24],
                     write_data[7:0],
                     memory_read_data[15:0]};

            2'b11:
                assembled_word <=
                    {write_data[7:0],
                     memory_read_data[23:0]};
        endcase
        memory[address[9:2]] <= assembled_word; 
    end
            endcase
        end
    end
end

endmodule