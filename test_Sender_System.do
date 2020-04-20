if {![file exists work]} { 
	vlib work 
}

vcom -work work Datengenerator.vhd
vcom -work work serieller_sender.vhd
vcom -work work sender_system.vhd
vcom -work work test_serial.vhd
vcom -work work Sender_System_tb.vhd

vsim -voptargs=+acc work.Sender_System_tb

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
configure wave -timelineunits ms

add wave                         /Sender_System_tb/Takt

add wave -divider "Eingang des Seriellen Senders"
add wave                         /Sender_System_tb/uut/DG_Valid
add wave                         /Sender_System_tb/uut/DG_Ready
add wave -ascii -radixshowbase 0 /Sender_System_tb/uut/DG_Data

add wave -divider "Ausgang des Seriellen Senders"
add wave                         /Sender_System_tb/TxD

add wave -divider "Von der Testbench erzeuge Signale"
add wave                         /Sender_System_tb/Start
add wave -ascii -radixshowbase 0 /Sender_System_tb/Data

run 2 ms
wave zoom full
