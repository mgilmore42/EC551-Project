`timescale 1ns / 1ps

module camera_interface(
		input wire clk,
		input wire clk_100,
		input wire rst_n,
		//camera pinouts
		input wire       cmos_pclk,
		input wire       cmos_href,
		input wire       cmos_vsync,
		inout            cmos_sda,
		inout            cmos_scl,
		output wire      cmos_xclk
	);
	
	
	//FSM state declarations
	localparam idle          =  0;
	localparam start_sccb    =  1;
	localparam write_address =  2;
	localparam write_data    =  3;
	localparam digest_loop   =  4;
	localparam delay         =  5;
	localparam vsync_fedge   =  6;
	localparam byte1         =  7;
	localparam byte2         =  8;
	localparam fifo_write    =  9;
	localparam stopping      = 10;

	localparam wait_init    = 0;
	localparam sccb_idle    = 1;
	localparam sccb_address = 2;
	localparam sccb_data    = 3;
	localparam sccb_stop    = 4;

	localparam MSG_INDEX = 3; //number of the last index to be digested by SCCB
	 
	reg        stop;
	reg        start;
	reg        wr_en;
	reg        start_delay_q=0;
	reg        start_delay_d;
	reg        delay_finish;

	reg [ 2:0] sccb_state_q=0;
	reg [ 2:0] sccb_state_d;
	reg [ 3:0] state_q=0;
	reg [ 3:0] state_d;
	reg [ 7:0] addr_q;
	reg [ 7:0] addr_d;
	reg [ 7:0] data_q;
	reg [ 7:0] data_d;
	reg [ 7:0] wr_data;
	reg [ 7:0] message_index_q=0;
	reg [ 7:0] message_index_d;
	reg [27:0] delay_q=0;
	reg [27:0] delay_d;

	reg [15:0] message [3:0];
	
	wire       rd_tick;
	wire [1:0] ack;
	wire [7:0] rd_data;
	wire [3:0] state;
	 
	 //buffer for all inputs coming from the camera
	 reg pclk_1,pclk_2,href_1,href_2,vsync_1,vsync_2;

	 
	initial begin //collection of all adddresses and values to be written in the camera {address,data}
		message[0]=16'h12_80;  //reset all register to default values
		message[1]=16'h12_04;  //set output format to RGB
		message[2]=16'h15_20;  //pclk will not toggle during horizontal blank
		message[3]=16'h8C_03;  //RGB444 in RG BX format
	end

	//register operations
	always @(posedge clk,negedge rst_n) begin
		if(!rst_n) begin
			state_q         <= 0;
			delay_q         <= 0;
			start_delay_q   <= 0;
			message_index_q <= 0;
			
			sccb_state_q <= 0;
			addr_q       <= 0;
			data_q       <= 0;
		end else begin
			state_q         <= state_d;
			delay_q         <= delay_d;
			start_delay_q   <= start_delay_d;
			message_index_q <= message_index_d;			
			pclk_1          <= cmos_pclk; 
			pclk_2          <= pclk_1;
			href_1          <= cmos_href;
			href_2          <= href_1;
			vsync_1         <= cmos_vsync;
			vsync_2         <= vsync_1;

			sccb_state_q <= sccb_state_d;
			addr_q       <= addr_d;
			data_q       <= data_d;
		end
	end
	 	 
	 
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
		wr_en           = 0;

		sccb_state_d = sccb_state_q;
		addr_d       = addr_q;
		data_d       = data_q;
		
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
				end else if(state==0 && delay_finish) begin
					state_d=start_sccb; //small delay before next SCCB transmission(if all messages are not yet digested)
				end
			end
		endcase
	end
	 
	 //module instantiations
	i2c_top #(.freq(100_000)) m0 (
		.clk     ( clk      ),
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
	 
	 
	dcm_24MHz m1 (
		// Clock in ports
		.clk ( clk ),      // IN
		// Clock out ports
		.cmos_xclk ( cmos_xclk ),     // OUT
		// Status and control signals
		.RESET  ( ~rst_n ),// IN
		.LOCKED (        )
	);      // OUT
	
endmodule
