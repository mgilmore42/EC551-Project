`timescale 1ns / 1ps

`include "my_header.vh"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2022 03:43:07 PM
// Design Name: 
// Module Name: partial_buffer
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


module partial_buffer(
    input wire clk,
    input wire rst,
    input wire wea, // wen for incoming values, staged for output
    input wire pop, // commit input values to output value
    input wire [`awidth_pbuff-1:0] waddr, // column address (0-639)
    input wire [`dwidth_dat-1:0] din, // RGB444 in
    input wire [`awidth_pbuff-1:0] raddr, // column address (0-639)
    output wire [(`dwidth_dat*`dwidth_slice)-1:0] col_out // containts the entire col as {RGB_N, RGB_N-1, ... RGB_1}
    );
    
    wire [(`dwidth_dat*`dwidth_slice)-1:0] dout [`hwidth-1:0]; // very large mux
    assign col_out = dout[raddr];
    
    genvar i;
    generate
        for (i=0; i<`hwidth; i=i+1) begin
            buffer_slice bf(
                .clk(clk),
                .rst(rst),
                .wea((wea && (waddr==i))),
                .pop(pop),
                .din(din),
                .dout(dout[i])
            );
        end
    endgenerate
endmodule
