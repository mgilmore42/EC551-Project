`timescale 1ns / 1ps

`include "my_header.vh"

module test_kernel_ROM(

    );
    reg [1:0] kernel_select;
    wire [(`dwss*`dwidth_kernel)-1:0] kernel;
    wire [`dwidth_div-1:0]              div;

    kernel_ROM kr(
        .kernel_select(kernel),
        .kernel(kernel),
        .div(div)
    );

    initial begin
        kernel_select = 0;
        #10;
        kernel_select = 1;
        #10;
        kernel_select = 2;
        #10;
        $finish;
    end
        

endmodule
