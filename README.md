# awgn_boxmuller
AWGN signal generator IP for FPGA implemented by Verilog HDL with Fmax up to 320MHz on Xilinx Virtex Ultra-Scale FPGA.

The generator is based on Box-Muller Algrithom and the fixed point proccessing with accuracy analysis refer to the following paper:
-D. U. Lee, J. D. Villasenor, W. Luk, and P. H. W. Leong, “A hardware
 Gaussian noise generator using the box-muller method and its error
 analysis,” IEEE Transactions on Computers, vol. 55, no. 6, pp. 659–671, June 2006.

IP core features:
1.Synthesizable Verilog HDL design for FPGA/ASIC.
2.Bit accurate matlab fixed point model.
3.High precision performance accurate to one unit in the last place up to 8.15 sigma.
4.State-of-the-art simulation enviorement for Modelsim.

Performance Test
TBD
