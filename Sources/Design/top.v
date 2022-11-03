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

    // General
    input wire CLK100MHZ,
    input wire rst_n,
    input wire [15:0] SW,
    
    // Camera I/O

    input wire [7:0] wdata_cam,
    input wire vsync_cam,
    input wire href_cam,
    input wire pclk_cam,
    output wire mclk_cam,
    inout  i2c_sda,
    output i2c_scl,

    input wire [3:0] BTNS,
    
    // VGA I/O
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS
    );
    
    // VGA Memory access
    wire [18:0] raddr_vga;
    wire [11:0] rdata_vga;
    
    // Processing access
    reg [12:0] raddr_alu;
    reg [18:0] waddr_alu;
    reg [11:0] wdata_alu;
    reg        wen_alu;
    wire [11:0] rdata_alu;
    
    mem_controller mc(
        .sys_clk  (CLK100MHZ),
        .rst      (~rst_n   ), 
        .pclk     (pclk_cam ),
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
    
    vga vga0(
        .CLK100MHZ(CLK100MHZ),
        .rst      (~rst_n),
        .rdata_vga(rdata_vga),
        .VGA_R    (VGA_R),
        .VGA_G    (VGA_G),
        .VGA_B    (VGA_B),
        .VGA_HS   (VGA_HS),
        .VGA_VS   (VGA_VS),
        .raddr_vga(raddr_vga)
    );
    
    camera_interface(
        .clk_100(CLK100MHZ),
        .rst_n(rst_n),
        .key(BTNS),
        // not needed, will be removed at a later date.
        .rd_en(1'b0),
        // output wire[9:0] data_count_r,
        // output wire[15:0] dout,
        
        //camera pinouts
        .cmos_pclk(pclk_cam),
        .cmos_href(href_cam),
        .cmos_vsync(vsync_cam),
        .cmos_db(wdata_cam),          // to be removed
        .cmos_sda(i2c_sda),         //inout!!
        .cmos_scl(i2c_scl),         //i2c comm wires
        // cmos_rst_n(),
        // cmos_pwdn(),
        .cmos_xclk(mclk_cam)
    );
endmodule
