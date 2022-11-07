`timescale 1ns / 1ps

`include "my_header.vh"

module ALU(
    input wire [(`dwidth_slice*`dwidth_slice*`dwidth_dat)-1:0] din,
    input wire [(`dwidth_slice*`dwidth_slice*4)-1:0] kernel,
    output wire [`dwidth_dat-1:0]
    );

    reg [(`dwidth_dat*2)-1:0] product [(`dwidth_slice*`dwidth_slice)-1:0];

    genvar i;
    generate
        for (i=0; i<(`dwidth_slice*`dwidth_slice); i=i+1) begin
            product[i] = din
        end
    endgenerate
endmodule
