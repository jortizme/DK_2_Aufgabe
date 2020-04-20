-------------------------------------------------------------------------------
-- Serieller Sender
-------------------------------------------------------------------------------
-- Modul Digitale Komponenten
-- Hochschule Osnabrueck
-- Bernhard Lang, Rainer Hoeckmann
-------------------------------------------------------------------------------
-- BitBreiteM1 = (Taktfrequenz / Baudrate) - 1
--
-- Bits = AnzahlBits - 1
--
-- Kodierung Stoppbits:
--   00 - 1   Stoppbits
--   01 - 1,5 Stobbits
--   10 - 2   Stoppbits
--   11 - 2,5 Stoppbits
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Serieller_Sender is
	generic(
		DATA_WIDTH  	  	: positive;
		BITBREITE_WIDTH 	: positive;
		BITS_WIDTH		  	: positive
	);	
	port(	
		Takt			  	: in  std_ulogic;

		BitBreiteM1 		: in  std_ulogic_vector(BITBREITE_WIDTH - 1 downto 0);
		Bits  		  	    : in  std_ulogic_vector(BITS_WIDTH - 1 downto 0);
		Paritaet_ein	  	: in  std_ulogic;
		Paritaet_gerade	  	: in  std_ulogic;
		Stoppbits		  	: in  std_ulogic_vector(1 downto 0);

		S_Valid			    : in  std_ulogic;
		S_Ready			    : out std_ulogic;
		S_Data			  	: in  std_ulogic_vector(DATA_WIDTH - 1 downto 0);

		TxD				  	: out std_ulogic
	);
end entity;

architecture rtl of Serieller_Sender is	
	
	-- Typ fuer die Ansteuerung des Multiplexers
	type TxDSel_type is (D, P, H, L);

	-- Signale zwischen Steuerwerk und Rechenwerk
	signal TxDSel    : TxDSel_type := H;
	signal ShiftEn   : std_ulogic;
	signal ShiftLd   : std_ulogic;
	signal CntSel    : std_ulogic := '-';
	signal CntEn     : std_ulogic;
	signal CntLd     : std_ulogic;
	signal CntTc     : std_ulogic := '1';	--Warum ist das auf High? Es sollte '0' sein
	signal BBSel     : std_ulogic := '0';
	signal BBLd      : std_ulogic;
	signal BBTC      : std_ulogic := '0';
	
begin
	Rechenwerk: block
	
	    -- Interne Signale des Rechenwerks
		signal DataBit   : std_ulogic := '0';
		signal ParityBit : std_ulogic := '0';
		
	begin
		-- Schieberegister zur Aufnahme der Sendedaten
		Schieberegister: process(Takt)
			variable Q : std_ulogic_vector(DATA_WIDTH - 1 downto 0) := (others=>'0');
		begin
			if rising_edge(Takt) then	

				if ShiftLd = '1' then
					Q = S_Data;	
				elsif ShiftEn = '1'
					DataBit <= Q(0);
					Q(DATA_WIDTH - 2 downto 0) = Q(DATA_WIDTH - 1 downto 1);				
				end if;

			end if;			
		end process;
		
		-- Register fuer das Paritaetsbit
		FF: process(Takt)
			variable p : std_ulogic := '0';
		begin
			if rising_edge(Takt) then
			
				if ShiftLd = '1' then
					p := not Paritaet_gerade;
					
					for i in S_Data'range loop
						if i <= unsigned(Bits) then
							p := p xor S_Data(i);
						end if;
					end loop;
					
					ParityBit <= p;
				end if;
				
			end if;
		end process;
		
		-- Zaehler Bits und Stoppbits
		ZaehlerBits: process(Takt)
			variable Q : unsigned(BITS_WIDTH - 1 downto 0) := (others=>'0');
			variable Stop_Bit : 
		begin
			if rising_edge(Takt) then

				case( CntSel ) is
				
					when '0' =>	
								if CntLd = '1' then
									Q = Bits;							
								end if;
					when '1' =>
								if CntEn = '1' then
									Q := Q - 1;
									if Q = 0 then
										CntTc <= '1';
									end if;

								else if CntLd = '1' then
								
									-- TODO --

								end if;
					--Maybe "when others" must be here too
				end case ;
			end if;
		end process;
		
		-- Zaehler Bitbreite
		ZaehlerBitbreite: process(Takt)
			variable Q : unsigned(BITBREITE_WIDTH - 1 downto 0) := (others=>'0');
		begin
			if rising_edge(Takt) then

				BBTC <= '0';	--default

				case( BBSel ) is
				
					when '0' =>
								if BBLd = '1' or BBTC = '1' then
									Q := Q + 1;
									if Q = unsigned(BitBreiteM1) then	
										Q := (others => 0);
										BBTC <= '1'
									end if ;
								end if ;
				
					when '1' =>
									-- TO DO --
				
				end case ;


				-- TODO: Funktion des Zaehlers beschreiben (Ausgang: BBTC)
			end if;
		end process;
		
		-- Ausgangsmultiplexer
		OutMux: process(TxDSel, DataBit, ParityBit)
		begin

			-- TODO: Funktion des Multiplexers beschreiben (Ausgang: TxD)
			
		end process;
	end block;
	
	Steuerwerk: block
	
		-- Typ fuer die Zustandswerte
		type Zustand_type is (Z_IDLE, Z_START, Z_BITS, Z_PARI, Z_STP, Z_ERROR);

	    -- Interne Signale des Rechenwerks
		signal Zustand      : Zustand_type := Z_IDLE;
		signal Folgezustand : Zustand_type;		
		
		-- Internes Signal fuer die Initialisierung
		signal S_Ready_i    : std_ulogic := '1';
		
	begin	
		-- Wert des internen Signals an Port zuweisen	
		process(S_Ready_i)
		begin
			S_Ready <= S_Ready_i;
		end process;

		-- Prozess zur Berechnung des Folgezustands und der Mealy-Ausgaenge
		Transition: process(Zustand, S_Valid, BBTC, CntTC, Paritaet_ein)
		begin
			
			-- Default-Werte fuer den Folgezustand und die Mealy-Ausgaenge
			ShiftEn      <= '0'; 
			ShiftLd      <= '0'; 
			CntEn        <= '0'; 
			CntLd        <= '0'; 
			BBLd         <= '0';
			Folgezustand <= Z_ERROR;
			
			-- Berechnung des Folgezustands und der Mealy-Ausgaenge
			-- TODO: Alle Uebergaenge des Zustandsdiagramms in VHDL formulieren
			
		end process;
		
		-- Register fuer Zustand und Moore-Ausgaenge
		Reg: process(Takt)
		begin
			if rising_edge(Takt) then

				-- Zustandsregister
				-- TODO: Funktion des Zustandsregisters beschreiben
				
				-- Berechnung der Moore-Ausgaenge aus dem Folgezustand
				-- TODO: Aus dem Folgezustand die Werte der Moore-Ausgaenge bestimmen
			end if;
		end process;
			
	end block;
end architecture;