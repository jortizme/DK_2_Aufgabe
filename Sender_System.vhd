-- Dateiname: sender_system.vhd
--
-- Erzeugung eines Datenstroms fuer die serielle Schnittstelle mit einem
-- Datengenerator
--
-- Erstellt: 18.02.2016, Rainer Hoeckmann
--
-- Aenderungen:
-- 2020-03-30 Uebernommen fuer Modul Digitale Komponenten
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Sender_System is
	port(
		Takt : in  std_ulogic;
		TxD  : out std_ulogic
	);
end entity;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of Sender_System is

	constant TXT                : string(1 to 19)   := "Hallo hier bin ich" & LF;
	
	constant DATA_WIDTH  	  	: positive          := 8;
	constant BITBREITE_WIDTH 	: positive          := 16;
	constant BITS_WIDTH		  	: positive          := 4;

	constant TAKT_FREQUENZ      : positive          := 12_000_000;
	constant BAUDRATE           : positive          := 115_200;
	constant ANZAHL_BITS        : positive          := 8;
	constant PARITAET_EIN       : std_ulogic        := '0';
	constant PARITAET_GERADE    : std_ulogic        := '0';
	constant STOPPBITS          : std_ulogic_vector := "00";

	signal   DG_Valid           : std_ulogic;
	signal   DG_Ready           : std_ulogic;
	signal   DG_Data            : std_ulogic_vector(DATA_WIDTH - 1 downto 0);

	function BitsValue(AnzahlBits : positive) return std_ulogic_vector is
	begin
			return std_ulogic_vector(to_unsigned(AnzahlBits - 1, BITS_WIDTH));
	end function;
		
	function BitbreiteValue(Baudrate : positive) return std_ulogic_vector is
			variable AnzahlTakte : positive;
	begin
			return std_ulogic_vector(to_unsigned(TAKT_FREQUENZ / Baudrate - 1, BITBREITE_WIDTH));
	end function;
	
begin

	Sender: entity work.Datengenerator
		generic map(
			TXT 		=> TXT
		)
		port map(
			Takt      	=> Takt,   
			M_Valid     => DG_Valid,
			M_Ready     => DG_Ready,
			M_Data      => DG_Data
		);
		
	Receiver: entity work.Serieller_Sender
		generic map (
			DATA_WIDTH 		=> DATA_WIDTH,
			BITBREITE_WIDTH => BITBREITE_WIDTH,
			BITS_WIDTH 		=> BITS_WIDTH

		)
		port map(
			Takt 			=>	Takt, 			  	

			BitBreiteM1 	=> BitBreiteValue(BAUDRATE),
			Bits			=> BitsValue(ANZAHL_BITS),	    
			Paritaet_ein	=> PARITAET_EIN,
			Paritaet_gerade	=> PARITAET_GERADE,
			Stoppbits		=> STOPPBITS,	

			S_Valid			=>	DG_Valid,	    
			S_Ready			=>	DG_Ready,
			S_Data			=>	DG_Data,  	

			TxD				=>	TxD
		);

end architecture;
