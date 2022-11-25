`timescale 1ns / 1ps

module top_test (
		input wire clk,rst_n,
		input wire[3:0] key, //key[1:0] for brightness control , key[3:2] for contrast control
		//camera pinouts
		input wire cmos_pclk,cmos_href,cmos_vsync,
		input wire[7:0] cmos_db,
		inout cmos_sda,cmos_scl, 
		output wire cmos_rst_n, cmos_pwdn, cmos_xclk,
		//VGA output
		output wire[3:0] vga_out_r,
		output wire[3:0] vga_out_g,
		output wire[3:0] vga_out_b,
		output wire vga_out_vs,vga_out_hs
	);
	 
	wire        f2s_data_valid;
	wire [ 9:0] data_count_r;
	wire [15:0] dout;
	wire [15:0] din;
	wire        clk_sdram;
	wire        empty_fifo;
	wire        clk_vga;
	wire        state;
	wire        rd_en;

	//control logic for retrieving data from camera, storing data to asyn_fifo, and  sending data to sdram
	camera_interface m0 (
		.clk     (clk       ),
		.clk_100 (clk_sdram ),
		.rst_n   (rst_n     ),
		.key     (key       ),
		//asyn_fifo IO
		.rd_en        ( f2s_data_valid ),
		.data_count_r ( data_count_r   ),
		.dout         ( dout           ),
		//camera pinouts
		.cmos_pclk  ( cmos_pclk  ),
		.cmos_href  ( cmos_href  ),
		.cmos_vsync ( cmos_vsync ),
		.cmos_db    ( cmos_db    ),
		.cmos_sda   ( cmos_sda   ),
		.cmos_scl   ( cmos_scl   ), 
		.cmos_rst_n ( cmos_rst_n ),
		.cmos_pwdn  ( cmos_pwdn  ),
		.cmos_xclk  ( cmos_xclk  )
    );
	 
	//control logic for retrieving data from sdram, storing data to asyn_fifo, and sending data to vga
	vga_interface m2 (
		.clk   ( clk   ),
		.rst_n ( rst_n ),
		//asyn_fifo IO
		.empty_fifo ( empty_fifo ),
		.din        ( din        ),
		.clk_vga    ( clk_vga    ),
		.rd_en      ( rd_en      ),
		//VGA output
		.vga_out_r  ( vga_out_r  ),
		.vga_out_g  ( vga_out_g  ),
		.vga_out_b  ( vga_out_b  ),
		.vga_out_vs ( vga_out_vs ),
		.vga_out_hs ( vga_out_hs )
    );
	
	//SDRAM clock
	dcm_165MHz m3 (// Clock in ports
		.clk( clk ),      // IN
		// Clock out ports
		.clk_sdram( clk_sdram ),     // OUT
		// Status and control signals
		.RESET  ( RESET  ),// IN
		.LOCKED ( LOCKED )
	);      // OUT


endmodule
