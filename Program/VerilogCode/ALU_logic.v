module alu_8bit(
    input [7:0] A,          
    input [7:0] B,          
    input [3:0] alu_sel,    
    output reg [7:0] led,   
    output reg zero,        
    output reg carry_out,   
    output reg overflow,    
    output reg negative     
    );

    always @(*) begin
        led = 8'b0;
        carry_out = 0;
        overflow = 0;
        case(alu_sel)
            4'b0000: {carry_out, led} = A + B;       // Add
            4'b0001: {carry_out, led} = A + (~B + 1);       // Sub
            4'b0010: led = A & B;                   // AND
            4'b0011: led = A | B;                   // OR
            4'b0100: led = A ^ B;                   // XOR
            4'b0101: led = ~A;                      // NOT
            4'b0110: led = A << 1;                  // L-Shift
            4'b0111: led = A >> 1;                  // R-Shift
            4'b1000: led = A * B;                   // Mult
            4'b1001: led = (B != 0) ? A / B : 8'h00; // Div
            4'b1010: led = (B != 0) ? A % B : 8'h00; // Mod
            default: led = 8'b0;
        endcase
        
        zero = (led == 8'b0);
        negative = led[7];
        overflow = (alu_sel == 4'b0000) && (A[7] == B[7]) && (led[7] != A[7]);
    end
endmodule
