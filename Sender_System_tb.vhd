-- Dateiname: Sender_System_tb.vhd
--
-- Erzeugung eines Datenstroms aus einer Zeichenkette
--
-- Erstellt: 18.02.2016, Rainer Hoeckmann
--
-- Aenderungen:
-- 2020-03-30 Uebernommen fuer Modul Digitale Komponenten
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
ENTITY Sender_System_tb IS
END entity;

use work.test_serial.all;

architecture behavior of Sender_System_tb is 

	constant TAKT_PERIOD : time := 83.333 ns; 
	
	signal Takt  : std_logic := '0';
	signal TxD   : std_logic;
	signal Data  : std_ulogic_vector(7 downto 0) := (others=>'U');
	signal Start : std_ulogic;

begin

	uut: entity work.sender_system 
	port map (
		Takt => Takt,
		TxD  => TxD
	);

	Takt_process: process
	begin
		Takt <= '0';
		wait for TAKT_PERIOD / 2;
		Takt <= '1';
		wait for TAKT_PERIOD / 2;
	end process;

	receive: process
		variable v : std_ulogic_vector(7 downto 0);
	begin
		Serial_Receive (
			Baudrate  => 115200,
			Num_Bits  => 8,
			Parity    => false,
			P_even    => false,
			RxD       => TxD,
			Start     => Start,
			Data      => v
		);  
		Data <= v;
		wait for 1 ns;
	end process;
  
end;
