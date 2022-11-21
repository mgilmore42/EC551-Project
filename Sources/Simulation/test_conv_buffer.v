`timescale 1ns / 1ps
`include "my_header.vh"

module test_conv_buffer(

    );


    reg clk;
    reg rst;
    reg wen; // wen for incoming values, staged for output
    reg pop; // commit input values to output value
    reg [(`dwidth_dat*`dwidth_slice)-1:0] wdata; // full_slice in
    wire [(`dwss*`dwidth_dat)-1:0] rdata; // entire data
    
    conv_buffer cb(
        .clk(clk),
        .rst(rst),
        .wen(wen),
        .pop(pop),
        .wdata(wdata),
        .rdata(rdata)
    );

    always  
        #1 clk<=~clk;

    initial begin
        clk  <='b0;
        rst  <='b1;
        wen  <='b0;
        pop  <='b0;
        wdata<='b0;

        #10; rst<='b0;

        // write unique buffer `dwidth_slice times
        #2;wdata={12'h0,12'h1,12'h2,12'h3,12'h4};     wen=1;pop=1;
        #2;wdata={12'h10,12'h11,12'h12,12'h13,12'h14};wen=1;pop=1;
        #2;wdata={12'h20,12'h21,12'h22,12'h23,12'h24};wen=1;pop=1;
        #2;wdata={12'h30,12'h31,12'h32,12'h33,12'h34};wen=1;pop=1;
        #2;wdata={12'h40,12'h41,12'h42,12'h43,12'h44};wen=1;pop=1;
        #2;wdata={12'h50,12'h51,12'h52,12'h53,12'h54};wen=1;pop=1;
        #2;

        $finish;
    end
endmodule