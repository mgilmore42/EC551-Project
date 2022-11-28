`timescale 1ps/1ps

module mmcm_24MHz (// Clock in ports
		// Clock out ports
		output reg  clk_25MHz,
		input  wire clk_100MHz
	);

	reg count;
	
	initial begin
		count     <= 0;
		clk_25MHz <= 0;
	end
	
	// FF
	always @(posedge clk_100MHz) begin
		count = count + 1;
	end
	
	// FF with enable
	always @(posedge clk_100MHz) begin
		clk_25MHz <= ~clk_25MHz;
	end

endmodule
