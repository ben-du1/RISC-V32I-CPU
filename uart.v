module uart(
    input clk,
    input reset,
    input [7:0] uart_tx_data,
    input uart_tx_start,
    input rx,
    input uart_rx_read,

    output reg tx,
    output wire [7:0] uart_rx_data,
    output wire uart_rx_ready
);

reg [2:0] tx_clock_count = 0;
reg [3:0] tx_bit_index = 0;
reg transmitting = 0;
reg [7:0] tx_current_data;
reg tx_stopping = 0;

reg [7:0] uart_tx_fifo [0:7];
reg [2:0] uart_tx_fifo_front = 0;
reg [2:0] uart_tx_fifo_back = 0;
wire uart_tx_fifo_empty;
assign uart_tx_fifo_empty = uart_tx_fifo_front == uart_tx_fifo_back;

reg recieving = 0;
reg [7:0] rx_current_data;
reg [2:0] rx_clock_count = 0;
reg [2:0] rx_state = 0;
reg [3:0] rx_bit_index = 0;
reg [7:0] rx_data_reg;

reg [7:0] uart_rx_fifo [0:7];
reg [2:0] uart_rx_fifo_front = 0;
reg [2:0] uart_rx_fifo_back = 0;
wire uart_rx_fifo_empty;
assign uart_rx_fifo_empty = uart_rx_fifo_front == uart_rx_fifo_back;

// assign uart_rx_data = uart_rx_fifo[uart_rx_fifo_front];
assign uart_rx_data = rx_data_reg;

assign uart_rx_ready = !uart_rx_fifo_empty;


always @(posedge clk) begin
    if (uart_rx_read) begin
        rx_data_reg <= uart_rx_fifo[uart_rx_fifo_front];

        if (uart_rx_fifo_front == 7 )
            uart_rx_fifo_front <= 0;
        else
            uart_rx_fifo_front <= uart_rx_fifo_front + 1;

    end

    if (uart_tx_start) begin
        uart_tx_fifo[uart_tx_fifo_back] <= uart_tx_data;
        if (uart_tx_fifo_back == 7 )
            uart_tx_fifo_back <= 0;
        else
            uart_tx_fifo_back <= uart_tx_fifo_back + 1;
    end

    if (reset) begin
        tx <= 1'b1;
        tx_current_data <= 0;
        tx_clock_count <= 0;
        tx_bit_index <= 0;
        transmitting <= 0;
        tx_stopping <= 0;
        rx_clock_count <= 0;
        rx_state <= 0;
        rx_bit_index <= 0;
        recieving <= 0;
        rx_data_reg <= 0;
        uart_rx_fifo_back <= 0;
        uart_rx_fifo_front <= 0;
        uart_tx_fifo_back <= 0;
        uart_tx_fifo_front <= 0;

    end else if (!transmitting && !uart_tx_fifo_empty) begin
            transmitting <= 1;
            tx_current_data <= uart_tx_fifo[uart_tx_fifo_front];
            if (uart_tx_fifo_front == 7 )
                uart_tx_fifo_front <= 0;
            else
                uart_tx_fifo_front <= uart_tx_fifo_front + 1;
            tx_bit_index <= 0;
            tx_clock_count <= 0;
            tx <= 1'b0;
            tx_stopping <= 0;
    end else if (transmitting) begin
        tx_clock_count <= tx_clock_count + 1;
        if (tx_clock_count == 4) begin
            if (tx_bit_index <= 7) begin
                tx <= tx_current_data[tx_bit_index];
                tx_bit_index <= tx_bit_index + 1;
            end else if (tx_stopping) begin
                tx_stopping <= 0;
                transmitting <= 0;
                tx <= 1'b1;
            end else begin 
                tx_stopping <= 1;
                tx <= 1'b1;
            end
            tx_clock_count <= 0;
        end 
    end

    if (!recieving && !rx) begin
        recieving <= 1;
        rx_state <= 1;
        rx_clock_count <= 0;
        rx_bit_index <= 0;
    end

    if (recieving) begin
        case (rx_state)
            1: begin
                if (rx_clock_count == 3'b010) begin
                    if (rx) begin
                        recieving <= 0;
                    end
                    rx_state <= 2;
                    rx_clock_count <= 0;
                end else begin
                    rx_clock_count <= rx_clock_count + 1;
                end
            end

            2: begin
                if (rx_clock_count == 3'b100) begin
                    rx_current_data[rx_bit_index] <= rx;
                    if (rx_bit_index == 7) begin
                        rx_state <= 3;
                    end
                    rx_clock_count <= 0;
                    rx_bit_index <= rx_bit_index  + 1;
                end else begin
                    rx_clock_count <= rx_clock_count + 1;
                end
            end

            3: begin
                if (rx_clock_count == 3'b100) begin
                    if (rx) begin
                        uart_rx_fifo[uart_rx_fifo_back] <= rx_current_data;
                        if (uart_rx_fifo_back == 7 )
                            uart_rx_fifo_back <= 0;
                        else
                            uart_rx_fifo_back <= uart_rx_fifo_back + 1;
                    end
                    recieving <= 0;

                end else begin
                    rx_clock_count <= rx_clock_count + 1;
                end
            end
        endcase
    end
end

endmodule