################################################################################
# Dateiname: sender_system.xdc
#
# Constraints File fuer Vivado
#
# Erstellt: 30.03.2020, Rainer Hoeckmann
#
# Aenderungen:
################################################################################

# Clock signal	
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { Takt }];
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports { TxD }];

# UART TxD signal
set_property -dict { PACKAGE_PIN M3   IOSTANDARD LVCMOS33 } [get_ports { TxD }];

