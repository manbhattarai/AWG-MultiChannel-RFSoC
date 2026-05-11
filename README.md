# AWG-MultiChannel-RFSoC

[![Platform](https://img.shields.io/badge/Platform-RealDigital%20RFSoC%204x2-red)]([https://redpitaya.com/](https://www.realdigital.org/hardware/rfsoc-4x2))
[![FPGA](https://img.shields.io/badge/FPGA-ZYNQ%20Ultrascale+%20RFSoC%20ZU48DR-blue)]([https://www.xilinx.com/](https://www.amd.com/en/products/adaptive-socs-and-fpgas/soc/zynq-ultrascale-plus-rfsoc.html))


## Overview
High-sampling-rate, high-memory-density, multi-channel arbitrary waveform generator.

## Features

- Data sampling at 9.8304 GSps
- 4 independent $2^{18}$-sample waveforms.
- Two output channels.
  - Each channel can output one of the two waveforms.
  - Waveform selection via software (AXI GPIOs) or an external signal.
- 


## System Architecture
The AWG 

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

## Input/Output 
The relevant I/O pins and ports on the board are
| Name | Pin/Port |  Type | Description |
| -------- | -------- | -------- | -------- |
| Control_Trigger | PMOD0_1 | Input | External trigger signal.  |
| pmod_out| PMOD0_0  | Output | Generates a TTL pulse when the threshold condition is met.  |
| DAC| DAC A  | Output | Outputs the YAG_Trigger singal. Only meant for diagnostics. |
| DAC | DAC B | Output | PMT pulse signal. Typically a negative pulse. |

The design contains AXI GPIOs that can be accessed by software. A sample C code is provided.
| Name | Memory Address |  Type | Description |
| -------- | -------- | -------- | -------- |
| axi_gpio_0 | 0x4120_0000 | Input |12 bit. Memory address to read the content of the counter RAM |
| axi_gpio_1 | 0x4121_0000  | Output | 14 bit. Threshold value (unsigned input, interpreted as 14-bit 2's complement by hardware). Values 0-8191 represent positive thresholds, values 8192-16383 represent negative thresholds. Threshold is met when \|signal\| > \|threshold\| |
| axi_gpio_2| 0x4122_0000  | Input | 8 bit. Count value at the memory address specified by axi_gpio_0  |
| axi_gpio_3 | 0x4123_0000 | Output | 1 bit. Read the YAG_trigger signal |
| pll_locked_out| 0x4124_0000 | Output | 1 bit. Read the locked state of the PLL. 1 represents locked, and 0 unlocked. |
| empty_full| 0x4125_0000 | Output | 2 bit. FIFO empty and full signal. Bit 0 represnts if full, and Bit 1 represnets if empty. |
| axi_gpio_4| 0x4126_0000 | Output | 1 bit. TTL signal that goes high when the signal meets the threshold condition. |
| disc_width| 0x4127_0000 | Input |2 bit. Discriminator pulse width setting (see table below)   |



## Usage





## Board Files
The board file can be installed from
https://github.com/RealDigitalOrg/RFSoC4x2-BSP

High 
