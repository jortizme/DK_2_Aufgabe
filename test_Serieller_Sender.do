if {![file exists work]} { 
	vlib work 
}

vcom Serieller_Sender.vhd 
vcom test_serial.vhd
vcom txt_util_pack_v1_2.vhd
vcom Serieller_Sender_tb.vhd 

vsim -t ns -voptargs=+acc work.serieller_sender_tb

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

add wave /serieller_sender_tb/Takt
add wave -unsigned /serieller_sender_tb/UUT/BitBreiteM1
add wave -unsigned /serieller_sender_tb/UUT/Bits
add wave /serieller_sender_tb/UUT/Paritaet_ein
add wave /serieller_sender_tb/UUT/Paritaet_gerade
add wave /serieller_sender_tb/UUT/Stoppbits
add wave /serieller_sender_tb/UUT/S_Valid
add wave /serieller_sender_tb/UUT/S_Ready
add wave -hexadecimal /serieller_sender_tb/UUT/S_Data

add wave -divider "Schieberegister"
add wave /serieller_sender_tb/UUT/ShiftEn
add wave /serieller_sender_tb/UUT/ShiftLd
add wave /serieller_sender_tb/UUT/Rechenwerk/DataBit

add wave -divider "FF"
add wave /serieller_sender_tb/UUT/ShiftLd
add wave /serieller_sender_tb/UUT/Rechenwerk/ParityBit

add wave -divider "Zaehler Bits und Stoppbits"
add wave /serieller_sender_tb/UUT/CntSel
add wave /serieller_sender_tb/UUT/CntLd
add wave /serieller_sender_tb/UUT/CntEn
add wave /serieller_sender_tb/UUT/CntTc

add wave -divider "Zaehler Bitbreite"
add wave /serieller_sender_tb/UUT/BBSel
add wave /serieller_sender_tb/UUT/BBLd
add wave /serieller_sender_tb/UUT/BBTC

add wave -divider "Ausgangsmultiplexer"
add wave /serieller_sender_tb/UUT/TxDSel

add wave -divider
add wave /serieller_sender_tb/UUT/TxD
add wave /serieller_sender_tb/Start
add wave -hexadecimal /serieller_sender_tb/Data
add wave /serieller_sender_tb/UUT/Steuerwerk/Zustand

run 800 us
wave zoom full