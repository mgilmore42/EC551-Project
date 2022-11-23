`timescale 1ns / 1ps

`include "my_header.vh"

module mem_controller(

    // General signal
    input wire                     sys_clk,
    input wire                     rst,

    // Camera Data
    input wire                     pclk,
    input wire                     vsync_cam,
    input wire                     href_cam,
    input wire [7:0]               wdata_cam,
    input wire                     pass_thru,
    
    // VGA Memory access           
    input wire [18:0]              raddr_vga,
    output wire [11:0]             rdata_vga,
    
    // Processing access
    input wire [`awidth_fbuff-1:0] waddr_alu,
    input wire [`dwidth_dat-1:0]   wdata_alu,
    input wire                     wen_alu,
    output wire [`awidth_fbuff-1:0] raddr_alu,
    output wire [(`dwss*`dwidth_dat)-1:0]  rdata_alu
    
    );

//    localparam pad = ($floor(`dwidth_slice/2));
    localparam pad = 2;    
    // mux between passthrough mode and process mode
    
    wire [`awidth_fbuff-1:0] waddr_cam;
    reg  [`dwidth_dat-1:0] wdata_cam_full;
    reg  wen_cam, wen_cbuff;
    wire wen_cam_p, wen_cbuff_p;
    reg  [9:0]  hcnt_c, hcnt_n; // pix in row
    reg  [8:0]  vcnt_c, vcnt_n; // row of pix
    wire [8:0]  vcnt_r;
    reg  [2:0]  ws_c, ws_n, rs_c, rs_n; // FSM states
    reg         wen_n; // assemble both bytes
    reg  pop_pbuff, pop_pbuff_n, pop_cbuff, pop_cbuff_n;
    wire pop_pbuff_p, pop_cbuff_p;
    reg  [3:0]  dlast; // previous data

    wire [(`dwidth_dat*`dwidth_slice)-1:0] rdata_pbuff;
    wire [(`dwidth_dat*`dwidth_slice)-1:0] rdata_cbuff;

    localparam [2:0] IDLE = 'd0, HREF = 'd1, B0   = 'd2, B1   = 'd3, POP = 'd4;
    localparam [2:0]              VPAD = 2'd1, HPAD = 2'd2, READ = 2'd3;
    

    partial_buffer pbuff (
        .clk(sys_clk),
        .rst(rst),
        .wen(wen_cam_p),
        .pop(pop_pbuff_p),
        .waddr(hcnt_c),
        .wdata(wdata_cam_full),
        .raddr(hcnt_c),
        .rdata(rdata_pbuff)
    );

    wire [11:0] douta;

    full_buffer fbuff (
        .clka(sys_clk),    // input wire clka
        .wea((pass_thru) ? wen_cam : wen_alu),      // input wire [0 : 0] wea
        .addra((pass_thru) ? waddr_cam : waddr_alu),  // input wire [18 : 0] addra
        .dina((pass_thru) ? wdata_cam_full : wdata_alu),    // input wire [11 : 0] dina
        .douta(douta),  // output wire [11 : 0] douta
        .clkb(sys_clk),    // input wire clkb
        .web('b0),      // input wire [0 : 0] web
        .addrb(raddr_vga),  // input wire [18 : 0] addrb
        .dinb('b0),    // input wire [11 : 0] dinb
        .doutb(rdata_vga)   // output wire [11 : 0] doutb
    );
    
    conv_buffer cbuff (
        .clk(sys_clk),
        .rst(rst),
        .wen(wen_cam_p), // written on every new val written
        .pop(wen_cam_p), // popped as well
        .wdata(rdata_pbuff),
        .rdata(rdata_cbuff)
    );

    // data writing FSM
    assign waddr_cam = {1'b0,vcnt_c,9'b0} + {3'b0,vcnt_c,7'b0} + {10'b0,hcnt_c}; // 640(1010000000) * row_cnt + col_cnt = (2^9+2^7) * row_cnt + col_cnt, avoids 18 bit multiplication
    always @(posedge pclk) begin
        if (rst) begin
            ws_c <= 'b0;
            hcnt_c <= 'b0;
            vcnt_c <= 'b0;
            wen_cam <= 'b0;
            dlast <= 'b0;
            pop_pbuff <= 'b0;
        end else begin
            ws_c <= ws_n;
            hcnt_c <= hcnt_n;
            vcnt_c <= vcnt_n;
            wen_cam <= wen_n;
            dlast <= wdata_cam[3:0];
            pop_pbuff <= pop_pbuff_n;
            wdata_cam_full <= {dlast,wdata_cam};
        end        
    end
    
    always @(*) begin
        case(ws_c)
            IDLE : begin // idle, waiting for vsync
                ws_n = (vsync_cam) ? HREF : IDLE; // next state is 
                hcnt_n = 'b0;
                vcnt_n = 'b0;
                wen_n = 'b0;
                pop_pbuff_n = 'b0;
            end
            HREF : begin // active, waiting for href
                ws_n = (vcnt_c==`vwidth) ? IDLE : ((href_cam) ? B0 : HREF); // reset if count=480, progress if href, wait otherwise
                hcnt_n = 'b0;
                vcnt_n = vcnt_c;
                wen_n = 'b0;
                pop_pbuff_n = 'b0;
            end
            B0 : begin // active, captured first half of data
                ws_n = (href_cam) ? B1 : HREF;
                hcnt_n = hcnt_c;
                vcnt_n = vcnt_c;
                wen_n = 'b1;
                pop_pbuff_n = 'b0;
            end
            B1 : begin // active, captured second half of data and write
                ws_n = ((hcnt_c<(`hwidth-1)) && href_cam) ? B0 : POP;
                hcnt_n = hcnt_c + 1;
                vcnt_n = (hcnt_c<(`hwidth-1)) ? vcnt_c : vcnt_c+1;
                wen_n = 1'b0;
                pop_pbuff_n = 'b0;
            end
            POP : begin // commit values
                ws_n = HREF;
                hcnt_n = hcnt_c;
                vcnt_n = vcnt_c;
                wen_n = 1'b0;
                pop_pbuff_n = 'b1;
            end
        endcase
    end

    // data reading FSM
    assign vcnt_r = vcnt_c-pad-1; // read vertical count lags behind the write vcnt by half the kernel size
    assign raddr_alu = {1'b0,vcnt_r,9'b0} + {3'b0,vcnt_r,7'b0} + {10'b0,hcnt_c};

    always @(posedge sys_clk) begin // clock to be determined
        if (rst)
            rs_c <= 0;
        else
            rs_c <= rs_n;
    end
    assign rdata_alu = (rs_c==READ) ? rdata_cbuff : 'b0; // data going to the ALU will be 0's when buffer is not full/ready
    always @(*) begin // Mealy machine
        case(rs_c)
            IDLE : begin // the clocks before the write address is valid
                rs_n = ((vcnt_c-pad-1) == 0) ? VPAD : IDLE;
            end
            VPAD : begin // The first floor(N/2) rows which will just be black
                rs_n = (vcnt_c < `dwidth_slice) ? VPAD : HPAD;
            end
            HPAD : begin // active, waiting for href
                if (hcnt_c < pad-1) begin // front padding
                    rs_n = HPAD;
                end else if (hcnt_c >= `hwidth-pad-1) begin // end padding
                    if (hcnt_c == `hwidth-1 && vcnt_c == `vwidth-1) // last value
                        rs_n = IDLE;
                    else
                        rs_n = HPAD;
                end else begin
                    rs_n = READ;
                end
            end
            READ: begin // active, captured first half of data
                rs_n = (hcnt_c < (`hwidth-pad-1)) ? READ : HPAD;
            end
        endcase
    end
                
    pulse_gen pg0( // generates 1 clock pulse to prevent multi write/pop
        .clk(sys_clk),
        .rst(rst),
        .flag(pop_pbuff),
        .pulse(pop_pbuff_p)
    );
    
    pulse_gen pg1(
        .clk(sys_clk),
        .rst(rst),
        .flag(wen_cam),
        .pulse(wen_cam_p)
    );    
    
endmodule
