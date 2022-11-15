`timescale 1ns / 1ps

`include "my_header.vh"

localparam dwss = `dwidth_slice*`dwidth_slice;


module kernel_ROM(
    input wire [1:0] kernel_select,
    output reg [(dwss*`dwidth_kernel)-1:0] kernel,
    output reg [`dwidth_div-1:0] div
    );

    // Must be hard_coded at this point
    always @(kernel_select) begin
        case(kernel_select)
            2'b00: begin // Sobel filter (combined)
                kernel <= {
                    `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, 
                    `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h2, `dwidth_kernel'h2, `dwidth_kernel'h0, 
                    `dwidth_kernel'h0, `dwidth_kernel'hE, `dwidth_kernel'h0, `dwidth_kernel'h2, `dwidth_kernel'h0, 
                    `dwidth_kernel'h0, `dwidth_kernel'hE, `dwidth_kernel'hE, `dwidth_kernel'h0, `dwidth_kernel'h0, 
                    `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0 
                };
                div <= `dwidth_div'd0;
            end
            2'b01: begin // blur filter
                kernel <= {
                    `dwidth_kernel'h0, `dwidth_kernel'h1, `dwidth_kernel'h1, `dwidth_kernel'h1, `dwidth_kernel'h0, 
                    `dwidth_kernel'h1, `dwidth_kernel'h2, `dwidth_kernel'h2, `dwidth_kernel'h2, `dwidth_kernel'h1, 
                    `dwidth_kernel'h1, `dwidth_kernel'h2, `dwidth_kernel'h4, `dwidth_kernel'h2, `dwidth_kernel'h1, 
                    `dwidth_kernel'h1, `dwidth_kernel'h2, `dwidth_kernel'h2, `dwidth_kernel'h2, `dwidth_kernel'h1, 
                    `dwidth_kernel'h0, `dwidth_kernel'h1, `dwidth_kernel'h1, `dwidth_kernel'h1, `dwidth_kernel'h0 
                };
                div <= `dwidth_div'd5;
            end
            default: begin // untouched
                kernel <= {
                    `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, 
                    `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, 
                    `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h1, `dwidth_kernel'h0, `dwidth_kernel'h0, 
                    `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, 
                    `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0, `dwidth_kernel'h0 
                };
                div <= `dwidth_div'd0;
            end
        endcase
    end

endmodule
