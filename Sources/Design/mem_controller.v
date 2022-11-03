`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2022 09:15:55 PM
// Design Name: 
// Module Name: mem_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_controller(
    // General signal
    input wire          sys_clk,
    input wire          rst,
    
    // Camera Data
    input wire          pclk,
    input wire          vsync_cam,
    input wire          href_cam,
    input wire [7:0]    wdata_cam,
    
    // VGA Memory access
    input wire [18:0]   raddr_vga,
    output wire [11:0]  rdata_vga,
    
    // Processing access
    input wire [12:0]   raddr_alu,
    input wire [18:0]   waddr_alu,
    input wire [11:0]   wdata_alu,
    input wire          wen_alu,
    output wire [11:0]  rdata_alu
    
    );
    
    // mux between passthrough mode and process mode
    reg passthrough_mode = 1;
    
    wire [18:0] waddr_cam;
    reg [11:0] wdata_cam_full;
    reg         wen_cam;
    reg  [9:0]  ccnt_c, ccnt_n; // pix in row
    reg  [8:0]  rcnt_c, rcnt_n; // row of pix
    reg  [1:0]  st_c,   st_n; // FSM state
    reg         wen_n; // assemble both bytes
    reg  [3:0]  dlast; // previous data
    
    // Will remain dormant for now
    partial_buffer pbuff (
        .clka(sys_clk),    // input wire clka
        .wea(wen_cam),      // input wire [0 : 0] wea
        .addra(waddr_cam),  // input wire [12 : 0] addra
        .dina(wdata_cam_full),    // input wire [11 : 0] dina
        .clkb(sys_clk),    // input wire clkb
        .addrb(raddr_alu),  // input wire [12 : 0] addrb
        .doutb(rdata_alu)  // output wire [11 : 0] doutb
    );

    wire [11:0] douta;

    full_buffer fbuff (
        .clka(sys_clk),    // input wire clka
        .wea((passthrough_mode) ? wen_cam : wen_alu),      // input wire [0 : 0] wea
        .addra((passthrough_mode) ? waddr_cam : waddr_alu),  // input wire [18 : 0] addra
        .dina((passthrough_mode) ? wdata_cam_full : wdata_alu),    // input wire [11 : 0] dina
        .douta(douta),  // output wire [11 : 0] douta
        .clkb(sys_clk),    // input wire clkb
        .web('b0),      // input wire [0 : 0] web
        .addrb(raddr_vga),  // input wire [18 : 0] addrb
        .dinb('b0),    // input wire [11 : 0] dinb
        .doutb(rdata_vga)   // output wire [11 : 0] doutb
    );
    
    // data writing FSM
    assign waddr_cam = {2'b0,rcnt_c,8'b0} + {4'b0,rcnt_c,6'b0} + {10'b0,ccnt_c}; // 640(1010000000) * row_cnt + col_cnt = (2^9+2^7) * row_cnt + col_cnt, avoids 18 bit multiplication
    always @(posedge pclk) begin
        if (rst) begin
            st_c <= 'b0;
            ccnt_c <= 'b0;
            rcnt_c <= 'b0;
            wen_cam <= 'b0;
            dlast <= 'b0;
        end else begin
            st_c <= st_n;
            ccnt_c <= ccnt_n;
            rcnt_c <= rcnt_n;
            wen_cam <= wen_n;
            dlast <= wdata_cam[3:0];
            wdata_cam_full <= {dlast,wdata_cam};
        end        
    end
    
    always @(*) begin
        case(st_c)
            2'b00 : begin // idle, waiting for vsync
                st_n = (vsync_cam) ? 2'b01 : 2'b00;
                ccnt_n = 'b0;
                rcnt_n = 'b0;
                wen_n = 'b0;
            end
            2'b01 : begin // active, waiting for href
                st_n = (rcnt_c==9'd480) ? 2'b00 : ((href_cam) ? 2'b10 : 2'b01); // reset if count=480, progress if href, wait otherwise
                ccnt_n = 'b0;
                rcnt_n = rcnt_c;
                wen_n = 'b0;
            end
            2'b10 : begin // active, captured first half of data
                st_n = (href_cam) ? 2'b11 : 2'b01;
                ccnt_n = ccnt_c;
                rcnt_n = rcnt_c;
                wen_n = 'b1;
            end
            2'b11 : begin // active, captured second half of data and write
                st_n = ((ccnt_c<(10'd640-1)) && href_cam) ? 2'b10 : 2'b01;
                ccnt_n = ccnt_c + 1;
                rcnt_n = (ccnt_c<(10'd640-1)) ? rcnt_c : rcnt_c+1;
                wen_n = 1'b0;
            end
        endcase
    end
                
                
    
endmodule
