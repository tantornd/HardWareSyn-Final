`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/6/2021 01:42:33 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART Transmitter module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_tx(
    input clk,                  // Clock signal
    input [7:0] data_transmit,  // Data to be transmitted
    input ena,                  // Enable signal to start transmission
    output reg sent,            // Transmission status (sent or not)
    output reg bit_out          // Bit to be transmitted
);

    // Internal signals and registers
    reg last_ena;              // Stores the previous value of the enable signal
    reg sending = 0;           // Flag indicating if data is being sent
    reg [7:0] count = 0;       // Counter to manage the transmission
    reg [7:0] temp;            // Temporary register to hold data during transmission
    
    // State machine for UART transmission
    always @(posedge clk) begin
        // When the enable signal goes high, begin sending data
        if (~sending && ~last_ena && ena) begin
            temp <= data_transmit;  // Load data to transmit
            sending <= 1;           // Indicate that sending is in progress
            sent <= 0;               // Reset sent flag
            count <= 0;              // Reset the counter
        end
        
        // Update the last enable signal
        last_ena <= ena;
        
        // If sending, increment the counter; else reset the counter and set bit_out to 1 (idle)
        if (sending) begin
            count <= count + 1;
        end else begin
            count <= 0;
            bit_out <= 1;           // Idle state (high) for UART transmission
        end

        // Case statement to manage the bit-by-bit transmission
        case (count)
            8'd8:    bit_out <= 0;                 // Start bit (low)
            8'd24:   bit_out <= temp[0];           // Transmit data bit 0
            8'd40:   bit_out <= temp[1];           // Transmit data bit 1
            8'd56:   bit_out <= temp[2];           // Transmit data bit 2
            8'd72:   bit_out <= temp[3];           // Transmit data bit 3
            8'd88:   bit_out <= temp[4];           // Transmit data bit 4
            8'd104:  bit_out <= temp[5];           // Transmit data bit 5
            8'd120:  bit_out <= temp[6];           // Transmit data bit 6
            8'd136:  bit_out <= temp[7];           // Transmit data bit 7
            8'd152: begin
                sent <= 1;        // Indicate transmission complete
                sending <= 0;     // Reset sending flag
            end
        endcase
    end

endmodule
