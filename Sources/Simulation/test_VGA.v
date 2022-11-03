`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 09:24:36 PM
// Design Name: 
// Module Name: test_VGA
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


module test_VGA(

    );
    
    reg rst, pixel_clk;
	wire HS, VS, blank;
	wire [10:0] hcounter, vcounter;
	
	vga_controller_640_60 vc (rst,pixel_clk,HS,VS,hcounter,vcounter,blank);
	
	always
	    #1 pixel_clk = ~pixel_clk;
	   
    initial begin
        pixel_clk = 0;
        rst = 1; #10; rst = 0;
        
        #(640*480);
        $finish;
    end

endmodule
