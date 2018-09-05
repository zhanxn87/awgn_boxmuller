#[Library]
vlib work
vmap work work

#[vcom]

#[vlog]
vlog +acc -work work -incr -f file.list

#[add wave]
#do wave.do

#[vsim]
vsim -lib work tb -t 1ns

do wave.do

#run
run 1000us

