`timescale 1ns / 1ps

module uart_rx(
    input clk,                // Clock signal
    input bit_in,             // Incoming bit signal from UART
    output reg received,      // Flag indicating data has been received
    output reg [7:0] data_out // 8-bit data output
    );

    // Internal signals
    reg last_bit;              // To track the previous value of bit_in
    reg receiving = 0;         // Flag indicating whether data reception is in progress
    reg [7:0] count = 0;       // Counter to sample data at specific intervals

    always @(posedge clk) begin
        // Detect the falling edge of the start bit (start of transmission)
        if (~receiving && last_bit && ~bit_in) begin
            receiving <= 1;  // Start receiving data
            received <= 0;   // Data reception is not complete yet
            count <= 0;      // Reset the counter for sampling
        end
        
        // Store the last bit value for edge detection
        last_bit <= bit_in;

        // Increment the counter if receiving is in progress
        if (receiving) 
            count <= count + 1;

        // Sample the incoming bits at intervals based on count (16 ticks per bit)
        case (count)
            8'd24: data_out[0] <= bit_in; 
            8'd40: data_out[1] <= bit_in; 
            8'd56: data_out[2] <= bit_in; 
            8'd72: data_out[3] <= bit_in;  
            8'd88: data_out[4] <= bit_in;  
            8'd104: data_out[5] <= bit_in; 
            8'd120: data_out[6] <= bit_in; 
            8'd136: data_out[7] <= bit_in; 
            8'd152: begin
                received <= 1;   // Set received flag when all 8 bits are received
                receiving <= 0;  // Stop receiving data
            end
        endcase
    end

endmodule
