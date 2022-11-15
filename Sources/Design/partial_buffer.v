`timescale 1ns / 1ps

`include "my_header.vh"

module partial_buffer(
    input wire clk,
    input wire rst,
    input wire wen, // wen for incoming values, staged for output
    input wire pop, // commit input values to output value
    input wire [`awidth_pbuff-1:0] waddr, // column address (0-639)
    input wire [`dwidth_dat-1:0] wdata, // RGB444 in
    input wire [`awidth_pbuff-1:0] raddr, // column address (0-639)
    output wire [(`dwidth_dat*`dwidth_slice)-1:0] rdata // containts the entire col as {RGB_N, RGB_N-1, ... RGB_1}
    );
    
    wire [(`dwidth_dat*`dwidth_slice)-1:0] dout [`hwidth-1:0]; // very large mux
    assign rdata = dout[raddr];
    
    genvar i;
    generate
        for (i=0; i<`hwidth; i=i+1) begin
            buffer_slice bf(
                .clk(clk),
                .rst(rst),
                .wen((wen && (waddr==i))),
                .pop(pop),
                .wdata(wdata),
                .rdata(dout[i])
            );
        end
    endgenerate
endmodule
