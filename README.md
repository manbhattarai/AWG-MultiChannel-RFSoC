# AWG-MultiChannel-RFSoC

[![Platform](https://img.shields.io/badge/Platform-RealDigital%20RFSoC%204x2-red)]([https://redpitaya.com/](https://www.realdigital.org/hardware/rfsoc-4x2))
[![FPGA](https://img.shields.io/badge/FPGA-ZYNQ%20Ultrascale+%20RFSoC%20ZU48DR-blue)]([https://www.xilinx.com/](https://www.amd.com/en/products/adaptive-socs-and-fpgas/soc/zynq-ultrascale-plus-rfsoc.html))


## Overview
High-sampling-rate, high-memory-density, multi-channel arbitrary waveform generator. Waveforms are transferred from PS to PL via AXI DMA, stored in RAM, and streamed to the on-chip DACs.

## Features

- Data sampling at 9.8304 GSps
- 4 independent $2^{18}$-sample waveforms.
- Two output channels.
  - Each channel can output one of the two waveforms.
  - Waveform selection via software (AXI GPIOs) or an external signal.


## System Architecture


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
| control_trigger | PMOD0_1 | Input | External trigger signal.  Switches between waveform-A and waveform-B for DAC0 output and between waveform-C and waveform-D fpr DAC2 output. The actual signal is (axi_control || control_trigger)|
| pmod_out| PMOD0_0  | Output | Outputs control_trigger signal sampled at a 614.4 MHz clock.  |
| DAC 0| DAC A  | Output | DAC output |
| DAC 2| DAC B  | Output | DAC output |

The design contains AXI GPIOs that can be accessed by software. A sample C code is provided.
| Name | Memory Address |  Type | Description |
| -------- | -------- | -------- | -------- |
| rst_n | 0x00_A007_0000 | Output |1 bit. Software reset signal. Active negative signal. |
| write_enable | 0x00_A005_0000  | Output | 1 bit. Enables writing data to RAM bank. Set to 0 to enable output; set enable_ch0 and enambe_ch2 accordingly. |
| MAX_POINTS| 0x00_A006_0000  | Output | 32 bit. MAX_POINTS << 4 represnts the maximum number of points to output.  |
| enable_ch0 | 0x00_A009_0000 | Output | 1 bit. Enables output on DAC A if write_enable is low too. |
| enable_ch2| 0x00_A00A_0000 | Output | 1 bit. Enables output on DAC B if write_enable is low too. |
| axi_control| 0x00_A008_0000 | Output | 1 bit. Software trigger signal.  Switches between waveform-A and waveform-B for DAC0 output and between waveform-C and waveform-D for DAC2 output. The actual signal is (axi_control || control_trigger) |
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

High 
