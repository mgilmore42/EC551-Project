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

	localparam MSG_INDEX = 3; //number of the last index to be digested by SCCB

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
		message[0] <= 16'h12_80;  //reset all register to default values
		message[1] <= 16'h12_04;  //set output format to RGB
		message[2] <= 16'h15_20;  //pclk will not toggle during horizontal blank
		message[3] <= 16'h8C_02;  //RGB444 in XR GB format

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