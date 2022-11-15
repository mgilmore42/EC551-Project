`timescale 1ns / 1ps

`include "my_header.vh"

module conv_buffer(
    input wire clk,
    input wire rst,
    input wire wen, // wen for incoming values, staged for output
    input wire pop, // commit input values to output value
    input wire [(`dwidth_dat*`dwidth_slice)-1:0] wdata, // full_slice in
    output wire [(`dwss*`dwidth_dat)-1:0] rdata // entire data
    );
    
    genvar i;
    generate
        for (i=0; i<`dwidth_slice; i=i+1) begin
            buffer_slice bf(
                .clk(clk),
                .rst(rst),
                .wen(wen),
                .pop(pop),
                .wdata(wdata[`dwidth_dat*(i+1)-1:`dwidth_dat*i]),
                .rdata(rdata[`dwidth_dat*`dwidth_slice*(i+1)-1:`dwidth_dat*`dwidth_slice*i])
            );
        end
    endgenerate
endmodule
