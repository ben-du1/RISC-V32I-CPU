module alu(
    input [3:0] alu_control,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] result,
    output reg zero
);


always @(*) begin
    case(alu_control)
        4'b0000:
            result = A+B;
        4'b0001:
            result = A-B;
        4'b0010:
            result = A&B;
        4'b0011:
            result = A|B;
        4'b0100:
            result = A^B;
        4'b0101:
            result = A << B[4:0];
        4'b0110:
            result = A >> B[4:0];
        4'b0111:
            result = $signed(A) >>> B[4:0];
        4'b1000:
            result = ($signed(A) < $signed(B)) ? 1 : 0;
        4'b1001:
            result = (A < B) ? 1 : 0;
        default:
            result = 0;
    
    endcase
    zero = (result == 0) ? 1 : 0;


end
endmodule