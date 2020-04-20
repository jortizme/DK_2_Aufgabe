if {![file exists work]} { 
	vlib work 
}

vcom Datengenerator.vhd
vcom Datengenerator_tb.vhd

vsim -voptargs=+acc work.datengenerator_tb

configure wave -namecolwidth 173
configure wave -valuecolwidth 106
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0

add wave                         /datengenerator_tb/Takt
add wave                         /datengenerator_tb/M_Valid
add wave                         /datengenerator_tb/M_Ready
add wave -ascii -radixshowbase 0 /datengenerator_tb/M_Data

run 400 ns
wave zoom full

