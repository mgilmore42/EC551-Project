`timescale 1ns / 1ps

`include "my_header.vh"

module test_ALU();
    reg clk;
    reg [(`dwss*`dwidth_dat)-1:0] din;
    reg [1:0] kernel_select;
    reg [`awidth_fbuff-1:0] raddr_alu;
    wire [(`dwss*`dwidth_kernel)-1:0] kernel;
    wire [`dwidth_div-1:0] div;
    wire [`dwidth_dat-1:0] dout;
    wire [`awidth_fbuff-1:0] waddr_alu;

    ALU alu(
        .clk(clk),
        .din(din),
        .kernel(kernel),
        .raddr_alu(raddr_alu),
        .div(div),
        .dout(dout),
        .waddr_alu(waddr_alu)
    );
    kernel_ROM kr(
        .kernel_select(kernel_select),
        .kernel(kernel),
        .div(div)
    );
    
    always
        #1 clk<=~clk;
        
    initial begin
        clk = 0;
        raddr_alu = 1;
        din = {
            12'h000, 12'h101, 12'h202, 12'h303, 12'h404,
            12'h110, 12'h011, 12'h112, 12'h213, 12'h314,
            12'h220, 12'h121, 12'h022, 12'h123, 12'h224,
            12'h330, 12'h231, 12'h132, 12'h033, 12'h134,
            12'h440, 12'h341, 12'h242, 12'h143, 12'h044
        };
        kernel_select = 0;
        #10;
        raddr_alu = 2;
        kernel_select = 1;
        #10;
        raddr_alu = 3;
        kernel_select = 2;
        #10;
        raddr_alu = 4;
        kernel_select = 3;
        #10;

        $finish;        
    end

endmodule