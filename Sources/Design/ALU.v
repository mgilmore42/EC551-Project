`timescale 1ns / 1ps

`include "my_header.vh"

module ALU(
    input wire [(`dwss*`dwidth_dat)-1:0] din,
    input wire [(`dwss*`dwidth_kernel)-1:0] kernel, // `dwidth_kernel bit signed value
    input wire [`dwidth_div-1:0] div,
    output wire [`dwidth_dat-1:0] dout
    );

    localparam prod_bw = `dwidth_dat/3*2;
    localparam bw_ext = $clog2(`dwidth_slice);

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

    wire [prod_bw+bw_ext:0] sum_floor [2:0];
    //                      if MSB is 1, round to 0, else passthrough
    assign sum_floor[0] = (sums[`dwss-2][0][prod_bw+bw_ext-1])?'b0:sums[`dwss-2][0];
    assign sum_floor[1] = (sums[`dwss-2][1][prod_bw+bw_ext-1])?'b0:sums[`dwss-2][1];
    assign sum_floor[2] = (sums[`dwss-2][2][prod_bw+bw_ext-1])?'b0:sums[`dwss-2][2];

    reg [`dwidth_dat-1:0] dout_t;
    always @(*) begin
        case(div)
            `dwidth_div'd0: dout_t <= {sum_floor[2][3+0:0],sum_floor[1][3+0:0],sum_floor[0][3+0:0]};
            `dwidth_div'd1: dout_t <= {sum_floor[2][3+1:1],sum_floor[1][3+1:1],sum_floor[0][3+1:1]};
            `dwidth_div'd2: dout_t <= {sum_floor[2][3+2:2],sum_floor[1][3+2:2],sum_floor[0][3+2:2]};
            `dwidth_div'd3: dout_t <= {sum_floor[2][3+3:3],sum_floor[1][3+3:3],sum_floor[0][3+3:3]};
            `dwidth_div'd4: dout_t <= {sum_floor[2][3+4:4],sum_floor[1][3+4:4],sum_floor[0][3+4:4]};
            `dwidth_div'd5: dout_t <= {sum_floor[2][3+5:5],sum_floor[1][3+5:5],sum_floor[0][3+5:5]};
            `dwidth_div'd6: dout_t <= {sum_floor[2][3+6:6],sum_floor[1][3+6:6],sum_floor[0][3+6:6]};
            `dwidth_div'd7: dout_t <= {sum_floor[2][3+7:7],sum_floor[1][3+7:7],sum_floor[0][3+7:7]};
            default:        dout_t <= {sum_floor[2][3+0:0],sum_floor[1][3+0:0],sum_floor[0][3+0:0]};
        endcase
    end
    assign dout = dout_t;
endmodule
