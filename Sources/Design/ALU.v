`timescale 1ns / 1ps

`include "my_header.vh"

localparam dwss = `dwidth_slice*`dwidth_slice;

module ALU(
    input wire [(dwss*`dwidth_dat)-1:0] din,
    input wire [(dwss*`dwidth_slice*5)-1:0] kernel, // 5 bit signed value
    output wire [`dwidth_dat-1:0]
    );

    reg [(`dwidth_dat*2)-1:0] product [dwss-1:0];
    wire [`dwidth_dat*2+$log2(`dwidth_slice)-1:0] sums [dwss-2:0];

    genvar i;
    generate
        for (i=0; i<dwss; i=i+1) begin
            // mult each RGB Component with sign-extended slice
            product[i][2] = {  
                {4'b0,din[`dwidth_slice*(i+1)-1:`dwidth_slice*i+4*2]]} * {{3{din[4*(i+1)-1]}},din[4*(i+1)-1:4*i]},  // R
                {4'b0,din[`dwidth_slice*(i+1)-1-4:`dwidth_slice*i+4]]} * {{3{din[4*(i+1)-1]}},din[4*(i+1)-1:4*i]},  // G
                {4'b0,din[`dwidth_slice*(i+1)-1-2*4:`dwidth_slice*i]]} * {{3{din[4*(i+1)-1]}},din[4*(i+1)-1:4*i]}   // B
            };

            // if (i==0)
            //     assign sums[i] = {
            //         {{$log2(`dwidth_slice){product[i][(`dwidth_dat*2)-1]}},product[i][].... switch to unpacked dimensions?
        end
    endgenerate


endmodule
