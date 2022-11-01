`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2022 02:00:07 PM
// Design Name: 
// Module Name: top
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


module top(
    input wire CLK100MHZ,
    input wire rst,
    input wire [15:0] SW,
    
    input wire [9:0] JA,
    input wire [9:0] JB,
    
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS
    );
    
    // Camera Data
    reg pclk;
    reg vsync_cam;
    reg href_cam;
    reg [7:0] wdata_cam;
    
    // VGA Memory access
    reg [18:0] raddr_vga;
    wire [11:0] rdata_vga;
    
    // Processing access
    reg [12:0] raddr_alu;
    reg [18:0] waddr_alu;
    reg [11:0] wdata_alu;
    reg        wen_alu;
    wire [11:0] rdata_alu;
    
    memory_controller mc(
        .sys_clk  (CLK100MHZ),
        .rst      (rst      ), 
        .pclk     (pclk     ),
        .vsync_cam(vsync_cam),
        .href_cam (href_cam ),
        .wdata_cam(wdata_cam),     
        .raddr_vga(raddr_vga),
        .rdata_vga(rdata_vga),
        .raddr_alu(raddr_alu),
        .waddr_alu(waddr_alu),
        .wdata_alu(wdata_alu),
        .wen_alu  (wen_alu  ),
        .rdata_alu(rdata_alu)
    );
endmodule
