module basys3_alu_top (
    input clk,                    // Inbuilt 100MHz clock pin
    input [15:0] sw,              // sw[7:0] = A, sw[15:8] = B
    input btnU, btnR, btnD, btnL, // Pushbuttons for ALU_SEL
    output [15:0] led,            // led[7:0]=Result, led[15:12]=Flags
    output [3:0] an,              // 7-segment anodes
    output [6:0] seg              // 7-segment cathodes
);

    wire [7:0] alu_result;
    wire z_flag, c_flag, o_flag, n_flag;
    
    // Concatenate the buttons into a 4-bit bus matching your selector layout
    wire [3:0] alu_select = {btnU, btnR, btnD, btnL};

    // Instantiate core ALU logic
    alu_8bit core_alu (
        .A(sw[7:0]),
        .B(sw[15:8]),
        .ALU_SEL(alu_select),
        .ALU_OUT(alu_result),
        .ZERO(z_flag),
        .CARRY_OUT(c_flag),
        .OVERFLOW(o_flag),
        .NEGATIVE(n_flag)
    );

    // Instantiate Seven Segment Multiplexer
    seven_seg_mux display_unit (
        .clk(clk),
        .val(alu_result),
        .an(an),
        .seg(seg)
    );

    // Mapping to LEDs
    assign led[7:0]   = alu_result; // Output value to the first 8 LEDs
    assign led[11:8]  = 4'b0000;     // Unused buffer LEDs padding the gap
    
    // Mapping flags to the last 4 LEDs (led[15:12])
    assign led[12]    = n_flag;     // NEGATIVE
    assign led[13]    = o_flag;     // OVERFLOW
    assign led[14]    = c_flag;     // CARRY_OUT
    assign led[15]    = z_flag;     // ZERO

endmodule