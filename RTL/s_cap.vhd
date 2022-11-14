---- convergence adding plate

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all; 

entity S_CAP is
	GENERIC(
      n : INTEGER := 16
        );
	port (clk, rst, run : in std_logic;
		out_reg : out std_logic;
        dinF , dinI ,dinG, dinO: in STD_LOGIC_VECTOR (32*n-1 DOWNTO 0);
        doutF, doutI, doutG, doutO :out std_logic_vector(31 downto 0)
        );
end S_CAP;

architecture behavioural of S_CAP is 

component CAP4 IS 
	GENERIC( n : INTEGER := 16 );
	port (clk , in_reg , add_reg , reg_out : in std_logic;
		  sel : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		  dinF , dinI ,dinG, dinO: in STD_LOGIC_VECTOR (32*n-1 DOWNTO 0);
          doutF, doutI, doutG, doutO :out std_logic_vector(31 downto 0) );
END component;	
  
component CAP_controller IS 
	generic ( n : INTEGER := 8);
	PORT (clk, rst, run : IN STD_LOGIC;
		  sel : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		  in_reg, add_reg, out_reg : OUT STD_LOGIC );       
END component;

signal in_reg , add_reg , reg_out : std_logic;
signal sel : STD_LOGIC_VECTOR (3 DOWNTO 0);
begin 

	CAP_N : CAP4 
	GENERIC MAP( n )
	port map (clk , in_reg , add_reg , reg_out,
		  sel , dinF , dinI ,dinG, dinO,
          doutF, doutI, doutG, doutO );
	ctrl : CAP_controller  
	generic map( n )
	PORT map(clk, rst, run ,
		  sel ,
		  in_reg, add_reg, reg_out );
		  
	out_reg <= reg_out;

END behavioural;	 
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all; 

entity CAP4 is
	GENERIC(
      n : INTEGER := 16
        );
	port (clk , in_reg , add_reg , reg_out : in std_logic;
		sel : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        dinF , dinI ,dinG, dinO: in STD_LOGIC_VECTOR (32*n-1 DOWNTO 0);
        doutF, doutI, doutG, doutO :out std_logic_vector(31 downto 0)
        );
end CAP4;

architecture behavioural of CAP4 is 


