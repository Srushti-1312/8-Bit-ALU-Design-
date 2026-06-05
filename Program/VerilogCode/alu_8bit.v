module alu_8bit (
    input  [7:0] A,          // From sw[7:0]
    input  [7:0] B,          // From sw[15:8]
    input  [3:0] ALU_SEL,    // From {BTNU, BTNR, BTND, BTNL}
    output reg [7:0] ALU_OUT,
    output reg ZERO,
    output reg CARRY_OUT,
    output reg OVERFLOW,
    output reg NEGATIVE
);

    always @(*) begin
        // Default assignments to prevent latches
        ALU_OUT   = 8'b0;
        CARRY_OUT = 1'b0;
        OVERFLOW  = 1'b0;
        
        case (ALU_SEL)
            4'b0000: begin // Unsigned Addition
                {CARRY_OUT, ALU_OUT} = A + B;
                OVERFLOW = (A[7] == B[7]) && (ALU_OUT[7] != A[7]);
            end
            4'b0001: begin // Unsigned Subtraction
                {CARRY_OUT, ALU_OUT} = A - B;
                OVERFLOW = (A[7] != B[7]) && (ALU_OUT[7] != A[7]);
            end
            4'b0010: ALU_OUT = A & B;  // Bitwise AND
            4'b0011: ALU_OUT = A | B;  // Bitwise OR
            4'b0100: ALU_OUT = A ^ B;  // Bitwise XOR
            4'b0101: ALU_OUT = ~A;     // Bitwise NOT
            4'b0110: ALU_OUT = A << 1; // Logical Left Shift
            4'b0111: ALU_OUT = A >> 1; // Logical Right Shift
            4'b1000: ALU_OUT = A * B;  // Unsigned Multiplication
            4'b1001: ALU_OUT = (B != 0) ? (A / B) : 8'b0; // Unsigned Division (Safe for Div by 0)
            4'b1010: ALU_OUT = (B != 0) ? (A % B) : 8'b0; // Modulo
            4'b1011: ALU_OUT = (B != 0) ? (A / B) : 8'b0; // Optional Unsigned Division
            default: ALU_OUT = 8'b0;   // Default to zero output
        endcase
        
        // Status Flag Calculations
        ZERO     = (ALU_OUT == 8'b0);
        NEGATIVE = ALU_OUT[7];
    end
endmodule