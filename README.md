# AWG-MultiChannel-RFSoC

[![Platform](https://img.shields.io/badge/Platform-RealDigital%204x2RFSoC-red)]([https://redpitaya.com/](https://www.realdigital.org/hardware/rfsoc-4x2))
[![FPGA](https://img.shields.io/badge/FPGA-Zynq--7010-blue)](https://www.xilinx.com/)


## Overview
Fast sampling, high memory density multichannel arbitrary waveform generator.

## Features

- Data sampling at 9.8304 GSps
- 4 independent $2^{18}$ sample $waveforms
- 3000 time bins with 10 µs resolution
- Robust clock domain crossing with custom FIFO
- AXI GPIO interface for software control
- Analog output monitoring (DAC)
- Configurable discriminator pulse width (8-64 ns)


## System Architecture

## Input/Output

## Usage



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

## Board Files
The board file can be installed from
https://github.com/RealDigitalOrg/RFSoC4x2-BSP

High 
