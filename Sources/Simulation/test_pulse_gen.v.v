`timescale 1ns / 1ps
`include "my_header.vh"

module test_pulse_gen();
    reg clk,flag;
    wire pulse;

    pulse_gen pg(
        .clk(clk),
        .flag(flag),
        .pulse(pulse)
    );

    always 
        #1 clk<=~clk;

    initial begin
        clk<=0;
        flag<=0;
        #10; flag<=1;
        #10; flag<=0;
        #10; flag<=1;
        #10; 
    end
endmodule