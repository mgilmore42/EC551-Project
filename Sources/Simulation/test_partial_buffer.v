`timescale 1ns / 1ps
`include "my_header.vh"
module test_partial_buffer(

    );
    
    // NOT CORRECT, change later
    
    reg                                     clk  ;
    reg                                     rst  ;
    reg                                     wen  ; // wen for incoming values, staged for output
    reg                                     pop  ; // commit input values to output value
    reg [`awidth_pbuff-1:0]                 waddr; // column address (0-639)
    reg [`dwidth_dat-1:0]                   wdata; // RGB444 in
    reg [`awidth_pbuff-1:0]                 raddr; // column address (0-639)
    wire [(`dwidth_dat*`dwidth_slice)-1:0]  rdata; // containts the entire col as {RGB_N, RGB_N-1, ... RGB_1}
    
    partial_buffer pb(
        .clk  (clk  ),
        .rst  (rst  ),
        .wen  (wen  ),
        .pop  (pop  ),
        .waddr(waddr),
        .wdata(wdata),
        .raddr(raddr),
        .rdata(rdata)
    );
    
    always
        #1 clk <= ~clk;
    integer i;
    initial begin
        clk  <='b0;
        rst  <='b1;
        wen  <='b0;
        pop  <='b0;
        waddr<='b0;
        wdata<='b0;
        raddr<='b0;

        #10; rst<='b0;
        
        #10;
        for(i=0;i<`hwidth*6;i=i+1)begin
            wdata=i[11:0];
            waddr=(i%`hwidth);
            raddr=(i%`hwidth);
            wen=1;
            pop=((i%`hwidth)==(`hwidth-1))?1:0;
            #2;
        end
        $finish;
    end
endmodule
