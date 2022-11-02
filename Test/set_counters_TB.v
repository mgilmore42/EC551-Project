`timescale 1ns / 1ps

module set_counters_TB;

    reg pixel_clk;
    reg [18:0] raddr_vga;
    wire [10:0] vga_hcnt, vga_vcnt;

    set_counters uut (pixel_clk,raddr_vga,vga_hcnt,vga_vcnt);
    
    initial begin
    pixel_clk = 0; raddr_vga = 19'b0011101010101111100;
    //pixel_clk = 0; raddr_vga = 19'b0000000000000000100;
    #10 pixel_clk = 1; 
    #10 $finish;
    end
    
endmodule
