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
												    
	constant TAKTFREQUENZ       : positive          := 12_000_000;
	constant BAUDRATE           : positive          := 115_200;
	constant ANZAHL_BITS        : positive          := 8;
	constant PARITAET_EIN       : std_ulogic        := '0';
	constant PARITAET_GERADE    : std_ulogic        := '0';
	constant STOPPBITS          : std_ulogic_vector := "00";

	signal   DG_Valid           : std_ulogic;
	signal   DG_Ready           : std_ulogic;
	signal   DG_Data            : std_ulogic_vector(DATA_WIDTH - 1 downto 0);
	
begin

	-- TODO: Komponente "Datengenerator" instanziieren

	-- TODO: "Serieller_Sender" instanziieren
end architecture;
