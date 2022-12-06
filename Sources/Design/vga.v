`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////////////////

// vga module that instantiate the VGA controller and generate images
module vga(
    input wire CLK100MHZ,
    input wire rst,
    input wire [11:0] rdata_vga,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS,
	output wire [18:0] raddr_vga
    );

reg pclk_div_cnt;
reg pixel_clk;
wire [10:0] vga_hcnt, vga_vcnt;
wire vga_blank;

// Calculate read address, advanced by on clock
reg [11:0] RGB;
// assign raddr_vga = {2'b0,vga_vcnt,8'b0} + {4'b0,vga_vcnt,6'b0} + {10'b0,(vga_hcnt-1)}; // 640(1010000000) * row_cnt + col_cnt = (2^9+2^7) * row_cnt + col_cnt, avoids 18 bit multiplication
assign raddr_vga =  {1'b0,vga_vcnt,9'b0} + {3'b0,vga_vcnt,7'b0} + {10'b0,vga_hcnt}; // 640(1010000000) * row_cnt + col_cnt = (2^9+2^7) * row_cnt + col_cnt, avoids 18 bit multiplication
always @(posedge pixel_clk)
    RGB <= rdata_vga;

// Clock divider. Generate 25MHz pixel_clk from 100MHz clock.
always @(posedge CLK100MHZ) begin
    pclk_div_cnt <= !pclk_div_cnt;
    if (pclk_div_cnt == 1'b1) pixel_clk <= !pixel_clk;
end

// Instantiate VGA controller
vga_controller_640_60 vga_controller(
    .rst(rst),
    .pixel_clk(pixel_clk),
    .HS(VGA_HS),
    .VS(VGA_VS),
    .hcounter(vga_hcnt),
    .vcounter(vga_vcnt),
    .blank(vga_blank)
);

// Generate figure to be displayed
// Decide the color for the current pixel at index (hcnt, vcnt).
always @(*) begin
    // Set pixels to black during Sync. Failure to do so will result in dimmed colors or black screens.
    if (vga_blank) begin 
        VGA_R = 0;
        VGA_G = 0;
        VGA_B = 0;
    end
    else begin  // Image to be displayed
        VGA_R = RGB[11:8];
        VGA_G = RGB[7:4];
        VGA_B = RGB[3:0];
    end
end

endmodule