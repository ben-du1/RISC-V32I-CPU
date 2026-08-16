module cpu_tb;

reg clk;
reg reset;
wire tx;
reg rx;
wire [15:0] gpio_out;
reg [15:0] gpio_in;

cpu uut(
    .clk(clk),
    .reset(reset),
    .tx(tx),
    .rx(rx),
    .gpio_in(gpio_in),
    .gpio_out(gpio_out)
);

always begin
    #5 clk = ~clk;
end

integer i;
reg [7:0] recieved;

always @(negedge tx) begin 
    repeat(2) @(posedge clk);

    for (i = 0; i<8; i = i+1) begin
        repeat(5) @(posedge clk);
        recieved[i] = tx;
    end

    repeat(5) @(posedge clk);
    $display("UART: %c (0x%02h)",recieved,recieved);
end

task send_uart_byte;
    input [7:0] data;
    integer j;

    begin
        rx = 1'b1;
        repeat(5) @(posedge clk);

        rx = 1'b0;
        repeat(5) @(posedge clk);

        for(j = 0; j < 8; j = j + 1)
        begin
            rx = data[j];
            repeat(5) @(posedge clk);
        end

        // stop bit
        rx = 1'b1;
        repeat(5) @(posedge clk);
    end
endtask

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0,cpu_tb);

    rx = 1'b1;

    clk = 0;
    reset = 1;

    #100;

    reset = 0;
    send_uart_byte(8'hD0);
    send_uart_byte(8'h41);
    send_uart_byte(8'h67);

    gpio_in = 16'h1010;

    #10000;

    $finish;
end



endmodule