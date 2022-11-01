// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
// Date        : Tue Nov  1 01:28:58 2022
// Host        : eng-grid2 running 64-bit CentOS Linux release 7.9.2009 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /ad/eng/users/w/k/wkrska/Documents/EC551/EC551_Project/frame_buffer/frame_buffer.srcs/sources_1/ip/partial_buffer_1/partial_buffer_stub.v
// Design      : partial_buffer
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_3,Vivado 2019.1" *)
module partial_buffer(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[12:0],dina[11:0],clkb,addrb[12:0],doutb[11:0]" */;
  input clka;
  input [0:0]wea;
  input [12:0]addra;
  input [11:0]dina;
  input clkb;
  input [12:0]addrb;
  output [11:0]doutb;
endmodule
