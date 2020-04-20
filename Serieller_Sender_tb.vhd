library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Serieller_Sender_tb is
end entity;

use work.test_serial.all;
use work.txt_util_pack_v1_2.all;

architecture testbench of Serieller_Sender_tb is

	constant Taktfrequenz       : positive := 12_000_000;
	constant DATA_WIDTH  	  	: positive := 8;
	constant BITBREITE_WIDTH 	: positive := 20;
	constant BITS_WIDTH		  	: positive := 3;

	function BitsValue(AnzahlBits : positive) return std_ulogic_vector is
	begin
		return std_ulogic_vector(to_unsigned(AnzahlBits - 1, BITS_WIDTH));
	end function;
	
	function BitbreiteValue(Baudrate : positive) return std_ulogic_vector is
		variable AnzahlTakte : positive;
	begin
		return std_ulogic_vector(to_unsigned(Taktfrequenz / Baudrate - 1, BITBREITE_WIDTH));
	end function;
	
	function StoppbitsValue(Stoppbits : real) return std_ulogic_vector is
	begin
		if    Stoppbits = 1.0 then return "00";
		elsif Stoppbits = 1.5 then return "01";
		elsif Stoppbits = 2.0 then return "10";
		elsif Stoppbits = 2.5 then return "11";
		else                       return "XX";
		end if;
	end function;
	
	signal Takt             : std_ulogic := '0';
	signal BitBreiteM1 		: std_ulogic_vector(BITBREITE_WIDTH - 1 downto 0);
	signal Bits  		  	: std_ulogic_vector(BITS_WIDTH - 1 downto 0); -- Achtung Bits = AnzahlBits - 1!
	signal Paritaet_ein	  	: std_ulogic;
	signal Paritaet_gerade	: std_ulogic;
	signal Stoppbits		: std_ulogic_vector(1 downto 0);
	signal S_Valid			: std_ulogic := '0';
	signal S_Ready			: std_ulogic;
	signal S_Data			: std_ulogic_vector(DATA_WIDTH - 1 downto 0);
	signal TxD				: std_ulogic;
	signal Start			: std_ulogic;
	signal Data             : std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others=>'-');
	
	type testcase_record is record
		Baudrate        : positive;
		AnzahlBits      : positive;
		Paritaet_ein    : boolean;
		Paritaet_gerade : boolean;
		Stoppbits       : real;
		Zeichen         : std_ulogic_vector(DATA_WIDTH - 1 downto 0);
	end record;
	
	type testcase_vector is array(natural range <>) of testcase_record;
	
	constant tests : testcase_vector(0 to 15) := (
		 0=>(115_200, 5, false, false, 1.0, x"15"),
		 1=>(115_200, 6, false, false, 1.5, x"2A"),
		 2=>(115_200, 7, false, false, 2.0, x"55"),
		 3=>(115_200, 8, false, false, 2.5, x"AA"),
		 4=>(256_000, 5, false, false, 1.0, x"15"),
		 5=>(256_000, 6, false, false, 1.5, x"2A"),
		 6=>(256_000, 7, false, false, 2.0, x"55"),
		 7=>(256_000, 8, false, false, 2.5, x"AA"),
		 8=>(256_000, 5, true,  false, 1.0, x"15"),
		 9=>(256_000, 6, true,  false, 1.5, x"2A"),
		10=>(256_000, 7, true,  false, 2.0, x"55"),
		11=>(256_000, 8, true,  false, 2.5, x"AA"),
		12=>(256_000, 5, true,  true,  1.0, x"15"),
		13=>(256_000, 6, true,  true,  1.5, x"2A"),
		14=>(256_000, 7, true,  true,  2.0, x"55"),
		15=>(256_000, 8, true,  true,  1.5, x"AA")
	);
	
begin
	-- Clock Generation
	GenClock: process
	begin
		wait for 1 sec / Taktfrequenz / 2;
		Takt <= not Takt;
	end process;
	
	Stimulate: process
		function to_std_ulogic(x: boolean) return std_ulogic is
		begin
			if x then 
				return '1';
			else 
				return '0';
			end if;
		end function;
		
		procedure execute_test(i: integer; ok: out boolean) is
			variable v : std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others=>'-');
		begin
			ok := true;
		
			wait until falling_edge(Takt);
			S_Valid <= '1';
			BitBreiteM1     <= BitBreiteValue(tests(i).Baudrate);
			Bits          <= BitsValue(tests(i).AnzahlBits);
			Paritaet_ein    <= to_std_ulogic(tests(i).Paritaet_ein);
			Paritaet_gerade <= to_std_ulogic(tests(i).Paritaet_gerade);
			Stoppbits       <= StoppbitsValue(tests(i).Stoppbits);
			S_Data          <= tests(i).Zeichen;
			loop
				wait until rising_edge(Takt);
				if s_ready = '1' then exit;	end if;
			end loop;
			
			if(i = tests'High) then
				S_Valid <= '0';
			end if;

			Serial_Receive(
				Baudrate => tests(i).Baudrate, 
				Num_Bits => tests(i).AnzahlBits, 
				Parity   => tests(i).Paritaet_ein, 
				P_even   => tests(i).Paritaet_gerade, 
				Start    => Start,
				RxD      => TxD, 
				Data     => v 
			);
			Data <= v;
			
			if v /= tests(i).Zeichen then
				ok := false;
				report "Test #" & str(i) & ": Falscher Wert: 0x"  & hstr(v) & ". Erwartet: 0x" & hstr(tests(i).zeichen) severity error;
			end if;
		end procedure;
		
		variable errors : natural := 0;
		variable result : boolean;
	begin
		wait for 100 ns;

		for i in tests'range loop
			execute_test(i, result);
			if not result then
				errors := errors + 1;
			end if;
		end loop;
		
		report str(tests'Length) & " Tests durchgefuehrt. " & str(errors) & " Fehler.";
		
		wait;
	end process;
		
	UUT: entity work.Serieller_Sender
	generic map(
		DATA_WIDTH  	  	=> DATA_WIDTH,
		BITBREITE_WIDTH 	=> BITBREITE_WIDTH,
		BITS_WIDTH		  	=> BITS_WIDTH
	)
	port map(	
		Takt			  	=> Takt,
		BitBreiteM1 		=> BitBreiteM1,
		Bits  		  	    => Bits,
		Paritaet_ein	  	=> Paritaet_ein,
		Paritaet_gerade	  	=> Paritaet_gerade,
		Stoppbits		  	=> Stoppbits,
		S_Valid			    => S_Valid,
		S_Ready			    => S_Ready,
		S_Data			  	=> S_Data,
		TxD				  	=> Txd
	);
	
end architecture;