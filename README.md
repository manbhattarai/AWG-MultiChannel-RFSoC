# AWG-MultiChannel-RFSoC

[![Platform](https://img.shields.io/badge/Platform-RealDigital%20RFSoC%204x2-red)]([https://redpitaya.com/](https://www.realdigital.org/hardware/rfsoc-4x2))
[![FPGA](https://img.shields.io/badge/FPGA-ZYNQ%20Ultrascale+%20RFSoC%20ZU48DR-blue)]([https://www.xilinx.com/](https://www.amd.com/en/products/adaptive-socs-and-fpgas/soc/zynq-ultrascale-plus-rfsoc.html))


## Overview
High-sampling-rate, high-memory-density, multi-channel arbitrary waveform generator. Waveforms are transferred from PS to PL via AXI DMA, stored in RAM, and streamed to the on-chip DACs.

## Features

- Data sampling at 9.8304 GSps
- Two output channels: DAC A (DAC0) and DAC B (DAC2)
- Four waveforms total, each $2^{18}$ samples
  - DAC A (DAC0): waveform A or B
  - DAC B (DAC2): waveform C or D
  - Waveform selection via software (AXI GPIO) or an external signal.


## System Architecture
The implementation is summarized with the help of the following diagrams. It is separated into the waveform-write and the waveform-read blocks.

The sample comprising the waveforms A,B,C, and D are fed into the PL via an AXI-DMA as in the sequesce outlined in the diagram. The data sequence then passed through a datasorter module, which sorts and write the data onto the RAM memory block in the format depicted in the diagram. During the write process, the `write_enable` signal is held high. In case of the memory block RAM[0] and RAM[1], the first $2^{14}$ memory address contains sample points of waveform-A, and the rest $2^{14}$ address (from $2^{14}$ to $2^{15}$) contain samples from waveform-B. 

<table cellspacing="0" cellpadding="10">
  <tr>
    <th align="left">Input</th>
    <th align="left">Output</th>
  </tr>
  <tr>
    <td><img src="./assets/arb_RFSoC_input_bkg.png" width="500" alt="Input"></td>
    <td><img src="./assets/arb_RFSoC_output_bkg.png" width="500" alt="Output"></td>
  </tr>
</table>

## Input/Output 
The relevant I/O pins and ports on the board are
| Name | Pin/Port |  Type | Description |
| -------- | -------- | -------- | -------- |
| control_trigger | PMOD0_1 | Input | External waveform-select trigger. Toggles DAC A between waveform-A/waveform-B and DAC B between waveform-C/waveform-D. Effective select: (axi_control || control_trigger)|
| pmod_out| PMOD0_0  | Output | Outputs control_trigger signal sampled on a 614.4 MHz clock.  |
| DAC 0| DAC A  | Output | AWG output |
| DAC 2| DAC B  | Output | AWG output |

The design contains AXI GPIOs that can be accessed by software. A sample C code is provided.
| Name | Memory Address |  Type | Description |
| -------- | -------- | -------- | -------- |
| rst_n | 0x00_A007_0000 | Output |1 bit. Software reset. Active low signal. |
| write_enable | 0x00_A005_0000  | Output | 1 bit. Enables writing waveform to RAM bank. Set to 0 to enable output; set enable_ch0 and enambe_ch2 accordingly. |
| MAX_POINTS| 0x00_A006_0000  | Output | 32 bit. (MAX_POINTS<<4) is the maximum number of points to output. |
| enable_ch0 | 0x00_A009_0000 | Output | 1 bit. Enables output on DAC A when write_enable is low. |
| enable_ch2 | 0x00_A00A_0000 | Output | 1 bit. Enables output on DAC B when write_enable is low. |
| axi_control| 0x00_A008_0000 | Output | 1 bit. Software trigger signal.  Switches between waveform-A and waveform-B for DAC0 output and between waveform-C and waveform-D for DAC2 output. The effective select signal is (axi_control || control_trigger) |
| axi_dma_0| 0x00_A006_0000 | Input | AMD's DMA IP for direct memory access and fast transfer of data from PS to PL.|


## Usage
A sample jupyter notebook file is provided. 
1. Copy the .ipynb, the LMK and the LMX files, the .hwh file into the same folder in the device.
2. Extract the .7z file to obtain the .bit file at the same location.
3. Run the notebook from within the Linux of the FPGA.


## Modifications
The project can be built as a Vivado project using the <i>awg_multichannel_rfsoc.tcl</i> and necessary modifications can be made. 
The board file can be installed from
https://github.com/RealDigitalOrg/RFSoC4x2-BSP
