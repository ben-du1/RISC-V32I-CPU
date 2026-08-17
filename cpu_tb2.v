module cpu_tb;

    reg clk;
    reg reset;
    reg uart_rx;
    reg uart_tx;

    reg [15:0] gpio_in;
    reg [15:0] gpio_out;

    reg [7:0] test_program [0:1023];

    // CPU
    cpu uut (
        .clk(clk),
        .reset(reset),
        .rx(uart_rx),
        .tx(uart_tx),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out)
    );

    always #5 clk = ~clk;

    task uart_send_bit;
        input bit_value;
        begin
            uart_rx = bit_value;
            repeat (5) @(posedge clk);
        end
    endtask

    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            // start bit
            uart_send_bit(1'b0);

            // data bits, LSB first
            for (i = 0; i < 8; i = i + 1)
                uart_send_bit(data[i]);

            // stop bit
            uart_send_bit(1'b1);
        end
    endtask

    task send_program;
        input integer length;

        integer i;
        begin
            // Send 32-bit little-endian length
            uart_send_byte(length[7:0]);
            uart_send_byte(length[15:8]);
            uart_send_byte(length[23:16]);
            uart_send_byte(length[31:24]);

            // Send program
            for (i = 0; i < length; i = i + 1)
                uart_send_byte(test_program[i]);
        end
    endtask

    task uart_receive_byte;
        reg [7:0] data;
        integer i;
        begin
            // Wait for start bit
            @(negedge uart_tx);

            // Halfway through start bit
            repeat (2) @(posedge clk);

            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                repeat (5) @(posedge clk);
                data[i] = uart_tx;
            end

            // Stop bit
            repeat (5) @(posedge clk);

            $display("CPU UART TX: 0x%02X, %b", data, data);
        end
    endtask

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0,cpu_tb);
        $readmemh("_program.bin",test_program);

        clk = 0;
        uart_rx = 1;
        reset = 1;

        #100;
        reset = 0;

        send_program(700);

        // wait for application
        // gpio_in = 16'b0;
        // gpio_in[4] = 1'b1;
        // #10;
        // uart_send_byte(8'h67);
        // uart_receive_byte();
        #100000;

        $finish;
    end


initial begin
    forever begin
        uart_receive_byte();
    end
end

endmodule