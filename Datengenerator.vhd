--------------------------------------------------------------------------------
-- Dateiname: Datengenerator.vhd
--
-- Erzeugung eines Datenstroms aus einer Zeichenkette
--
-- Erstellt: 13.02.2014, Rainer Hoeckmann
--
-- Aenderungen:
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Datengenerator is
	generic(
		constant TXT : string
	);
	port(
		Takt         : in  std_ulogic;
		M_Valid      : out std_ulogic;
		M_Ready      : in  std_ulogic;
		M_Data       : out std_ulogic_vector(7 downto 0)
	);
end entity;

architecture rtl of Datengenerator is

	-- Interne Signale fuer die Initialisierung
	signal M_Data_i  : std_ulogic_vector(M_Data'range) := std_ulogic_vector(to_unsigned(character'pos(TXT(1)), M_Data'length));
	signal M_Valid_i : std_ulogic := '1';
	
begin
	-- Wert des internen Signals an den Port zuweisen
	process(M_Valid_i)
	begin
		M_Valid <= M_Valid_i;
	end process;

	-- Wert des internen Signals an den Port zuweisen
	process(M_Data_i)
	begin
		M_Data  <= M_Data_i;
	end process;
  
    -- Synchroner Prozess zur Ausgabe
	process(Takt) is
		variable i: integer range 1 to TXT'length := 1;  
	begin
		if rising_edge(Takt) then
			
			if M_Ready = '1' and M_Valid_i = '1' then		
				
				M_Data_i <= std_ulogic_vector(to_unsigned(character'pos(TXT(1+i)), M_Data_i'length)); 
				i := i+1;--wenn den über mdata ergibt fehler...	
				if i = (TXT'length) then 
					M_Valid_i <= '0';
				end if;			
			end if;

			--Alternative
			--if M_Ready = '1'  and M_Valid_i = '1' then		
				
				--for cnt in 1 to TXT'length loop
				--	M_Data_i <= std_ulogic_vector(to_unsigned(character'pos(TXT(1+cnt)), M_Data_i'length));

				--	if cnt = (TXT'length) then
				--		M_Valid_i <= '0';
				--	end if;			
			--	end loop; 				
			--end if;	
			
		end if;
	end process;
end architecture;