component CAP1 IS 
  GENERIC(
      n : INTEGER := 16
        );
  PORT (clk : IN STD_LOGIC ;
		sel : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		in_reg, add_reg, out_reg : IN STD_LOGIC;
	    din : IN STD_LOGIC_VECTOR(32*n-1 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
       );
END component;	
  

begin 

	  CAPF : CAP1 
			  GENERIC MAP( n )
			  PORT MAP(clk ,
					sel ,
					in_reg, add_reg, reg_out ,
					dinF ,
					doutF 
				   );
	  CAPI : CAP1 
			  GENERIC MAP( n )
			  PORT MAP(clk ,
					sel ,
					in_reg, add_reg, reg_out ,
					dinI ,
					doutI 
				   );
	  CAPO : CAP1 
			  GENERIC MAP( n )
			  PORT MAP(clk ,
					sel ,
					in_reg, add_reg, reg_out ,
					dinO ,
					doutO 
				   );
	  CAPG : CAP1 
			  GENERIC MAP( n )
			  PORT MAP(clk ,
					sel ,
					in_reg, add_reg, reg_out ,
					dinG ,
					doutG 
				   );


END behavioural;	 
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY CAP1 IS 
  GENERIC(
      n : INTEGER := 16
        );
  PORT (clk : IN STD_LOGIC ;
		sel : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		in_reg, add_reg, out_reg : IN STD_LOGIC;
	    din : IN STD_LOGIC_VECTOR(32*n-1 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
       );
END CAP1;	  


ARCHITECTURE behavioral_CAP OF CAP1 IS 

	COMPONENT  mux_cascading IS 
    PORT (
			sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			din : IN STD_LOGIC_VECTOR (511 DOWNTO 0);
			dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			);
	END COMPONENT;

	COMPONENT cap_add IS 
	  PORT (
			clk , in_reg , add_reg , reg_out : IN STD_LOGIC;
			din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			);
	END COMPONENT;

SIGNAL doutm : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL data_in_max : STD_LOGIC_VECTOR (32*16-1 DOWNTO 0);

BEGIN 
	 PROCESS ( din)
	 BEGIN  
		IF( n < 16) then
			data_in_max(32*n-1 DOWNTO 0)  <= din;
			data_in_max(511 DOWNTO 32*n)  <= (OTHERS => '0');
		ELSe
			data_in_max <= din;
		END IF;
	END PROCESS;

	  C_add : cap_add
		   PORT MAP(clk ,in_reg,add_reg ,out_reg ,
			doutm,
			dout
			);
	  mux : mux_cascading 
		  PORT MAP(
				sel ,
				data_in_max,
				doutm
				);      
END behavioral_CAP;

------------------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all; 

ENTITY mux_cascading IS 
  PORT (
        sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        din : IN STD_LOGIC_VECTOR (511 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
END mux_cascading;

architecture behavioral OF mux_cascading IS  
BEGIN  
	 
	 PROCESS(sel , din)
		 BEGIN 
		  CASE (sel)  IS  
			WHEN "0000" => dout <= din(31 DOWNTO 0) ;
			WHEN "0001" => dout <= din(63 DOWNTO 32) ;
			WHEN "0010" => dout <= din(95 DOWNTO 64) ;
			WHEN "0011" => dout <= din(127 DOWNTO 96) ;
			WHEN "0100" => dout <= din(159 DOWNTO 128) ;
			WHEN "0101" => dout <= din(191 DOWNTO 160) ;
			WHEN "0110" => dout <= din(223 DOWNTO 192) ;
			WHEN "0111" => dout <= din(255 DOWNTO 224) ;
		    WHEN "1000" => dout <= din(287 DOWNTO 256) ;
		    WHEN "1001" => dout <= din(319 DOWNTO 288) ;
		    WHEN "1010" => dout <= din(351 DOWNTO 320) ;
		    WHEN "1011" => dout <= din(383 DOWNTO 352) ;
		    WHEN "1100" => dout <= din(415 DOWNTO 384) ;
		    WHEN "1101" => dout <= din(447 DOWNTO 416) ;
		    WHEN "1110" => dout <= din(479 DOWNTO 448) ;
		    WHEN "1111" => dout <= din(511 DOWNTO 480) ;
			WHEN OTHERS => dout <= (OTHERS =>'0'); 
		  END CASE;
		  
	 END PROCESS;  

END behavioral;	 

------------------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all; 

ENTITY cap_add IS 
  PORT (clk , in_reg , add_reg , reg_out : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
END cap_add;

architecture behavioral OF cap_add IS  
COMPONENT SIGNED_ADD IS
generic ( n : integer := 31);
PORT (din1, din2 : in STD_LOGIC_VECTOR(31 downto 0);
	  dout : out STD_LOGIC_VECTOR(31 downto 0));
END COMPONENT;
SIGNAL  val1, outm1, d_reg1 :STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN  
	 PROCESS(clk)
		 BEGIN 
		   IF rising_edge(clk )then
			  IF(add_reg = '1')then
				   d_reg1 <= val1;
			  ELSIF ( in_reg ='1') then 
				  d_reg1 <= (OTHERS=>'0');
			  ELSIF (reg_out ='1') then
				   d_reg1 <= (OTHERS=>'0');
			  END IF;

			  IF (reg_out ='1') then
				   outm1 <= d_reg1;
			  END IF;
		 END IF;
	END PROCESS;  

	ADDER : SIGNED_ADD
		generic map(31)
		PORT MAP(din, d_reg1,val1);
	
	dout <= outm1 ;   
END behavioral;	 
------------------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;   
USE IEEE.NUMERIC_STD.all;

ENTITY CAP_controller IS 
	generic ( n : INTEGER := 8);
	PORT ( 
		  clk, rst, run : IN STD_LOGIC;
		  sel : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		  in_reg, add_reg, out_reg : OUT STD_LOGIC );       
END CAP_controller;	  

ARCHITECTURE contr OF CAP_controller IS 

component counter IS
	generic ( n : INTEGER := 8);
	PORT ( 
		  clk, rst,  en: in STD_LOGIC;
		  dout : out STD_LOGIC_VECTOR(n downto 0));
END component;

  TYPE mini_state IS  (init,  mull,  end_reg); -- add_pause,  
  SIGNAL ns,  ps : mini_state;
  SIGNAL count_r , rst_count_r : STD_LOGIC;
  SIGNAL add_row_i : STD_LOGIC_VECTOR(3 DOWNTO 0);
  
BEGIN 
-- c <= STD_LOGIC_VECTOR(to_UNSIGNED(n , 4));
PROCESS(clk) BEGIN 
  IF rising_edge(clk) then
    IF (rst ='1')then
      ps <= init; 
    ELSe  
      ps <= ns;  
    END IF;
  END IF;
END PROCESS;

PROCESS ( ps,  run,add_row_i )
  BEGIN 
	add_reg <= '0';
    out_reg <= '0';
	count_r <= '0';
	in_reg <= '0';
	rst_count_r <= '0';
	  CASE (ps) IS 
		WHEN init =>
				rst_count_r <= '1';
				in_reg <= '1';
			IF ( run = '1') then
				ns <= mull;
			ELSe
				ns <= init;
			END IF;
		WHEN mull =>
			count_r <= '1';
			add_reg <= '1';
			IF ( add_row_i = STD_LOGIC_VECTOR(to_UNSIGNED(n , 4) - 1)) then 
				IF ( run = '1') then
					ns <= mull;
					out_reg <= '1';
					rst_count_r <= '1';
				ELSe
					ns <= end_reg;
				END IF;
			ELSe 
				ns <= mull;
			END IF;
		WHEN end_reg =>
			out_reg <= '1';
			rst_count_r <= '1';
			IF ( run = '1') then
				ns <= mull;
			ELSe
				ns <= init;
			END IF;
		WHEN OTHERS =>
				ns <= init;
	   END CASE;
END PROCESS;
 


r_count : counter 
	generic map(3)
	PORT map( 
		  clk, rst_count_r,  count_r , add_row_i);
	
	sel <= add_row_i;
		 
END contr;------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
ENTITY counter IS
generic ( n : integer := 8);
PORT ( 
      clk, rst,  en: in STD_LOGIC;
	  dout : out STD_LOGIC_VECTOR(n downto 0));
END counter;	  

ARCHITECTURE behavioral OF counter IS
signal i : std_logic_vector(n downto 0);
begin
PROCESS (clk)
	   BEGIN 
		 IF rising_edge (clk ) then 
		     IF ( rst = '1') then 
			 	i <= (others => '0'); 
		     ELSIF ( en = '1')then
		        i <= STD_LOGIC_VECTOR(UNSIGNED(i)+ 1);
		     END IF;
	     END IF;
END PROCESS;
dout <= i ; 
end behavioral;	 
-----------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.numeric_std.all; 

ENTITY SIGNED_ADD IS
generic ( n : integer := 31);
PORT (din1, din2 : in STD_LOGIC_VECTOR(n downto 0);
	  dout : out STD_LOGIC_VECTOR(n downto 0));
END SIGNED_ADD;	  

ARCHITECTURE behavioral OF SIGNED_ADD IS

signal out1, out2, d : std_logic_vector(n-1 downto 0);
signal en , se11, sel2, sign : std_logic;
--signal val : std_logic_vector(31 downto 0):= (others =>'0');
signal do : std_logic_vector(n-1 downto 0);


component twoscompliment IS
generic ( n : integer := 31);
PORT (en : in std_logic;
      din : in STD_LOGIC_VECTOR(n downto 0);
	    dout : out STD_LOGIC_VECTOR(n downto 0));
END component;

component mux_2 is
  generic (
		n : integer := 31
		);
  port (
        sel : in std_logic;
        a , b : in STD_LOGIC_VECTOR (n DOWNTO 0);
        c :out STD_LOGIC_VECTOR(n DOWNTO 0) 
         );
end component;

BEGIN
    
process(din1,din2)
 begin
  
    if ( din1(n) = din2(n) ) then
       en <= '0';
       se11 <= '0'; -- din1
       sel2 <= '1'; -- din2
       sign <= din1(n);
    ELSif (din1(n-1 downto 0) > din2(n-1 downto 0)) then
       en <= '1';
       se11 <= '0'; -- din1
       sel2 <= '1'; -- din2
       sign <= din1(n);
    else
       en <= '1';
       se11 <= '1'; -- din1
       sel2 <= '0'; -- din2
       sign <= din2(n);
    end if;
	
 end process;
 
 comp : twoscompliment 
	generic map (n-1)
    PORT MAP(en ,
      out2 ,
	    d);
	    
  mux0 :mux_2 
  generic map (n-1)
  port map(
        se11 ,
        din1(n-1 downto 0) , din2(n-1 downto 0),
        out1
         );
  mux1 :mux_2 
  generic map (n-1)
  port map(
        sel2 ,
        din1(n-1 downto 0) , din2(n-1 downto 0),
        out2
         );      
  do <= STD_LOGIC_VECTOR (UNSIGNED(out1) + UNSIGNED(d));
  dout  <= sign & do;
  
END behavioral;
------------------------------------------------------------------------------------------------------------------------------------------
---- convergence adding plate

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all; 

entity tb_S_CAP is

end tb_S_CAP;

architecture tb of tb_S_CAP is 

component S_CAP is
	GENERIC(
      n : INTEGER := 16
        );
	port (clk, rst, run : in std_logic;
		out_reg : out std_logic;
        dinF , dinI ,dinG, dinO: in STD_LOGIC_VECTOR (32*n-1 DOWNTO 0);
        doutF, doutI, doutG, doutO :out std_logic_vector(31 downto 0)
        );
END component;	

signal 	clk, rst, run :  std_logic := '1';
signal  out_reg :  std_logic;
signal  dinF , dinI ,dinG, dinO: STD_LOGIC_VECTOR (511 DOWNTO 0);
signal  doutF, doutI, doutG, doutO : std_logic_vector(31 downto 0);

begin 

clk <= not clk after 1 ns;
rst <= '0' after 10 ns;
run <= '0' after 5 ns, '1' after 15 ns, '0' after 17 ns, '1' after 46 ns, '0' after 51 ns;

dinF <= "00000000000000000000010000000000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000","00000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000" after 49 ns;
dinI <= "00000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000";
dinG <= "00000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000";
dinO <= "00000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001000000000000000";


cap :S_CAP
	GENERIC map( 16 )
	port map(clk, rst, run ,
		out_reg ,
        dinF , dinI ,dinG, dinO,
        doutF, doutI, doutG, doutO
        );

end tb;