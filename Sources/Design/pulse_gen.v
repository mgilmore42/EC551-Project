`timescale 1ns / 1ps

module pulse_gen(
    input wire clk,
    input wire rst,
    input wire flag,
    output wire pulse
);
    reg [1:0] cs=0;
    reg [1:0] ns=0;

    always @(posedge clk)
        cs <= (rst) ? 0 : ns;

    assign pulse = cs[0];

    always @(*) begin  
        case(cs)
            2'b00: ns = (flag) ? 2'b01 : 2'b00;
            2'b01: ns = 2'b10;
            2'b10: ns = (flag) ? 2'b10 : 2'b00;
        endcase
    end
endmodule