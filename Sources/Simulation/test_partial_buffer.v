`timescale 1ns / 1ps

module test_partial_buffer(

    );
    
    // NOT CORRECT, change later
    
    reg clk;
    reg rst;
    reg wen;
    reg pop;
    reg [11:0] din;
    wire [(9*12)-1:0] dout;
    
    buffer_slice bf(
        .clk(clk),
        .rst(rst),
        .wen(wen),
        .pop(pop),
        .din(din),
        .dout(dout)
    );
    
    always
        #1 clk = ~clk;
    
    initial begin
        clk <= 0;
        wen <= 0;
        pop <= 0;
        rst <= 1;
        din <= 0;
        
        #10;
        
        rst <= 0;
        wen <= 1;
        din <= 12'd1; #2;
        pop <= 1;
        din <= 12'd2; #2;
        din <= 12'd3; #2;
        din <= 12'd4; #2;
        din <= 12'd5; #2;
        din <= 12'd6; #2;
        din <= 12'd7; #2;
        din <= 12'd8; #2;
        din <= 12'd9; #2;
        din <= 12'd10; #2;
        din <= 12'd11; #2;
        wen <= 0;
        din <= 12'd12; #2;
        din <= 12'd13; #2;
        din <= 12'd14; #2;
        
        $finish;
    end
endmodule
