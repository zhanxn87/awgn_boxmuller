# awgn_boxmuller
I. Introduction

AWGN signal generator IP for FPGA implemented by Verilog HDL with Fmax up to 320MHz 
on Xilinx Virtex Ultra-Scale FPGA.

The generator is based on Box-Muller Algorithm and the fixed point proccessing with 
accuracy analysis refer to the following paper:

-D. U. Lee, J. D. Villasenor, W. Luk, and P. H. W. Leong, “A hardware
 Gaussian noise generator using the box-muller method and its error
 analysis,” IEEE Transactions on Computers, vol.55, no.6, pp.659–671, June 2006.

II. IP core features

  1.Synthesizable Verilog HDL design for FPGA/ASIC.
  2.Bit accurate matlab fixed point model.
  3.High precision performance accurate to one unit in the last place up to 8.15 sigma.
  4.State-of-the-art simulation enviorement for Modelsim.

III. Performance Test

  TBD

IV. Use Guide

1. matlab running

1) Open Matlab software, direct to the "matlab" subdirectory under the project.

2) If First time using, need to run "mex taus_URNG.c" command, this will generate the needed mex function according your OS.

3) Modify the "len" and "write_file" value according to your purpose:

  a)"len" represent the samples number to be generate, recommanded value for bit-Match simulation is 1e5 to 1e6, for performance evaluation the value can be set to 1e7 to 1e8;
  
  b)"write_file" is a signal to control golden files (for RTL bit-Match) writing on-off. 
    If "write_file=0", matlab will not write golden files and will draw the PDF figure to illustrate the random feature of the algorithm;
	If "write_file=1", the opsite behaviour of above.
	
4) run function "BoxMuller_Fixed" directly(random seed is set to 8628673799 default), or with the specific random_seed, for example "BoxMuller_Fixed(123456)"
	
2. Simulation (Modelsim on Windows)

1) Direct to the subdirec "sim";

2) Double click "run_modelsim.bat"(Modelsim has been installed on your OS ready.)

  a) "run_modelsim.bat" call "vsim -do run_sim.do".
  
  b) "run_sim.do" setup the environment for simulation, including vlib, vlog, vsim, and run wave.do to add waves to view.
  
  c) All used files(verilog) are included in file "file.list", and called by "run_sim.do" script.
  
  d) View and check the output waveform. "tb.v" read input data and golden data from the "bitMatchFile" subdirectory under "matlab" directory, and compares them to the data output by RTL.
	 The error signals indicate the mismatch comparement are also listed in the waveform view.

3. Synthesize and Implementation of FPGA

  The Verilog codes are totally synthesizable independent from any FPGA/ASIC IP core/libraries, feel free to use them.
  
