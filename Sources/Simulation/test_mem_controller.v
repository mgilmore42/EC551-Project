`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2022 10:44:55 PM
// Design Name: 
// Module Name: test_mem_controller
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


module test_mem_controller(

    );
    
    // General signal
    reg sys_clk;
    reg rst;
    
    // Camera Data
    reg pclk;
    reg vsync_cam;
    reg href_cam;
    reg [7:0] wdata_cam;
    
    // VGA Memory access
    reg [18:0] raddr_vga;
    wire [11:0] rdata_vga;
    
    // Processing access
    reg [`awidth_fbuff-1:0] waddr_alu;
    reg [`dwidth_dat-1:0] wdata_alu;
    reg        wen_alu;
    wire [`awidth_fbuff-1:0] raddr_alu;
    wire [(`dwss*`dwidth_dat)-1:0] rdata_alu;
    
    mem_controller mc0 (
        .sys_clk  (sys_clk  ),
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
        .rdata_alu(rdata_alu));
    
    
    always // 100MHz clk
        #1 sys_clk = ~sys_clk;
    
    always // 25Mhz clk
        #4 pclk = ~pclk;
        
        
    integer i, k;
    // write loops
    initial begin
        sys_clk  ='b0;
        pclk     ='b0;
        vsync_cam='b0;
        href_cam ='b0;
        wdata_cam='b0;
        raddr_vga='b0;
        waddr_alu='b0;
        wdata_alu='b0;
        wen_alu  ='b0;
        
        // reset
        rst      =1; #10; rst      ='b0;
        
        // vsync
        #10; vsync_cam = 1; #40; vsync_cam = 0;
         
        // loop
        for (i = 0; i <=(481*40); i=i+1) begin
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
    
    // read loops
    initial begin
        #(100+16*2);
        // loop through rows
        for (k = 0; k<(481*640); k=k+1) begin
            raddr_vga = k;
            #16;
        end
        
    end
endmodule
