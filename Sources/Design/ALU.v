`timescale 1ns / 1ps

`include "my_header.vh"

module ALU(
    input wire clk,
    input wire [(`dwss*`dwidth_dat)-1:0] din,
    input wire [(`dwss*`dwidth_kernel)-1:0] kernel, // `dwidth_kernel bit signed value
    input wire [`dwidth_div-1:0] div,
    input wire [`awidth_fbuff-1:0] raddr_alu,
    input wire ren_alu,
    output reg [`dwidth_dat-1:0] dout,
    output reg [`awidth_fbuff-1:0] waddr_alu,
    output wire wen_alu
    );

    localparam prod_bw = `dwidth_dat/3 + `dwidth_kernel; // width of a single value and the kernel value
    localparam bw_ext = $clog2(`dwss); // log2 of dwss, since entire kernel is summed

    wire [prod_bw-1:0] product [`dwss-1:0][2:0]; // 9bit product for all N**2 elements in R,G,B
    wire [prod_bw+bw_ext-1:0] sums [`dwss-2:0][2:0];

    genvar i,j;
    generate
        for (i=0; i<`dwss; i=i+1) begin
            // mult each RGB Component with sign-extended slice
            // NOTE: for signed multiplication, multiplicands must be bit-extended to length of each added (4+`dwidth_kernel in this case)
            //                din: 4bit, guarenteed to be positive, ext w/ 0's        kernel: signed `dwidth_kernel-bit, bit extend with k[4]
            // assign product[i][2] = {`dwidth_kernel'b0,din[`dwidth_dat*(i+1)-1:`dwidth_dat*i+4*2]} * {{4{kernel[`dwidth_kernel*(i+1)-1]}},kernel[`dwidth_kernel*(i+1)-1:`dwidth_kernel*i]};  // R
            // assign product[i][1] = {`dwidth_kernel'b0,din[`dwidth_dat*(i+1)-1-4:`dwidth_dat*i+4]} * {{4{kernel[`dwidth_kernel*(i+1)-1]}},kernel[`dwidth_kernel*(i+1)-1:`dwidth_kernel*i]};  // G
            // assign product[i][0] = {`dwidth_kernel'b0,din[`dwidth_dat*(i+1)-1-4*2:`dwidth_dat*i]} * {{4{kernel[`dwidth_kernel*(i+1)-1]}},kernel[`dwidth_kernel*(i+1)-1:`dwidth_kernel*i]};  // B
            assign product[i][2] = {{(prod_bw-4){1'b0}},din[`dwidth_dat*(i+1)-1:`dwidth_dat*i+4*2]} * {{(prod_bw-`dwidth_kernel){kernel[`dwidth_kernel*(i+1)-1]}},kernel[`dwidth_kernel*(i+1)-1:`dwidth_kernel*i]};  // R
            assign product[i][1] = {{(prod_bw-4){1'b0}},din[`dwidth_dat*(i+1)-1-4:`dwidth_dat*i+4]} * {{(prod_bw-`dwidth_kernel){kernel[`dwidth_kernel*(i+1)-1]}},kernel[`dwidth_kernel*(i+1)-1:`dwidth_kernel*i]};  // G
            assign product[i][0] = {{(prod_bw-4){1'b0}},din[`dwidth_dat*(i+1)-1-4*2:`dwidth_dat*i]} * {{(prod_bw-`dwidth_kernel){kernel[`dwidth_kernel*(i+1)-1]}},kernel[`dwidth_kernel*(i+1)-1:`dwidth_kernel*i]};  // B
        end
    endgenerate

    generate
        for (j=0; j<`dwss-1; j=j+1) begin
            if (j==0) begin
                // first sum is of prod 0 and 1
                assign sums[j][2] = {{bw_ext{product[j][2][prod_bw-1]}}, product[j][2]} + {{bw_ext{product[j+1][2][prod_bw-1]}}, product[j+1][2]};
                assign sums[j][1] = {{bw_ext{product[j][1][prod_bw-1]}}, product[j][1]} + {{bw_ext{product[j+1][1][prod_bw-1]}}, product[j+1][1]};
                assign sums[j][0] = {{bw_ext{product[j][0][prod_bw-1]}}, product[j][0]} + {{bw_ext{product[j+1][0][prod_bw-1]}}, product[j+1][0]};
            end else begin
                // rest of sums are sum(n-1)+prod(n)
                assign sums[j][2] = sums[j-1][2] + {{bw_ext{product[j+1][2][prod_bw-1]}}, product[j+1][2]};
                assign sums[j][1] = sums[j-1][1] + {{bw_ext{product[j+1][1][prod_bw-1]}}, product[j+1][1]};
                assign sums[j][0] = sums[j-1][0] + {{bw_ext{product[j+1][0][prod_bw-1]}}, product[j+1][0]};
            end 
        end
    endgenerate


    wire [prod_bw+bw_ext:0] sum_abs [2:0];
    //                      if MSB is 1, invert and add1, else passthrough
    assign sum_abs[0] = (sums[`dwss-2][0][prod_bw+bw_ext-1]) ? (~sums[`dwss-2][0]+'b1) : sums[`dwss-2][0];
    assign sum_abs[1] = (sums[`dwss-2][1][prod_bw+bw_ext-1]) ? (~sums[`dwss-2][1]+'b1) : sums[`dwss-2][1];
    assign sum_abs[2] = (sums[`dwss-2][2][prod_bw+bw_ext-1]) ? (~sums[`dwss-2][2]+'b1) : sums[`dwss-2][2];

    wire [`dwidth_dat-1:0] dout_t;

    //   if bits between MSB and just above the valid range are 1's, then there was overflow and we ceil at 0Xf
    
    reg check_sign [2:0];
    always @(*) begin   
        case(div)
            'd0 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+0];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+0];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+0]; end
            'd1 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+1];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+1];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+1]; end
            'd2 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+2];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+2];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+2]; end
            'd3 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+3];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+3];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+3]; end
            'd4 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+4];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+4];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+4]; end
            'd5 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+5];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+5];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+5]; end
            'd6 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+6];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+6];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+6]; end
            'd7 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+7];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+7];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+7]; end
            'd8 : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+8];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+8];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+8]; end
            default : begin check_sign[0] = |sum_abs[0][prod_bw+bw_ext-2:4+0];  check_sign[1] = |sum_abs[1][prod_bw+bw_ext-2:4+0];  check_sign[2] = |sum_abs[2][prod_bw+bw_ext-2:4+0]; end
        endcase
    end

//    wire [3:0] temp0,temp1,temp2;
//    assign temp2 = sum_abs[2][3+div -: 4] ;
//    assign temp1 = sum_abs[1][3+div -: 4] ;
//    assign temp0 = sum_abs[0][3+div -: 4] ;

    assign dout_t = {
        (check_sign[2]) ? 4'hf : sum_abs[2][3+div -: 4],
        (check_sign[1]) ? 4'hf : sum_abs[1][3+div -: 4],
        (check_sign[0]) ? 4'hf : sum_abs[0][3+div -: 4]
    };

    reg [`awidth_fbuff-1:0] waddr_d, waddr_dd;
    assign wen_alu = ((waddr_dd == waddr_alu) && (waddr_dd == raddr_alu) && ren_alu) ? 1'b1 : 1'b0 ;
    always @(posedge clk) begin
        dout <= dout_t;
        waddr_alu <= raddr_alu;
        waddr_d <= waddr_alu;
        waddr_dd <= waddr_d;
    end
endmodule
