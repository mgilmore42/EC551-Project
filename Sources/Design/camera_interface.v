`timescale 1ns / 1ps

  module camera_interface(
	input wire clk,clk_100,rst_n,

	// key[0] increase brightness
	// key[1] decrease brightness
	// key[2] increase contrast
	// key[3] decrease contrast
	input wire[3:0] key,
	//asyn_fifo IO
	input wire rd_en,
	output wire[9:0] data_count_r,
	output wire[15:0] dout,
	//camera pinouts
	input wire cmos_pclk,cmos_href,cmos_vsync,
	input wire[7:0] cmos_db,
	inout cmos_sda,cmos_scl, //i2c comm wires
	output wire cmos_rst_n, cmos_pwdn, cmos_xclk,
	//Debugging
	output wire[3:0] led
    );
	 //FSM state declarations
	 localparam idle=0,
					start_sccb=1,
					write_address=2,
					write_data=3,
					digest_loop=4,
					delay=5,
					vsync_fedge=6,
					byte1=7,
					byte2=8,
					fifo_write=9,
					stopping=10;
					
	 localparam wait_init=0,
					sccb_idle=1,
					sccb_address=2,
					sccb_data=3,
					sccb_stop=4;
					
	 localparam MSG_INDEX=77; //number of the last index to be digested by SCCB
	 
	 
	 
	 reg[3:0] state_q=0,state_d;
	 reg[2:0] sccb_state_q=0,sccb_state_d;
	 reg[7:0] addr_q,addr_d;
	 reg[7:0] data_q,data_d;

	// holds the brightness and and contrast data
	reg[7:0] brightness_q,brightness_d;
	reg[7:0] contrast_q,contrast_d;

	 reg start,stop;
	 reg[7:0] wr_data;
	 wire rd_tick;
	 wire[1:0] ack;
	 wire[7:0] rd_data;
	 wire[3:0] state;
	 reg[3:0] led_q=0,led_d; 
	 reg[27:0] delay_q=0,delay_d;
	 reg start_delay_q=0,start_delay_d;
	 reg delay_finish;
	 reg[15:0] message[250:0];
	 reg[7:0] message_index_q=0,message_index_d;
	 reg[15:0] pixel_q,pixel_d;
	 reg wr_en;
	 wire full;
	 wire key0_tick,key1_tick,key2_tick,key3_tick;
	 
	 //buffer for all inputs coming from the camera
	 reg pclk_1,pclk_2,href_1,href_2,vsync_1,vsync_2;

	 
	initial begin // loads in messages needed to send to camera
		$readmemh("camera_interface.mem",message);
	end
	 
	//register operations
	always @(posedge clk_100,negedge rst_n) begin
		if(!rst_n) begin
			state_q<=0;
			led_q<=0;
			delay_q<=0;
			start_delay_q<=0;
			message_index_q<=0;
			pixel_q<=0;
			
			sccb_state_q<=0;
			addr_q<=0;
			data_q<=0;
			brightness_q<=0;
			contrast_q<=0;
		end else begin
			state_q<=state_d;
			led_q<=led_d;
			delay_q<=delay_d;
			start_delay_q<=start_delay_d;
			message_index_q<=message_index_d;			
			pclk_1<=cmos_pclk; 
			pclk_2<=pclk_1;
			href_1<=cmos_href;
			href_2<=href_1;
			vsync_1<=cmos_vsync;
			vsync_2<=vsync_1;
			pixel_q<=pixel_d;
			
			sccb_state_q<=sccb_state_d;
			addr_q<=addr_d;
			data_q<=data_d;
			brightness_q<=brightness_d;
			contrast_q<=contrast_d;
		end
	 end
	 	 
	 
	//FSM next-state logics
	always @* begin
		state_d=state_q;
		led_d=led_q;
		start=0;
		stop=0;
		wr_data=0;
		start_delay_d=start_delay_q;
		delay_d=delay_q;
		delay_finish=0;
		message_index_d=message_index_q;
		pixel_d=pixel_q;
		wr_en=0;
		
		sccb_state_d=sccb_state_q;
		addr_d=addr_q;
		data_d=data_q;
		brightness_d=brightness_q;
		contrast_d=contrast_q;
		
		//delay logic  
		if(start_delay_q) begin
			delay_d=delay_q+1'b1;
		end

		if(delay_q[16] && message_index_q!=(MSG_INDEX+1) && (state_q!=start_sccb))  begin  //delay between SCCB transmissions (0.66ms)
			delay_finish=1;
			start_delay_d=0;
			delay_d=0;
		end else if((delay_q[26] && message_index_q==(MSG_INDEX+1)) || (delay_q[26] && state_q==start_sccb)) begin //delay BEFORE SCCB transmission, AFTER SCCB transmission, and BEFORE retrieving pixel data from camera (0.67s)
			delay_finish=1;
			start_delay_d=0;
			delay_d=0;
		end
		
		case(state_q) 
		
			////////Begin: Setting register values of the camera via SCCB///////////
					
			idle: begin
				if(delay_finish) begin //idle for 0.6s to start-up the camera
					state_d=start_sccb; 
					start_delay_d=0;
				end else begin
					start_delay_d=1;
				end
			end

			start_sccb: begin   //start of SCCB transmission
				start=1;
				wr_data=8'h42; //slave address of OV7670 for write
				state_d=write_address;						
			end

			write_address: begin
				if(ack==2'b11) begin 
					wr_data=message[message_index_q][15:8]; //write address
					state_d=write_data;
				end
			end

			write_data: begin
				if(ack==2'b11) begin 
					wr_data=message[message_index_q][7:0]; //write data
					state_d=digest_loop;
				end
			end

	 		digest_loop: begin
	 			if(ack==2'b11) begin //stop sccb transmission
					stop=1;
					start_delay_d=1;
					message_index_d=message_index_q+1'b1;
					state_d=delay;
				end
			end

			delay: begin
				if(message_index_q==(MSG_INDEX+1) && delay_finish) begin 
					state_d=vsync_fedge; //if all messages are already digested, proceed to retrieving camera pixel data
					led_d=4'b0110;
				end	else if(state==0 && delay_finish) begin
					state_d=start_sccb; //small delay before next SCCB transmission(if all messages are not yet digested)
				end
			end

			///////////////Begin: Retrieving Pixel Data from Camera to be Stored to SDRAM/////////////////
			vsync_fedge: begin
				if(vsync_1==0 && vsync_2==1) begin
					state_d=byte1; //vsync falling edge means new frame is incoming
				end
			end
			
			byte1: begin
				if(pclk_1==1 && pclk_2==0 && href_1==1 && href_2==1) begin //rising edge of pclk means new pixel data(first byte of 16-bit pixel RGB565) is available at output
					pixel_d[15:8]=cmos_db;
					state_d=byte2;
				end else if(vsync_1==1 && vsync_2==1) begin
					state_d=vsync_fedge;
				end
			end

			byte2: begin
				if(pclk_1==1 && pclk_2==0 && href_1==1 && href_2==1) begin //rising edge of pclk means new pixel data(second byte of 16-bit pixel RGB565) is available at output
					pixel_d[7:0]=cmos_db;
					state_d=fifo_write;
				end else if(vsync_1==1 && vsync_2==1) begin
					state_d=vsync_fedge;
				end
			end

			fifo_write: begin //write the 16-bit data to asynchronous fifo to be retrieved later by SDRAM
				wr_en=1;
				state_d=byte1;
				if(full) begin
					led_d=4'b1001; //debugging led
				end
			end

			default: state_d=idle;

		endcase
		
		//Logic for increasing/decreasing brightness and contrast via the 4 keybuttons
		case(sccb_state_q)
			wait_init: begin
				if(state_q==byte1) begin //wait for initial SCCB transmission to finish
					sccb_state_d=sccb_idle;
					addr_d=0;
					data_d=0;
					brightness_d=8'h00; 
					contrast_d=8'h40;
				end
			end

			sccb_idle: begin
				if(state==0) begin //wait for any pushbutton
					if(key0_tick) begin//increase brightness
						brightness_d=(brightness_q[7]==1)? brightness_q-1:brightness_q+1;
						if(brightness_q==8'h80) brightness_d=0;
						start=1;
						wr_data=8'h42; //slave address of OV7670 for write
						addr_d=8'h55; //brightness control address
						data_d=brightness_d;
						sccb_state_d=sccb_address;
						led_d=0;
					end else if(key1_tick) begin //decrease brightness
						brightness_d=(brightness_q[7]==1)? brightness_q+1:brightness_q-1;
						if(brightness_q==0) brightness_d=8'h80;
						start=1;
						wr_data=8'h42; 
						addr_d=8'h55;
						data_d=brightness_d;
						sccb_state_d=sccb_address;
						led_d=0;
					end else if(key2_tick) begin //increase contrast
						contrast_d=contrast_q+1;
						start=1;
						wr_data=8'h42; //slave address of OV7670 for write
						addr_d=8'h56; //contrast control address
						data_d=contrast_d;
						sccb_state_d=sccb_address;
						led_d=0;
					end else if(key3_tick) begin //change contrast
						contrast_d=contrast_q-1;
						start=1;
						wr_data=8'h42;
						addr_d=8'h56;
						data_d=contrast_d;
						sccb_state_d=sccb_address;
						led_d=0;
					end
				end
			end

			sccb_address: begin
				if(ack==2'b11) begin 
					wr_data=addr_q; //write address
					sccb_state_d=sccb_data;
				end
			end

			sccb_data: begin
				if(ack==2'b11) begin 
					wr_data=data_q; //write databyte
					sccb_state_d=sccb_stop;
				end
			end

			sccb_stop: begin
				if(ack==2'b11) begin //stop
					stop=1;
					sccb_state_d=sccb_idle;
					led_d=4'b1001;
				end
			end

			default: sccb_state_d=wait_init;
		endcase
		
	end //awlays
	

	assign cmos_pwdn=0; 
	assign cmos_rst_n=1;
	assign led=led_q;
	 
	//module instantiations
	i2c_top #(.freq(100_000)) m0 (
		.clk     ( clk_100  ),
		.rst_n   ( rst_n    ),
		.start   ( start    ),
		.stop    ( stop     ),
		.wr_data ( wr_data  ),
		.rd_tick ( rd_tick  ), //ticks when read data from servant is ready,data will be taken from rd_data
		.ack     ( ack      ), //ack[1] ticks at the ack bit[9th bit],ack[0] asserts when ack bit is ACK,else NACK
		.rd_data ( rd_data  ), 
		.scl     ( cmos_scl ),
		.sda     ( cmos_sda ),
		.state   ( state    )
    ); 
	 
	 
	dcm_24MHz m1 (// Clock in ports
    	.clk       ( clk       ),
    	.cmos_xclk ( cmos_xclk ),
    	.RESET     ( RESET     ),
    	.LOCKED    ( LOCKED    )
    );

	//1024x16 FIFO mem
	asyn_fifo #(.DATA_WIDTH(16),.FIFO_DEPTH_WIDTH(10)) m2 (
		.rst_n        ( rst_n        ),
		.clk_write    ( clk_100      ),
		.clk_read     ( clk_100      ), //clock input from both domains
		.write        ( wr_en        ),
		.read         ( rd_en        ), 
		.data_write   ( pixel_q      ), //input FROM write clock domain
		.data_read    ( dout         ), //output TO read clock domain
		.full         ( full         ),
		.empty        (              ), //full=sync to write domain clk , empty=sync to read domain clk
		.data_count_r ( data_count_r ) //asserted if fifo is equal or more than than half of its max capacity
    );
	
	debounce_explicit m3 (
		.clk      ( clk_100   ),
		.rst_n    ( rst_n     ),
		.sw       ( {!key[0]} ),
		.db_level (           ),
		.db_tick  ( key0_tick )
    );
	 
	debounce_explicit m4 (
		.clk      ( clk_100   ),
		.rst_n    ( rst_n     ),
		.sw       ( {!key[1]} ),
		.db_level (           ),
		.db_tick  ( key1_tick )
    );
	 
	debounce_explicit m5 (
		.clk      ( clk_100   ),
		.rst_n    ( rst_n     ),
		.sw       ( {!key[2]} ),
		.db_level (           ),
		.db_tick  ( key2_tick )
    );
	 
	debounce_explicit m6 (
		.clk      ( clk_100   ),
		.rst_n    ( rst_n     ),
		.sw       ( {!key[3]} ),
		.db_level (           ),
		.db_tick  ( key3_tick )
    );
	
endmodule
