`timescale 1ns / 1ps

`include "my_header.vh"

module top(

    // General
    input wire CLK100MHZ,
    input wire rst_n,
    input wire [15:0] SW,
    output wire [15:0] LED,
    
    // Camera I/O

    input wire [7:0] wdata_cam,
    input wire vsync_cam,
    input wire href_cam,
    input wire pclk_cam,
    output wire mclk_cam,
    inout i2c_sda,
    inout i2c_scl,

    input wire [3:0] BTNS,
    
    // VGA I/O
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS
    );
    
    // VGA Memory access
    wire [`awidth_fbuff-1:0]            raddr_vga;
    wire [`dwidth_dat-1:0]              rdata_vga;
    
    // Processing access
    wire [`awidth_fbuff-1:0]             waddr_alu;
    wire [`dwidth_dat-1:0]               wdata_alu;
    wire                                 wen_alu;
    wire [(`dwss*`dwidth_dat)-1:0]       rdata_alu;
    wire [`awidth_fbuff-1:0]             raddr_alu;
    wire                                 ren_alu;
    wire [(`dwss*`dwidth_kernel)-1:0]    kernel_alu;
    wire [`dwidth_div-1:0]               div_alu;
    
    mem_controller mc(
        .sys_clk  (CLK100MHZ),
        .rst      (~rst_n   ), 
        .pclk     (pclk_cam ),
        .vsync_cam(vsync_cam),
        .href_cam (href_cam ),
        .wdata_cam(wdata_cam),
        .pass_thru(SW[0]    ),
        .raddr_vga(raddr_vga),
        .rdata_vga(rdata_vga),
        .waddr_alu(waddr_alu),
        .wdata_alu(wdata_alu),
        .wen_alu  (wen_alu  ),
        .raddr_alu(raddr_alu),
        .rdata_alu(rdata_alu),
        .ren_alu  (ren_alu  ),
        .state_debug(LED[5:0])
    );

    ALU alu(
        .clk(CLK100MHZ),
        .din(rdata_alu),
        .kernel(kernel_alu),
        .div(div_alu),
        .raddr_alu(raddr_alu),
        .ren_alu(ren_alu),
        .dout(wdata_alu),
        .waddr_alu(waddr_alu),
        .wen_alu(wen_alu)        
    );

    kernel_ROM kr(
        .kernel_select(SW[2:1]),
        .kernel(kernel_alu),
        .div(div_alu)
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
    
    mmcm_24MHz mmcm0 (
		.clk_100MHz ( CLK100MHZ ),
		.clk_25MHz  ( mclk_cam  )
	);
	
    camera_interface ca(
        .clk_100MHz(CLK100MHZ),
        .rst_n(rst_n),
        .cmos_sda(i2c_sda),         //inout!!
        .cmos_scl(i2c_scl),         //i2c comm wires
        .status(LED[7:6])
    );
endmodule
