module pc(
    input clk,
    input reset,
    input [31:0] next_pc,
    output reg [31:0] pc
);

always @(posedge clk) begin
    if (reset) begin
        pc <= 32'h0;
    end else begin
        pc <= next_pc;
    end
end

endmodule