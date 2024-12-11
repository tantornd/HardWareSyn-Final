`timescale 1ns / 1ps

module ascii_test(
    input clk,                 // Clock signal
    input reset,               // Reset signal
    input we,                  // Write enable signal from UART
    input [7:0] data,          // 8-bit data from UART
    input video_on,            // Video on/off signal
    input [9:0] x, y,          // Current pixel coordinates
    input [1:0] color_switch,   // Switch Color
    output reg [11:0] rgb      // RGB output
);

    // Parameters and declarations
    parameter MEMSIZE = 128;      // Memory size (128 locations)
    reg [6:0] mem[MEMSIZE - 1:0]; // 7-bit memory array
    reg [6:0] itr;                // Memory index for writing


    // Signals for ASCII ROM
    wire [10:0] rom_addr;         // 11-bit text ROM address
    wire [6:0] ascii_char;        // 7-bit ASCII character code
    wire [3:0] char_row;          // 4-bit row of ASCII character
    wire [2:0] bit_addr;          // Column number of ROM data
    wire [7:0] rom_data;          // 8-bit row data from text ROM
    wire ascii_bit, plot;         // ASCII ROM bit and plot signal
    
    integer i ;
    initial begin
        itr = 7'b1 ;
        mem[0] = 7'h3e ;
    end

    // ASCII ROM instance
    ascii_rom rom(.clk(clk), .addr(rom_addr), .data(rom_data));
    
    // ASCII ROM address and data interface
    assign rom_addr = {ascii_char, char_row};   // ROM address
    assign ascii_bit = rom_data[~bit_addr];     // Reverse bit order for ASCII character
    assign char_row = y[3:0];                   // Row number of ASCII character
    assign bit_addr = x[2:0];                   // Column number of ASCII character
    assign ascii_char = mem[((x[7:3] + 8) & 5'b11111) + 32 * ((y[5:4] + 3) & 2'b11)];
    
    assign plot = ((x >= 192 && x < 448) && (y >= 208 && y < 272)) ? ascii_bit : 1'b0;
    // Memory Write Logic
    always @(posedge we or posedge reset) begin
        if (reset) begin
            // Clear the memory when reset is active
            for (i = 0; i < MEMSIZE; i = i + 1) begin
                mem[i] = 7'h00;  // Clear all memory entries
            end
            itr = 7'b1;  // Reset the memory index
        end else begin
            // Normal memory write behavior when UART sends data
            if (data[6:0] == 13) begin // Carriage return (move to the next line)
                itr = (1 + (itr >> 5)) << 5;
                if (itr == 0)
                    itr = itr + 1;
            end else begin
                mem[itr] = data[6:0];  // Store data in memory
                itr = 1 + (itr % (MEMSIZE - 1));  // Increment memory index
            end
        end
    end

    // RGB multiplexing logic
    always @* begin
        if (~video_on)
            rgb = 12'h000; // Display blank screen
        else if (plot) begin
            case (color_switch)
                2'b00: rgb = 12'h00F; // Blue
                2'b01: rgb = 12'hF00; // Red
                2'b10: rgb = 12'h0F0; // Green
                2'b11: rgb = 12'hFF0; // Yellow
                default: rgb = 12'hFFF; // White (fallback)
            endcase
        end
        else
            rgb = 12'hFFF; // White background
    end


endmodule