`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/6/2021 01:43:21 PM
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART module supporting both English (ASCII) and Thai (TIS-620) protocols.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart(
    input baud,           // Baud rate clock
    input RsRx,           // UART receive line
    output RsTx,          // UART transmit line
    output [7:0] data_out,// Received data
    output received       // Data received flag
    );
    
    reg en, last_rec;      // Enable signal and last received flag
    reg [7:0] data_in;     // Transmitter data input
    reg is_thai;           // Protocol selector: 0 = English, 1 = Thai
    wire [7:0] data_out;   // Received data
    wire sent;             // Transmission complete flag
    wire received;         // Data received flag

    // Receiver and transmitter instances
    uart_rx receiver(baud, RsRx, received, data_out);
    uart_tx transmitter(baud, data_in, en, sent, RsTx);
    
    always @(posedge baud) begin
        if (en) 
            en <= 0; // Reset enable after transmission

        if (~last_rec & received) begin
            data_in <= data_out; // Load received data
            is_thai <= (data_out >= 8'hA0 && data_out <= 8'hFF); // Determine protocol
            
            // Enable transmission if valid data
            if ((data_out >= 8'h20 && data_out <= 8'h7E) || // English characters
                (data_out >= 8'hA0 && data_out <= 8'hFF))   // Thai characters
                en <= 1;
        end

        last_rec <= received; // Update last received state
    end
endmodule
