## FPGA4student.com: Interfacing Basys 3 FPGA with OV7670 Camera
## Pin assignment

## Clock signal
#set_property PACKAGE_PIN W5 [get_ports clk100]							
	#set_property IOSTANDARD LVCMOS33 [get_ports clk100]
	#create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk100]


## Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk100 }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk100}];

    ##VGA Connector
    #set_property PACKAGE_PIN G19 [get_ports {vga_r[0]}]                
     #   set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[0]}]
    #set_property PACKAGE_PIN H19 [get_ports {vga_r[1]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[1]}]
 #   set_property PACKAGE_PIN J19 [get_ports {vga_r[2]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[2]}]
#    set_property PACKAGE_PIN N19 [get_ports {vga_r[3]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[3]}]
#    set_property PACKAGE_PIN N18 [get_ports {vga_b[0]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[0]}]
#    set_property PACKAGE_PIN L18 [get_ports {vga_b[1]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[1]}]
#    set_property PACKAGE_PIN K18 [get_ports {vga_b[2]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[2]}]
#   set_property PACKAGE_PIN J18 [get_ports {vga_b[3]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[3]}]
#    set_property PACKAGE_PIN J17 [get_ports {vga_g[0]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[0]}]
#    set_property PACKAGE_PIN H17 [get_ports {vga_g[1]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[1]}]
#    set_property PACKAGE_PIN G17 [get_ports {vga_g[2]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[2]}]
#    set_property PACKAGE_PIN D17 [get_ports {vga_g[3]}]                
#        set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[3]}]
#    set_property PACKAGE_PIN P19 [get_ports vga_hsync]                        
#        set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]
#    set_property PACKAGE_PIN R19 [get_ports vga_vsync]                        
#        set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]


##VGA Connector
set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { vga_red[0] }]; #IO_L8N_T1_AD14N_35 Sch=vga_red[0]
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { vga_red[1] }]; #IO_L7N_T1_AD6N_35 Sch=vga_red[1]
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { vga_red[2] }]; #IO_L1N_T0_AD4N_35 Sch=vga_red[2]
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { vga_red[3] }]; #IO_L8P_T1_AD14P_35 Sch=vga_red[3]
set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[0] }]; #IO_L1P_T0_AD4P_35 Sch=vga_green[0]
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { vga_green[1] }]; #IO_L3N_T0_DQS_AD5N_35 Sch=vga_green[1]
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[2] }]; #IO_L2N_T0_AD12N_35 Sch=vga_green[2]
set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[3] }]; #IO_L3P_T0_DQS_AD5P_35 Sch=vga_green[3]
set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[0] }]; #IO_L2P_T0_AD12P_35 Sch=vga_blue[0]
set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[1] }]; #IO_L4N_T0_35 Sch=vga_blue[1]
set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[2] }]; #IO_L6N_T0_VREF_35 Sch=vga_blue[2]
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[3] }]; #IO_L4P_T0_35 Sch=vga_blue[3]
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { vga_hsync }]; #IO_L4P_T0_15 Sch=vga_hs
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { vga_vsync }]; #IO_L3N_T0_DQS_AD1N_15 Sch=vga_vs



## LEDs
#set_property PACKAGE_PIN U16 [get_ports {config_finished}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {config_finished}]

## LEDs
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; #IO_L18P_T2_A24_15 Sch=led[0]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; #IO_L24P_T3_RS1_15 Sch=led[1]
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; #IO_L17N_T2_A25_15 Sch=led[2]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]; #IO_L8P_T1_D11_14 Sch=led[3]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { LED[4] }]; #IO_L7P_T1_D09_14 Sch=led[4]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { LED[5] }]; #IO_L18N_T2_A11_D27_14 Sch=led[5]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { LED[6] }]; #IO_L17P_T2_A14_D30_14 Sch=led[6]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { LED[7] }]; #IO_L18P_T2_A12_D28_14 Sch=led[7]
					
##Buttons
#set_property PACKAGE_PIN U18 [get_ports btnc]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnc]
#set_property PACKAGE_PIN W19 [get_ports btnl]                        
 #    set_property IOSTANDARD LVCMOS33 [get_ports btnl]
#set_property PACKAGE_PIN T17 [get_ports btnr]						
         #set_property IOSTANDARD LVCMOS33 [get_ports btnr]
         
