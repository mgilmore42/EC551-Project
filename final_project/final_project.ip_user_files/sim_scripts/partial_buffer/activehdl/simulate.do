onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+partial_buffer -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_3 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.partial_buffer xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {partial_buffer.udo}

run -all

endsim

quit -force
