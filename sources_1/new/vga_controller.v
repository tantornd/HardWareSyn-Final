`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA Controller for 640x480 @ 60Hz with a 25MHz pixel clock
//////////////////////////////////////////////////////////////////////////////////

module vga_controller(
    input wire clk_100MHz,  // 100 MHz clock input
    input wire reset,       // Active-high reset
    output wire video_on,   // High when pixel is in the visible display area
    output wire hsync,      // Horizontal sync signal
    output wire vsync,      // Vertical sync signal
    output wire p_tick,     // Pixel clock tick (25 MHz)
    output wire [9:0] x,    // Current pixel x position (0-639)
    output wire [9:0] y     // Current pixel y position (0-479)
);

    // VGA Timing Parameters for 640x480 @ 60Hz
    localparam HD = 640;    // Horizontal display width
    localparam HF = 48;     // Horizontal front porch
    localparam HB = 16;     // Horizontal back porch
    localparam HR = 96;     // Horizontal sync pulse width
    localparam HMAX = HD + HF + HB + HR - 1;

    localparam VD = 480;    // Vertical display height
    localparam VF = 10;     // Vertical front porch
    localparam VB = 33;     // Vertical back porch
    localparam VR = 2;      // Vertical sync pulse width
    localparam VMAX = VD + VF + VB + VR - 1;

    // 25MHz Pixel Clock Generation
    reg [1:0] clk_div = 0;
    wire clk_25MHz;
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end
    assign clk_25MHz = (clk_div == 0);
    assign p_tick = clk_25MHz;

    // Horizontal and Vertical Counters
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk_25MHz or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == HMAX) begin
                h_count <= 0;
                if (v_count == VMAX)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // Horizontal and Vertical Sync Signals
    assign hsync = ~(h_count >= (HD + HB) && h_count < (HD + HB + HR));
    assign vsync = ~(v_count >= (VD + VB) && v_count < (VD + VB + VR));

    // Video On Signal
    assign video_on = (h_count < HD) && (v_count < VD);

    // Output Pixel Coordinates
    assign x = (h_count < HD) ? h_count : 0;
    assign y = (v_count < VD) ? v_count : 0;

endmodule
