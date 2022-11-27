`timescale 1ns / 1ps

// Generate HS, VS signals from pixel clock.
// hcounter & vcounter are the index of the current pixel 
// origin (0, 0) at top-left corner of the screen
// valid display range for hcounter: [0, 640)
// valid display range for vcounter: [0, 480)
module vga_controller_640_60(rst, pixel_clk,HS,VS,hcounter,vcounter,blank);

	input pixel_clk, rst;
	output reg HS, VS, blank;
	output reg [10:0] hcounter, vcounter;

	parameter HMAX = 800; // maximum value for the horizontal pixel counter, orig: 800
	parameter VMAX = 525; // maximum value for the vertical pixel counter, orig: 525
	parameter HLINES = 640; // total number of visible columns, orig: 640
	parameter HFP = 648; // value for the horizontal counter where front porch ends, orig: 648
	parameter HSP = 744; // value for the horizontal counter where the synch pulse ends, orig: 744
	parameter VLINES = 480; // total number of visible lines, orig: 480
	parameter VFP = 482; // value for the vertical counter where the front porch ends, orig: 482
	parameter VSP = 484; // value for the vertical counter where the synch pulse ends, orig: 484
	parameter SPP = 0;

	wire video_enable;


	always@(posedge pixel_clk)begin
		blank <= ~video_enable; 
	end

	always@(posedge pixel_clk)begin
	   if(rst==1) begin
        hcounter<=11'b0;
        end
		else if (hcounter == HMAX) hcounter <= 0;
		else hcounter <= hcounter + 1;
	end

	always@(posedge pixel_clk)begin
	    if(rst==1) begin
        vcounter<=11'b0;
        end
		else if(hcounter == HMAX) begin
			if(vcounter == VMAX) vcounter <= 0;
			else vcounter <= vcounter + 1; 
		end
	end

	always@(posedge pixel_clk)begin
		if(hcounter >= HFP && hcounter < HSP) HS <= SPP;
		else HS <= ~SPP; 
	end

	always@(posedge pixel_clk)begin
		if(vcounter >= VFP && vcounter < VSP) VS <= SPP;
		else VS <= ~SPP; 
	end

	assign video_enable = (hcounter < HLINES && vcounter < VLINES) ? 1'b1 : 1'b0;

endmodule