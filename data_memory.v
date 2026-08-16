module data_memory(
    input clk,
    input reset,

    input mem_write,
    input mem_read,

    input [2:0] mem_size_bytes,
    input mem_load_signed,
    input [31:0] address,
    input [31:0] write_data,

    input uart_rx_read_enable,
    input [7:0] uart_rx_data,
    input uart_rx_ready,

    input [15:0] gpio_in,

    output reg [15:0] gpio_out,

    output wire uart_rx_read,
    output reg [7:0] uart_tx_data,
    output reg uart_tx_start,

    output reg [31:0] read_data,

    output reg [31:0] timer_count
);

reg [31:0] memory [0:2047];
reg [31:0] memory_read_data;
reg [31:0] assembled_word;


initial begin
    // $readmemh("_program.hex",memory);
    $readmemh("_data.hex",memory,32'h400);
end

assign uart_rx_read = uart_rx_read_enable && (address == 32'h10000010);

// synchronous reads during MEM_READ
always @(posedge clk) begin
    if (mem_read)
        memory_read_data <= memory[address[12:2]];
end

// data formatting during MEM_WAIT
always @(*) begin

    // if reading rx
    if (address == 32'h10000010) begin
        read_data = {24'b0,uart_rx_data};
    end 
    
    // checking if rx available
    else if (address == 32'h10000014) begin
        read_data = {31'b0,uart_rx_ready};
    end 
    
    // reading gpio input pins
    else if (address == 32'h1000001c) begin
        read_data = {16'b0,gpio_in};
    end 

    // when changing gpio_out we need to first read it
    else if (address == 32'h10000020) begin
        read_data = {16'b0,gpio_out};
    end
    
    // getting timer value
    else if (address == 32'h10000024) begin
        read_data = timer_count;
    end 
    
    else begin
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

end

// synchronous writes during MEM_WRITE
always @(posedge clk) begin

    uart_tx_start <= 1'b0;

    if (reset) begin
        timer_count <= 32'd0;
        gpio_out <= 16'd0;
    end else
        timer_count <= timer_count + 32'd1;

    if (mem_write)  begin
        if (address == 32'h10000000) begin
            uart_tx_data <= write_data[7:0];
            uart_tx_start <= 1'b1;
        end else if (address == 32'h10000020) begin
            gpio_out <= write_data[15:0];
        end else begin
            case (mem_size_bytes)
                3'b100: begin
                    memory[address[12:2]] <= write_data; 
                end

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
                    memory[address[12:2]] <= assembled_word; 
                end

                3'b001: begin
                    case (address[1:0])
                        2'b00:
                            assembled_word =
                                {memory_read_data[31:8], write_data[7:0]};

                        2'b01:
                            assembled_word =
                                {memory_read_data[31:16],
                                write_data[7:0],
                                memory_read_data[7:0]};

                        2'b10:
                            assembled_word =
                                {memory_read_data[31:24],
                                write_data[7:0],
                                memory_read_data[15:0]};

                        2'b11:
                            assembled_word =
                                {write_data[7:0],
                                memory_read_data[23:0]};
                    endcase
                    memory[address[12:2]] <= assembled_word; 
                end
            endcase
        end
    end
end

endmodule