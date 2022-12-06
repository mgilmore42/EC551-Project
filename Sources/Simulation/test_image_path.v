`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2022 03:05:13 PM
// Design Name: 
// Module Name: test_image_path
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


module test_image_path(

    );
    // Sys wires
    // General
    reg CLK100MHZ;
    reg rst_n;
    reg [15:0] SW;
//    wire[15:0] LED;
    
    // Camera I/O

    reg [7:0] wdata_cam;
    reg vsync_cam;
    reg href_cam;
    reg pclk_cam;
    wire mclk_cam;
    
    // VGA I/O
    wire [3:0] VGA_R;
    wire [3:0] VGA_G;
    wire [3:0] VGA_B;
    wire VGA_HS;
    wire VGA_VS;
    
    // VGA Memory access
    wire [`awidth_fbuff-1:0]            raddr_vga;
    wire [`dwidth_dat-1:0]              rdata_vga;
    
    // Processing access
    wire [`awidth_fbuff-1:0]             raddr_alu;
    wire [`awidth_fbuff-1:0]             waddr_alu;
    wire [`dwidth_dat-1:0]               wdata_alu;
    wire                                  wen_alu;
    wire                                  ren_alu;
    wire [(`dwss*`dwidth_dat)-1:0]       rdata_alu;
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
        .ren_alu  (ren_alu  )
//        .state_debug(LED[5:0])
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
    
    always // 100MHz clk
        #1 CLK100MHZ = ~CLK100MHZ;
    
    always // 25Mhz clk
        #4 pclk_cam = ~pclk_cam;
        
    integer i;
    // write loops
    initial begin
        CLK100MHZ  ='b0;
        pclk_cam     ='b0;
        vsync_cam='b0;
        href_cam ='b0;
        SW = 'b0;
        
        // reset
        rst_n      =0; #10; rst_n      ='b1;
        
        // vsync
        #10; vsync_cam = 1; #40; vsync_cam = 0;
         
        // loop
        for (i = 0; i <=(481*20); i=i+1) begin
//        for (i = 0; i <=(481*640); i=i+1) begin
            if (i%640==0) begin
                // set href low then high
                href_cam = 0; #40; href_cam = 1;
            end
            
            wdata_cam = {4'b0000,i[11:8]}; #8;
            wdata_cam = i[7:0]; #8;
        end
        
        $finish;    
    end
endmodule
