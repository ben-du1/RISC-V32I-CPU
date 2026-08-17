module top (
    input clk,
    input reset,
    input rx,
    input [5:0] gpio_in,
    output tx,
    output [5:0] gpio_out
);

    wire [15:0] gin;
    wire [15:0] gout;
    
    assign gin[5:0] = gpio_in;
    assign gin[15:6] = 10'b0;
    assign gpio_out = gout[5:0];

    cpu cpu_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx),
        .gpio_in(gin),
        .gpio_out(gout)
    );


endmodule