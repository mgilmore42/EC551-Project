onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib partial_buffer_opt

do {wave.do}

view wave
view structure
view signals

do {partial_buffer.udo}

run -all

quit -force
