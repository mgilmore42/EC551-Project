`timescale 1ns / 1ps

module camera_interface (
		input wire clk_100MHz,
		input wire rst_n,
		//camera pinouts
		inout             cmos_sda,
		inout             cmos_scl,
		output wire [2:0] status // for debugging
	);


	//FSM state declarations
	localparam idle          = 3'd0;
	localparam start_sccb    = 3'd1;
	localparam write_address = 3'd2;
	localparam write_data    = 3'd3;
	localparam digest_loop   = 3'd4;
	localparam delay         = 3'd5;
	localparam done          = 3'd6;

	localparam MSG_INDEX = 'h37; //number of the last index to be digested by SCCB

	reg        stop;
	reg        start;
	reg        start_delay_q;
	reg        start_delay_d;
	reg        delay_finish;

	reg [ 3:0] state_q;
	reg [ 3:0] state_d;
	reg [ 7:0] wr_data;
	reg [ 7:0] message_index_q;
	reg [ 7:0] message_index_d;
	reg [27:0] delay_q;
	reg [27:0] delay_d;

	reg [15:0] message [MSG_INDEX:0];
	
	wire       rd_tick;
	wire [1:0] ack;
	wire [7:0] rd_data;
	wire [3:0] state;


	initial begin //collection of all adddresses and values to be written in the camera {address,data}
//		message[0] <= 16'h12_80;  //reset all register to default values
//		message[1] <= 16'h12_04;  //set output format to RGB
//		message[2] <= 16'h15_20;  //pclk will not toggle during horizontal blank
//		message[3] <= 16'h8C_02;  //RGB444 in XR GB format
		
		
		message[8'h00] <= 16'h1280; // COM7   Reset
        message[8'h01] <= 16'h12_80; // COM7   Reset
        message[8'h02] <= 16'h12_04; // COM7   Size & RGB output
        message[8'h03] <= 16'h11_00; // CLKRC  Prescaler - Fin/(1+1)
        message[8'h04] <= 16'h0C_00; // COM3   Lots of stuff, enable scaling, all others off
        message[8'h05] <= 16'h3E_00; // COM14  PCLK scaling off
        message[8'h06] <= 16'h8C_02; // RGB444 Set RGB format
        message[8'h07] <= 16'h04_00; // COM1   no CCIR601
        message[8'h08] <= 16'h40_10; // COM15  Full 0-255 output, RGB 565
        message[8'h09] <= 16'h3a_04; // TSLB   Set UV ordering,  do not auto-reset window
        message[8'h0A] <= 16'h14_38; // COM9  - AGC Celling
        message[8'h0B] <= 16'h4f_b3; // MTX1  - colour conversion matrix
        message[8'h0C] <= 16'h50_b3; // MTX2  - colour conversion matrix
        message[8'h0D] <= 16'h51_00; // MTX3  - colour conversion matrix
        message[8'h0E] <= 16'h52_3d; // MTX4  - colour conversion matrix
        message[8'h0F] <= 16'h53_a7; // MTX5  - colour conversion matrix
        message[8'h10] <= 16'h54_e4; // MTX6  - colour conversion matrix
        message[8'h11] <= 16'h58_9e; // MTXS  - Matrix sign and auto contrast
        message[8'h12] <= 16'h3d_c0; // COM13 - Turn on GAMMA and UV Auto adjust
        message[8'h13] <= 16'h11_00; // CLKRC  Prescaler - Fin/(1+1)
        message[8'h14] <= 16'h17_11; // HSTART HREF start (high 8 bits)
        message[8'h15] <= 16'h18_61; // HSTOP  HREF stop (high 8 bits)
        message[8'h16] <= 16'h32_A4; // HREF   Edge offset and low 3 bits of HSTART and HSTOP
        message[8'h17] <= 16'h19_03; // VSTART VSYNC start (high 8 bits)
        message[8'h18] <= 16'h1A_7b; // VSTOP  VSYNC stop (high 8 bits) 
        message[8'h19] <= 16'h03_0a; // VREF   VSYNC low two bits
        message[8'h1A] <= 16'h0e_61; // COM5(0x0E) 0x61
        message[8'h1B] <= 16'h0f_4b; // COM6(0x0F) 0x4B 
        message[8'h1C] <= 16'h16_02;
        message[8'h1D] <= 16'h1e_27; // MVFP (0x1E) 0x07  -- FLIP AND MIRROR IMAGE 0x3x
        message[8'h1E] <= 16'h21_02;
        message[8'h1F] <= 16'h22_91;
        message[8'h20] <= 16'h29_07;
        message[8'h21] <= 16'h33_0b;                   
        message[8'h22] <= 16'h35_0b;
        message[8'h23] <= 16'h37_1d;                    
        message[8'h24] <= 16'h38_71;
        message[8'h25] <= 16'h39_2a;              
        message[8'h26] <= 16'h3c_78; // COM12 (0x3C) 0x78
        message[8'h27] <= 16'h4d_40; 
        message[8'h28] <= 16'h4e_20;
        message[8'h29] <= 16'h69_00; // GFIX (0x69) 0x00                    
        message[8'h2A] <= 16'h6b_4a;
        message[8'h2B] <= 16'h74_10;             
        message[8'h2C] <= 16'h8d_4f;
        message[8'h2D] <= 16'h8e_00;           
        message[8'h2E] <= 16'h8f_00;
        message[8'h2F] <= 16'h90_00;            
        message[8'h30] <= 16'h91_00;
        message[8'h31] <= 16'h96_00;
        message[8'h32] <= 16'h9a_00;
        message[8'h33] <= 16'hb0_84;
        message[8'h34] <= 16'hb1_0c;
        message[8'h35] <= 16'hb2_0e;
        message[8'h36] <= 16'hb3_82;
        message[8'h37] <= 16'hb8_0a;

		// initializes stateful registers
		state_q         <= idle;
		delay_q         <= 0;
		start_delay_q   <= 0;
		message_index_q <= 0;
	end

	assign status = message_index_q; // for debugging

	//register operations
	always @(posedge clk_100MHz, negedge rst_n) begin
		if(!rst_n) begin
			state_q         <= idle;
			delay_q         <= 0;
			start_delay_q   <= 0;
			message_index_q <= 0;
		end else begin
			state_q         <= state_d;
			delay_q         <= delay_d;
			start_delay_q   <= start_delay_d;
			message_index_q <= message_index_d;
		end
	end

	// determines if the camera initialization is complete
/* 	always @(*) begin
		if (state == done) begin
			finished = 1;
		end else begin
			finished = 0;
		end
	end */


	//FSM next-state logics
	always @* begin
		state_d         = state_q;
		start           = 0;
		stop            = 0;
		wr_data         = 0;
		start_delay_d   = start_delay_q;
		delay_d         = delay_q;
		delay_finish    = 0;
		message_index_d = message_index_q;
		
		//delay logic  
		if(start_delay_q) begin
			delay_d = delay_q + 1'b1;
		end

		if(delay_q[16] && message_index_q!=(MSG_INDEX+1) && (state_q!=start_sccb))  begin  //delay between SCCB transmissions (0.66ms)
			delay_finish  = 1;	
			start_delay_d = 0;	
			delay_d       = 0;
		end else if((delay_q[26] && message_index_q==(MSG_INDEX+1)) || (delay_q[26] && state_q==start_sccb)) begin //delay BEFORE SCCB transmission, AFTER SCCB transmission, and BEFORE retrieving pixel data from camera (0.67s)
			delay_finish  = 1;
			start_delay_d = 0;
			delay_d       = 0;
		end

		case(state_q) 

			////////Begin: Setting register values of the camera via SCCB///////////
			idle: begin
				if(delay_finish) begin //idle for 0.6s to start-up the camera
					state_d       = start_sccb; 
					start_delay_d = 0;
				end else begin
					start_delay_d = 1;
				end
			end

			start_sccb: begin   //start of SCCB transmission
				start   = 1;
				wr_data = 8'h42; //slave address of OV7670 for write
				state_d = write_address;
			end

			write_address: begin
				if (ack == 2'b11) begin 
					wr_data = message[message_index_q][15:8]; //write address
					state_d = write_data;
				end
			end

			write_data: begin
				if (ack == 2'b11) begin 
					wr_data = message[message_index_q][7:0]; //write data
					state_d = digest_loop;
				end
			end

			digest_loop: begin
				if (ack == 2'b11) begin //stop sccb transmission
					stop            = 1;
					start_delay_d   = 1;
					message_index_d = message_index_q + 1'b1;
					state_d         = delay;
				end
			end

			delay: begin
				if ((message_index_q == MSG_INDEX + 1) && delay_finish) begin 
					state_d = done; //if all messages are already digested, proceed to retrieving camera pixel data
				end else if ((state == 0) && delay_finish) begin
					state_d = start_sccb; //small delay before next SCCB transmission(if all messages are not yet digested)
				end
			end

			done: begin
				state_d = done;
			end

			default: begin
				state_d = state_q;
			end

		endcase
	end

	//module instantiations
	i2c_top #(.freq(100_000)) m0 (
		.clk     ( clk_100MHz ),
		.rst_n   ( rst_n      ),
		.start   ( start      ),
		.stop    ( stop       ),
		.wr_data ( wr_data    ),
		.rd_tick ( rd_tick    ), //ticks when read data from servant is ready,data will be taken from rd_data
		.ack     ( ack        ), //ack[1] ticks at the ack bit[9th bit],ack[0] asserts when ack bit is ACK,else NACK
		.rd_data ( rd_data    ), 
		.scl     ( cmos_scl   ),
		.sda     ( cmos_sda   ),
		.state   ( state      )
	);

endmodule