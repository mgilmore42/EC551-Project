`timescale 1ns / 1ps

`include "my_header.vh"

module kernel_ROM(
    input wire [1:0] kernel_select,
    output reg [(`dwss*`dwidth_kernel)-1:0] kernel,
    output reg [`dwidth_div-1:0] div
    );

    // Must be hard_coded at this point
    always @(kernel_select) begin
        case(kernel_select)
            2'b00: begin // passthrough
                kernel <= {
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h01, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00 
                };
                div <= `dwidth_div'd0;
            end
            2'b01: begin // Sobel filter (combined)
                kernel <= {
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h02, `dwidth_kernel'h02, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'hFE, `dwidth_kernel'h00, `dwidth_kernel'h02, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'hFE, `dwidth_kernel'hFE, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00 
                };
                div <= `dwidth_div'd2;
            end
            2'b10: begin // blur filter
                kernel <= {
                    `dwidth_kernel'h00, `dwidth_kernel'h01, `dwidth_kernel'h01, `dwidth_kernel'h01, `dwidth_kernel'h00, 
                    `dwidth_kernel'h01, `dwidth_kernel'h02, `dwidth_kernel'h02, `dwidth_kernel'h02, `dwidth_kernel'h01, 
                    `dwidth_kernel'h01, `dwidth_kernel'h02, `dwidth_kernel'h04, `dwidth_kernel'h02, `dwidth_kernel'h01, 
                    `dwidth_kernel'h01, `dwidth_kernel'h02, `dwidth_kernel'h02, `dwidth_kernel'h02, `dwidth_kernel'h01, 
                    `dwidth_kernel'h00, `dwidth_kernel'h01, `dwidth_kernel'h01, `dwidth_kernel'h01, `dwidth_kernel'h00 
                };
                div <= `dwidth_div'd5;
            end
            2'b11: begin // Sharpening filter
                kernel <= {
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'hFF, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'hFF, `dwidth_kernel'hFE, `dwidth_kernel'hFF, `dwidth_kernel'h00, 
                    `dwidth_kernel'hFF, `dwidth_kernel'hFE, `dwidth_kernel'h1F, `dwidth_kernel'hFE, `dwidth_kernel'hFF, 
                    `dwidth_kernel'h00, `dwidth_kernel'hFF, `dwidth_kernel'hFE, `dwidth_kernel'hFF, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'hFF, `dwidth_kernel'h00, `dwidth_kernel'h00
                };
                div <= `dwidth_div'd4;
            end
            default: begin // untouched
                kernel <= {
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h01, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, 
                    `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00, `dwidth_kernel'h00 
                };
                div <= `dwidth_div'd0;
            end
        endcase
    end

endmodule