##Buttons
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { btnc }]; #IO_L9P_T1_DQS_14 Sch=btnc
#set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { btnl }]; #IO_L12P_T1_MRCC_14 Sch=btnl
#set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { btnr }]; #IO_L10N_T1_D15_14 Sch=btnr

## OV7670 Camera header pins

##Pmod Header JB
##Sch name = JB1
#set_property PACKAGE_PIN A14 [get_ports {ov7670_pwdn}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_pwdn}]
##Sch name = JB2
#set_property PACKAGE_PIN A16 [get_ports {ov7670_data[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data[0]}]
##Sch name = JB3
#set_property PACKAGE_PIN B15 [get_ports {ov7670_data[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data[2]}]
##Sch name = JB4
#set_property PACKAGE_PIN B16 [get_ports {ov7670_data[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data[4]}]
##Sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports {ov7670_reset}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_reset}]
##Sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports {ov7670_data[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data[1]}]
##Sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports {ov7670_data[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data[3]}]
##Sch name = JB10 
#set_property PACKAGE_PIN C16 [get_ports {ov7670_data[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data[5]}]
 
 
 ##Pmod Headers
##Pmod Header JA
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { OV7670_PWDN }]; #IO_L20N_T3_A19_15 Sch=ja[1]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { OV7670_D[0] }]; #IO_L21N_T3_DQS_A18_15 Sch=ja[2]
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { OV7670_D[2] }]; #IO_L21P_T3_DQS_15 Sch=ja[3]
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { OV7670_D[4] }]; #IO_L18N_T2_A23_15 Sch=ja[4]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { OV7670_RESET }]; #IO_L16N_T2_A27_15 Sch=ja[7]
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { OV7670_D[1] }]; #IO_L16P_T2_A28_15 Sch=ja[8]
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { OV7670_D[3] }]; #IO_L22N_T3_A16_15 Sch=ja[9]
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { OV7670_D[5] }]; #IO_L22P_T3_A17_15 Sch=ja[10]



##Pmod Header JC
##Sch name = JC1
#set_property PACKAGE_PIN K17 [get_ports {ov7670_data[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data[6]}]
##Sch name = JC2
#set_property PACKAGE_PIN M18 [get_ports ov7670_xclk]					
#	set_property IOSTANDARD LVCMOS33 [get_ports ov7670_xclk]
##Sch name = JC3
#set_property PACKAGE_PIN N17 [get_ports ov7670_href]					
#	set_property IOSTANDARD LVCMOS33 [get_ports ov7670_href]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports ov7670_siod]					
#	set_property IOSTANDARD LVCMOS33 [get_ports ov7670_siod]
#	set_property PULLUP TRUE [get_ports ov7670_siod]
##Sch name = JC7
#set_property PACKAGE_PIN L17 [get_ports {ov7670_data[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data[7]}]
##Sch name = JC8
#set_property PACKAGE_PIN M19 [get_ports ov7670_pclk]					
#	set_property IOSTANDARD LVCMOS33 [get_ports ov7670_pclk]
#    set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {ov7670_pclk_IBUF}]
##Sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports ov7670_vsync]					
#	set_property IOSTANDARD LVCMOS33 [get_ports ov7670_vsync]
##Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports ov7670_sioc]					
#	set_property IOSTANDARD LVCMOS33 [get_ports ov7670_sioc]


##Pmod Header JB
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { OV7670_D[6] }]; #IO_L1P_T0_AD0P_15 Sch=jb[1]
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { OV7670_XCLK }]; #IO_L14N_T2_SRCC_15 Sch=jb[2]
set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { OV7670_HREF }]; #IO_L13N_T2_MRCC_15 Sch=jb[3]
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { OV7670_SIOD }]; #IO_L15P_T2_DQS_15 Sch=jb[4]
set_property PULLUP TRUE [get_ports OV7670_SIOD]
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { OV7670_D[7] }]; #IO_L11N_T1_SRCC_15 Sch=jb[7]
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { OV7670_PCLK }]; #IO_L5P_T0_AD9P_15 Sch=jb[8]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {OV7670_PCLK_IBUF}]
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { OV7670_VSYNC }]; #IO_0_15 Sch=jb[9]
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { OV7670_SIOC }]; #IO_L13P_T2_MRCC_15 Sch=jb[10]
set_property PULLUP TRUE [get_ports OV7670_SIOC]
