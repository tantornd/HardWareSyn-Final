`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/6/2021 01:40:13 PM
// Design Name: 
// Module Name: baudrate_gen
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


module baudrate(
    input clk,
    output reg baud
    );
    //        freq = 100MHz
//        baud = 9600
//        count = freq/baud
//        count = count/2/16
    integer i;
    always @(posedge clk) begin
        i = i + 1;
        if (i == 325) 
            begin i = 0; 
            baud = ~baud; 
        end 

      
    end
    
endmodule