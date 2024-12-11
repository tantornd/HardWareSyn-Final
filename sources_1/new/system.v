`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/6/2021 01:35:13 PM
// Design Name: 
// Module Name: system
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module system(
    input wire [9:0] sw,
    input btnU,
    input reset, // btnC on Basys 3
    output wire hsync, vsync, //vga
    output [11:0] rgb, // to DAC, to VGA connector
    output wire RsTx, //uart
    output wire RsTx_2, //uart
    input wire RsRx_2, //uart
    input clk
    );

    
    // Generate Baudrate
    wire baud;
    baudrate baudrate(clk, baud);
    
    wire enable;
    singlePulser(enable, btnU, baud);
    
    // UART Transmitter
    wire [7:0] data_in = sw[7:0];
    uart_tx transmitter(baud, data_in, enable, sent, RsTx);
    
    // UART Receiver
    wire received;
    wire [7:0] data;
    uart uart(baud, RsRx_2, RsTx_2, data, received);
    
    // VGA
    // signals
    wire [9:0] w_x, w_y;
    wire w_video_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    // VGA Controller
    vga_controller vga(.clk_100MHz(clk), .reset(reset), .hsync(hsync), .vsync(vsync), .video_on(w_video_on), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    // Text Generation Circuit
        wire [1:0] s_color = sw[9:8];
    ascii_test ascii_test_inst (
        .clk(clk), 
        .reset(reset), 
        .video_on(w_video_on), 
        .x(w_x), 
        .y(w_y), 
        .rgb(rgb_next), 
        .data(data), 
        .we(received), 
        .color_switch(s_color)
    );
    // RGB Buffer and Reset Logic
    always @(posedge clk) begin
        if (reset) begin
            // Reset the rgb register to a default value (e.g., black)
            rgb_reg <= 12'b0;  // Reset to black (0 for RGB)
        end
        else if (w_p_tick) begin
            // Update RGB only when the pixel tick occurs
            rgb_reg <= rgb_next;
        end
    end
    
    // Output RGB to VGA
    assign rgb = rgb_reg;

endmodule