module set_counters(pixel_clk,raddr_vga,vga_hcnt,vga_vcnt);
    
    input pixel_clk;
    input [18:0] raddr_vga;
    output reg [10:0] vga_hcnt, vga_vcnt;
    
    always @ (posedge pixel_clk) begin
    vga_hcnt = raddr_vga % 640;
    vga_vcnt = raddr_vga / 640;
    end
 
endmodule
