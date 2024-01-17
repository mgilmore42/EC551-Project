# EC551 Project
This project is an implementation of a realtime image processor using an FPGA. The system described in Verilog is able to capture the video feed from a OV7670, applying kernel based filter to the image and then displaying it.

## Materals
- Nexys A7 FPGA
- OV7670 Camera Module
- Jumper wires

## How to Use
This project has everything needed to upload the implemented design directly to a Nexys A7 FPGA development board. First, wire the camera to the board using the following pmod connection table.

| Camera Pin | FPGA Pin |
|------------|----------|
| 3.3 V      | JB[6]    |
| SCL        | JB[1]    |
| VS         | JB[2]    |
| PCLK       | JB[10]   |
| D7         | JA[1]    |
| D5         | JA[2]    |
| D3         | JA[3]    |
| D1         | JA[4]    |
| GND        | JB[5]    |
| SDA        | JB[7]    |
| HD         | JB[8]    |
| MCLK       | JB[3]    |
| D6         | JA[7]    |
| D4         | JA[8]    |
| D2         | JA[9]    |
| D0         | JA[10]   |

After wiring the camera, you can simply power on the board. Then open the [final_project.xpr](final_project/final_project.xpr) file located in the the final_project directory. After opening the file you just need to upload the bitstream to the FPGA.

## Video

[![Video Link](https://img.youtube.com/vi/g5GMFYvGNuQ/0.jpg)](https://youtu.be/g5GMFYvGNuQ)

## Systems Parameters

For those ambitious and wanting to continue the work done in this project, here are some useful parameters to modify the system. They can be modified in the [my_header.vh](Sources/Design/my_header.vh) found in the Sources/Design.

| Parameter     | Default | Meaning                           |
|---------------|---------|-----------------------------------|
| dwidth_dat    |      12 | 3 times the color depth           |
| dwidth_slice  |       5 | Size of square kernel             |
| dwidth_kernel |       8 | Datawidth for kernel coefficients |
| dwidth_div    |       4 | Datawidth for kernel divisor      |
| awidth_pbuff  |      10 | Address width of partial buffer   |
| awidth_fbuff  |      19 | Address width of full buffer      |
| hwidth        |     640 | Height of image                   |
| vwidth        |     480 | Width of image                    |
