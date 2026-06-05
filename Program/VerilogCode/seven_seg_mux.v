module seven_seg_mux (
    input clk,                    // 100MHz system clock
    input [7:0] val,              // 8-bit value to display (0 to 255)
    output reg [3:0] an,          // Anodes (digit selectors, active-low)
    output reg [6:0] seg          // Cathodes (segments a-g, active-low)
);

    // Registers to hold our split base-10 numerical digits
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;

    // --- Binary to BCD Conversion Logic ---
    // Decodes the 8-bit binary value into individual base-10 digits
    always @(*) begin
        hundreds = val / 100;          // Extract hundreds digit
        tens     = (val % 100) / 10;   // Extract tens digit
        ones     = val % 10;           // Extract ones digit
    end

    // --- Refresh Counter for Display Multiplexing ---
    reg [19:0] refresh_counter = 0; 
    wire [1:0] activating_digit = refresh_counter[19:18]; 

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end

    // Exact Active-Low Pattern Generator (0 = Segment ON, 1 = Segment OFF)
    // Bit order mapping matches standard Xilinx Basys 3 configurations: {g, f, e, d, c, b, a}
    function [6:0] s_pattern (input [3:0] digit);
        case (digit)
            4'd0: s_pattern = 7'b1000000; // 0
            4'd1: s_pattern = 7'b1111001; // 1
            4'd2: s_pattern = 7'b0100100; // 2
            4'd3: s_pattern = 7'b0110000; // 3
            4'd4: s_pattern = 7'b0011001; // 4
            4'd5: s_pattern = 7'b0010010; // 5
            4'd6: s_pattern = 7'b0000010; // 6
            4'd7: s_pattern = 7'b1111000; // 7
            4'd8: s_pattern = 7'b0000000; // 8
            4'd9: s_pattern = 7'b0010000; // 9
            default: s_pattern = 7'b1111111; // Blank display on error
        endcase
    endfunction

    // Multiplexing between the digits (Rapidly cycling to avoid flicker)
    always @(*) begin
        case(activating_digit)
            2'b00: begin
                an = 4'b1110; // Activate Digit 0 (Rightmost - Ones place)
                seg = s_pattern(ones);
            end
            2'b01: begin
                an = 4'b1101; // Activate Digit 1 (Tens place)
                seg = s_pattern(tens);
            end
            2'b10: begin
                an = 4'b1011; // Activate Digit 2 (Hundreds place)
                seg = s_pattern(hundreds);
            end
            2'b11: begin
                an = 4'b0111; // Activate Digit 3 (Leftmost - Kept blank)
                seg = 7'b1111111; // Turn all segments off
            end
        endcase
    end
endmodule