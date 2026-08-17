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

localparam BIT_CLK_CYCLES = 9'd5;
// we only sample once per bit for now
localparam SAMPLE_DELAY = 9'd2;

localparam RX_START = 3'd1;
localparam RX_READ = 3'd2;
localparam RX_STOP = 3'd3;

localparam TX_START = 3'd1;
localparam TX_SEND = 3'd2;
localparam TX_STOP = 3'd3;

// TX_END holds stop bit high
localparam TX_END = 3'd4;

localparam FIFO_LENGTH = 4'd8;
localparam FIFO_END = FIFO_LENGTH - 1;

reg transmitting;
reg [8:0] tx_clock_count;
reg [3:0] tx_bit_index;
reg [7:0] tx_current_data;
reg [2:0] tx_state;

reg [7:0] tx_fifo [0:7];
reg [2:0] tx_fifo_front;
reg [2:0] tx_fifo_back;
wire tx_fifo_empty;

assign tx_fifo_empty = tx_fifo_front == tx_fifo_back;

reg receiving;
reg [8:0] rx_clock_count;
reg [3:0] rx_bit_index;
reg [7:0] rx_current_data;
reg [2:0] rx_state;
reg [7:0] rx_data_reg;

reg [7:0] rx_fifo [0:7];
reg [2:0] rx_fifo_front;
reg [2:0] rx_fifo_back;
wire rx_fifo_empty;

assign rx_fifo_empty = rx_fifo_front == rx_fifo_back;
assign uart_rx_ready = !rx_fifo_empty;
assign  uart_rx_data = rx_data_reg;
assign  uart_rx_ready = !rx_fifo_empty;

always @(posedge clk) begin

    if (reset) begin
        tx <= 1'b1;
        tx_current_data <= 0;
        tx_clock_count <= 0;
        tx_bit_index <= 0;
        transmitting <= 0;
        tx_state <= 0;
        rx_clock_count <= 0;
        rx_state <= 0;
        rx_bit_index <= 0;
        receiving <= 0;
        rx_data_reg <= 0;
        rx_fifo_back <= 0;
        rx_fifo_front <= 0;
        tx_fifo_back <= 0;
        tx_fifo_front <= 0;

    end else begin

        // update tx and rx fifos
        if (uart_rx_read) begin
            rx_data_reg <= rx_fifo[rx_fifo_front];

            if (rx_fifo_front == FIFO_END )
                rx_fifo_front <= 0;
            else
                rx_fifo_front <= rx_fifo_front + 3'd1;

        end

        if (uart_tx_start) begin
            tx_fifo[tx_fifo_back] <= uart_tx_data;
            if (tx_fifo_back == FIFO_END )
                tx_fifo_back <= 0;
            else
                tx_fifo_back <= tx_fifo_back + 3'd1;
        end
        
        if (!transmitting && !tx_fifo_empty) begin
                transmitting <= 1;
                tx_current_data <= tx_fifo[tx_fifo_front];

                if (tx_fifo_front == FIFO_END )
                    tx_fifo_front <= 0;
                else
                    tx_fifo_front <= tx_fifo_front + 3'd1;

                tx_bit_index <= 0;
                tx_clock_count <= 0;
                tx_state <= TX_START;

        end else if (transmitting) begin
            tx_clock_count <= tx_clock_count + 9'd1;
            if (tx_clock_count == BIT_CLK_CYCLES - 1) begin
                case (tx_state) 
                    TX_START: begin
                        tx <= 1'b0;
                        tx_state <= TX_SEND;   
                    end

                    TX_SEND: begin
                        if (tx_bit_index <= 7) begin
                            tx <= tx_current_data[tx_bit_index];
                            tx_bit_index <= tx_bit_index + 3'd1;
                        end else
                            tx_state <= TX_STOP;
                    end

                    TX_STOP: begin
                        tx <= 1'b1;
                        tx_state <= TX_END;
                    end

                    TX_END: begin
                        transmitting <= 0;
                        tx <= 1'b1;
                    end

                endcase
                tx_clock_count <= 0;
            end
        end




        if (!receiving && !rx) begin
            receiving <= 1;
            rx_state <= RX_START;
            rx_clock_count <= 0;
            rx_bit_index <= 0;
        end else if (receiving) begin
            case (rx_state)
                RX_START: begin
                    if (rx_clock_count == SAMPLE_DELAY) begin

                        // if rx is not low then exit
                        if (rx) begin
                            receiving <= 0;
                        end
                        rx_state <= RX_READ;
                        rx_clock_count <= 0;
                    end else begin
                        rx_clock_count <= rx_clock_count + 9'd1;
                    end
                end

                RX_READ: begin
                    if (rx_clock_count == BIT_CLK_CYCLES - 1) begin
                        rx_current_data[rx_bit_index] <= rx;
                        if (rx_bit_index == 7) begin
                            rx_state <= RX_STOP;
                        end
                        rx_clock_count <= 0;
                        rx_bit_index <= rx_bit_index  + 3'd1;
                    end else begin
                        rx_clock_count <= rx_clock_count + 9'd1;
                    end
                end

                RX_STOP: begin
                    if (rx_clock_count == BIT_CLK_CYCLES - 1) begin
                        if (rx) begin
                            rx_fifo[rx_fifo_back] <= rx_current_data;
                            if (rx_fifo_back == 7 )
                                rx_fifo_back <= 0;
                            else
                                rx_fifo_back <= rx_fifo_back + 3'd1;
                        end
                        receiving <= 0;

                    end else begin
                        rx_clock_count <= rx_clock_count + 9'd1;
                    end
                end
            endcase
        end
    end
end

endmodule