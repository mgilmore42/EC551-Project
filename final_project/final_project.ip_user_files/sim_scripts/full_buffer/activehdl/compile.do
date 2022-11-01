vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/blk_mem_gen_v8_4_3

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap blk_mem_gen_v8_4_3 activehdl/blk_mem_gen_v8_4_3

vlog -work xil_defaultlib  -sv2k12 \
"/ad/eng/opt/xilinx/Vivado/2019.1/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/mnt/support/software/linux/opt/Xilinx/Vivado/2019.1/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_3  -v2k5 \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../../Sources/IP/full_buffer/sim/full_buffer.v" \


vlog -work xil_defaultlib \
"glbl.v"

