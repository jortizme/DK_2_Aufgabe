library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Datengenerator_tb is
end entity;

architecture bench of Datengenerator_tb is

	signal Takt    : std_ulogic := '0';
	signal M_Valid : std_ulogic;
	signal M_Ready : std_ulogic := '0';
	signal M_Data  : std_ulogic_vector(7 downto 0) ;

	constant clock_period : time := 10 ns;
	constant TXT          : string(1 to 19) := "Hallo hier bin ich" & LF;
	constant ITERATIONS   : positive := 2;

begin

	uut: entity work.Datengenerator 
		generic map (                                   
			TXT => TXT
		)
		port map ( 
			Takt    => Takt,
			M_Valid => M_Valid,
			M_Ready => M_Ready,
			M_Data  => M_Data 
		);

	verification: process		
	begin
		
		wait until falling_edge(Takt);
		M_Ready <= '1';
		for i in 1 to ITERATIONS loop
			for j in TXT'Range loop
				loop
					wait until rising_edge(Takt);
					if M_Valid = '1' then exit; end if;
				end loop;
				assert M_Data = std_ulogic_vector(to_unsigned(character'pos(TXT(j)), M_Data'Length)) report "Falsches Zeichen" severity error;
				report "Zeichen empfangen -----------------------------------> '" & character'val(to_integer(unsigned(M_Data))) & "'";
			end loop;
		end loop;
		wait until falling_edge(Takt);
		M_Ready <= '0';
		report "Test beendet";
		wait;
	end process;

	clocking: process
	begin
		wait for clock_period / 2;
		Takt <= not Takt;
	end process;

end architecture;