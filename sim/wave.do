onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_dut/clock
add wave -noupdate /tb/u_dut/rst_n
add wave -noupdate /tb/u_dut/init
add wave -noupdate /tb/u_dut/ce
add wave -noupdate -radix hexadecimal /tb/u_dut/seed0
add wave -noupdate -radix hexadecimal /tb/u_dut/seed1
add wave -noupdate /tb/u_dut/e_vld
add wave -noupdate -radix unsigned /tb/u_dut/e
add wave -noupdate /tb/u_dut/f_vld
add wave -noupdate -radix unsigned /tb/u_dut/f
add wave -noupdate /tb/u_dut/g_vld
add wave -noupdate -radix unsigned /tb/u_dut/ga
add wave -noupdate -radix unsigned /tb/u_dut/gb
add wave -noupdate -radix unsigned /tb/u_dut/ga_d7
add wave -noupdate -radix unsigned /tb/u_dut/gb_d7
add wave -noupdate /tb/u_dut/x_vld
add wave -noupdate /tb/u_dut/x_en
add wave -noupdate -format Analog-Step -height 80 -max 35550.999999999993 -min -36822.0 -radix decimal /tb/u_dut/x0
add wave -noupdate -format Analog-Step -height 80 -max 34644.000000000007 -min -36904.0 -radix decimal /tb/u_dut/x1
add wave -noupdate -radix unsigned /tb/e_rd
add wave -noupdate -color {Violet Red} /tb/e_err
add wave -noupdate -radix unsigned /tb/f_rd
add wave -noupdate -color {Violet Red} /tb/f_err
add wave -noupdate -radix unsigned /tb/g0_rd
add wave -noupdate -radix unsigned /tb/g1_rd
add wave -noupdate -color {Violet Red} /tb/g0_err
add wave -noupdate -color {Violet Red} /tb/g1_err
add wave -noupdate -radix decimal /tb/x0_rd
add wave -noupdate -radix decimal /tb/x1_rd
add wave -noupdate -color {Violet Red} /tb/x0_err
add wave -noupdate -color {Violet Red} /tb/x1_err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3401 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 186
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {927142 ps}
