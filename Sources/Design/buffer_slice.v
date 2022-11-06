`timescale 1ns / 1ps

`include "my_header.vh"

module buffer_slice(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   wen, // allows writing to the first element
    input  wire                   pop, // pushes everything down one element (synchronous updates)
    input  wire [`dwidth_dat-1:0] din,
    output wire [(`dwidth_dat*`dwidth_slice)-1:0] dout
    );
    
    reg [(`dwidth_dat*(`dwidth_slice+1))-1:0] dat = 'b0;
    assign dout = dat[(`dwidth_dat*(`dwidth_slice+1))-1:`dwidth_dat];
    
    genvar i;
    generate
        for (i=0; i<(`dwidth_slice+1);i=i+1) begin
            if (i==0) begin
                always @(posedge clk) begin
                    if (wen)
                        dat[`dwidth_dat-1:0] <= (rst) ? 'b0 : din;
                end 
            end else begin
                always @(posedge clk) begin
                    if (pop)
                        dat[(`dwidth_dat*(i+1))-1:`dwidth_dat*i] <= (rst) ? 'b0 : dat[(`dwidth_dat*i)-1:`dwidth_dat*(i-1)];
                end
            end
        end
    endgenerate
endmodule
