LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY MAP_n_m IS
	GENERIC( n : INTEGER := 3; --- number of dimension
	  m : INTEGER := 8; ---D(0)
	  num_map1 : INTEGER := 100; --- col / d0
	  num_cap1 : INTEGER := 10;  --- col / d0**2
	  num_cap2 : INTEGER := 1;  --- col / d0**3
	  num_cap3 : INTEGER := 1;  --- col / d0**4
	  num_cap4 : INTEGER := 1;  --- col / d0**5
	  num_cap5 : INTEGER := 1;  --- col / d0**6
	  num_cap6 : INTEGER := 1;  --- col / d0**7
	  addr_col  : INTEGER := 10; -- required bits to store 16 elements
	  col : INTEGER := 1023;
	  addr_row  : INTEGER := 4; -- required bits to store 16 elements
      row : INTEGER :=12 );-- = n
	PORT ( clk,  rst,  run : IN STD_LOGIC ;
      regout : OUT STD_LOGIC;
	  din : IN STD_LOGIC_VECTOR(16*num_map1 -1 DOWNTO 0);
	  doutF, doutI, doutG, doutO : OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
END MAP_n_m;

ARCHITECTURE behavioural OF MAP_n_m IS
	component S_MAP1 IS
		GENERIC( n : INTEGER := 12;
				addr_col  : integer := 10; -- required bits to store 16 elements
				col : integer := 1023; --- = H
				addr_row  : integer := 4; -- required bits to store 16 elements
				row : integer :=12 );-- = n
		PORT ( clk, rst, run: in std_logic;
			  reg_out : out std_logic;
			  din :in std_logic_vector(15 downto 0);
			  df , do , dc ,di : out std_logic_vector (31 downto 0) );
	END component;

	component S_CAP is
		GENERIC( n : INTEGER := 16 );
		port ( clk, rst, run : in std_logic;
			out_reg : out std_logic;
			dinF , dinI ,dinG, dinO: in STD_LOGIC_VECTOR (32*n-1 DOWNTO 0);
			doutF, doutI, doutG, doutO :out std_logic_vector(31 downto 0) );
	end component;

	component my_bus IS
		GENERIC (n : INTEGER := 16;
				cs : INTEGER := 16;
				ns : INTEGER := 16);
		PORT ( data_in_mapf, data_in_mapi,data_in_mapo,data_in_mapg : IN STD_LOGIC_VECTOR(cs*32-1 DOWNTO 0);
			   data_out_mapf, data_out_mapi,data_out_mapo,data_out_mapg : OUT STD_LOGIC_VECTOR (ns*n*32-1 DOWNTO 0));
	END component;


	signal data_out_mapf, data_out_mapi,data_out_mapo,data_out_mapg : std_logic_vector ((num_map1*32)-1 DOWNTO 0);
	signal data_out_mapf1, data_out_mapi1,data_out_mapo1,data_out_mapg1 : std_logic_vector ((num_cap1*32)-1 DOWNTO 0);
	signal data_out_mapf2, data_out_mapi2,data_out_mapo2,data_out_mapg2 : std_logic_vector ((num_cap2*32)-1 DOWNTO 0);
	signal data_out_mapf3, data_out_mapi3,data_out_mapo3,data_out_mapg3 : std_logic_vector ((num_cap3*32)-1 DOWNTO 0);
	signal data_out_mapf4, data_out_mapi4,data_out_mapo4,data_out_mapg4 : std_logic_vector ((num_cap4*32)-1 DOWNTO 0);
	signal data_out_mapf5, data_out_mapi5,data_out_mapo5,data_out_mapg5 : std_logic_vector ((num_cap5*32)-1 DOWNTO 0);
	signal data_out_mapf6, data_out_mapi6,data_out_mapo6,data_out_mapg6 : std_logic_vector ((num_cap6*32)-1 DOWNTO 0);
	signal data_in_mapf1, data_in_mapi1,data_in_mapo1,data_in_mapg1 : std_logic_vector ((num_cap1*m*32)-1 DOWNTO 0);
	signal data_in_mapf2, data_in_mapi2,data_in_mapo2,data_in_mapg2 : std_logic_vector ((num_cap2*m*32)-1 DOWNTO 0);
	signal data_in_mapf3, data_in_mapi3,data_in_mapo3,data_in_mapg3 : std_logic_vector ((num_cap3*m*32)-1 DOWNTO 0);
	signal data_in_mapf4, data_in_mapi4,data_in_mapo4,data_in_mapg4 : std_logic_vector ((num_cap4*m*32)-1 DOWNTO 0);
	signal data_in_mapf5, data_in_mapi5,data_in_mapo5,data_in_mapg5 : std_logic_vector ((num_cap5*m*32)-1 DOWNTO 0);
	signal data_in_mapf6, data_in_mapi6,data_in_mapo6,data_in_mapg6 : std_logic_vector ((num_cap6*m*32)-1 DOWNTO 0);
	signal data_in_mapf_f, data_in_mapi_f,data_in_mapo_f,data_in_mapg_f : std_logic_vector ((m*32)-1 DOWNTO 0);

	signal reg_out : std_logic_vector (6 downto 0) ;
	signal reg_out0 : std_logic_vector (num_map1-1 downto 0) ;
	signal reg_out1 : std_logic_vector (num_cap1-1 downto 0) ;
	signal reg_out2 : std_logic_vector (num_cap2-1 downto 0) ;
	signal reg_out3 : std_logic_vector (num_cap3-1 downto 0) ;
	signal reg_out4 : std_logic_vector (num_cap4-1 downto 0) ;
	signal reg_out5 : std_logic_vector (num_cap5-1 downto 0) ;
	signal reg_out6 : std_logic_vector (num_cap6-1 downto 0) ;
BEGIN
		reg_out(0) <= reg_out0(0);
		reg_out(1) <= reg_out1(0);
		reg_out(2) <= reg_out2(0);
		reg_out(3) <= reg_out3(0);
		reg_out(4) <= reg_out4(0);
		reg_out(5) <= reg_out5(0);
		reg_out(6) <= reg_out6(0);

		MAP_1s: FOR I IN 1 TO num_map1 GENERATE
		    MAP1 :  S_MAP1
		        GENERIC MAP( m,
		                    addr_col,
		                    col,
							addr_row,
		                    row )
					PORT MAP (  
			            clk,  rst,  run, reg_out0(I-1),
						din(((I*16)-1) DOWNTO ((I-1)*16)),  
						data_out_mapf((I*32)-1 DOWNTO (I-1)*32),data_out_mapi((I*32)-1 DOWNTO (I-1)*32),
						data_out_mapo((I*32)-1 DOWNTO (I-1)*32),data_out_mapg((I*32)-1 DOWNTO (I-1)*32)
						);
			END GENERATE MAP_1s;
								
		bus_map1_to_map2 : my_bus 
			GENERIC map( m,
					num_map1,
					num_cap1)
			PORT map( data_out_mapf, data_out_mapi,data_out_mapo,data_out_mapg,
				   data_in_mapf1, data_in_mapi1,data_in_mapo1,data_in_mapg1);
				   				   
		CAP_1s: FOR I IN 1 TO num_cap1 GENERATE
		    CAP_1 : S_CAP 
				GENERIC MAP (m)
					PORT MAP( 
						clk,  rst,  reg_out(0),  
						reg_out1(I-1),  
						data_in_mapf1((I*32*m)-1 DOWNTO (I-1)*32*m), data_in_mapi1((I*32*m)-1 DOWNTO (I-1)*32*m),
						data_in_mapo1((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapg1((I*32*m)-1 DOWNTO (I-1)*32*m),  
						data_out_mapf1((I*32)-1 DOWNTO (I-1)*32), data_out_mapi1((I*32)-1 DOWNTO (I-1)*32),
						data_out_mapo1((I*32)-1 DOWNTO (I-1)*32),data_out_mapg1((I*32)-1 DOWNTO (I-1)*32)
						);
			END GENERATE CAP_1s;
	
		bus_map2_to_map3 : my_bus 
			GENERIC map( m,
					num_cap1,
					num_cap2)
			PORT map( data_out_mapf1, data_out_mapi1,data_out_mapo1,data_out_mapg1,
				   data_in_mapf2, data_in_mapi2,data_in_mapo2,data_in_mapg2);
				   			   
		CAP_2s: FOR I IN 1 TO num_cap2 GENERATE
		    CAP_2 : S_CAP 
				GENERIC MAP (m)
					PORT MAP( 
						clk,  rst,  reg_out(1),  
						reg_out2(I-1),  
						data_in_mapf2((I*32*m)-1 DOWNTO (I-1)*32*m), data_in_mapi2((I*32*m)-1 DOWNTO (I-1)*32*m),
						data_in_mapo2((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapg2((I*32*m)-1 DOWNTO (I-1)*32*m),  
						data_out_mapf2((I*32)-1 DOWNTO (I-1)*32), data_out_mapi2((I*32)-1 DOWNTO (I-1)*32),
						data_out_mapo2((I*32)-1 DOWNTO (I-1)*32),data_out_mapg2((I*32)-1 DOWNTO (I-1)*32)
						);
			END GENERATE CAP_2s;	
	
		bus_map3_to_map4 : my_bus 
			GENERIC map( m,
					num_cap2,
					num_cap3)
			PORT map( data_out_mapf2, data_out_mapi2,data_out_mapo2,data_out_mapg2,
				   data_in_mapf3, data_in_mapi3,data_in_mapo3,data_in_mapg3);
				   				   
		CAP_3s: FOR I IN 1 TO num_cap3 GENERATE
		    CAP_3 : S_CAP 
				GENERIC MAP (m)
					PORT MAP( 
						clk,  rst,  reg_out(2),  
						reg_out3(I-1),  
						data_in_mapf3((I*32*m)-1 DOWNTO (I-1)*32*m), data_in_mapi3((I*32*m)-1 DOWNTO (I-1)*32*m),
						data_in_mapo3((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapg3((I*32*m)-1 DOWNTO (I-1)*32*m),  
						data_out_mapf3((I*32)-1 DOWNTO (I-1)*32), data_out_mapi3((I*32)-1 DOWNTO (I-1)*32),
						data_out_mapo3((I*32)-1 DOWNTO (I-1)*32),data_out_mapg3((I*32)-1 DOWNTO (I-1)*32)
						);
			END GENERATE CAP_3s;
	
		bus_map4_to_map5 : my_bus 
			GENERIC map( m,
					num_cap3,
					num_cap4)
			PORT map( data_out_mapf3, data_out_mapi3,data_out_mapo3,data_out_mapg3,
				   data_in_mapf4, data_in_mapi4,data_in_mapo4,data_in_mapg4);				   
				   
		CAP_4s: FOR I IN 1 TO num_cap4 GENERATE
		    CAP_4 : S_CAP 
				GENERIC MAP (m)
					PORT MAP( 
						clk,  rst,  reg_out(3),  
						reg_out4(I-1),  
						data_in_mapf4((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapi4((I*32*m)-1 DOWNTO (I-1)*32*m),
						data_in_mapo4((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapg4((I*32*m)-1 DOWNTO (I-1)*32*m),  
						data_out_mapf4((I*32)-1 DOWNTO (I-1)*32),data_out_mapi4((I*32)-1 DOWNTO (I-1)*32),
						data_out_mapo4((I*32)-1 DOWNTO (I-1)*32),data_out_mapg4((I*32)-1 DOWNTO (I-1)*32)
						);
			END GENERATE CAP_4s;			
	
		bus_map5_to_map6 : my_bus 
			GENERIC map( m,
					num_cap4,
					num_cap5)
			PORT map( data_out_mapf4, data_out_mapi4,data_out_mapo4,data_out_mapg4,
				   data_in_mapf5, data_in_mapi5,data_in_mapo5,data_in_mapg5);
				   				   
		CAP_5s: FOR I IN 1 TO num_cap5 GENERATE
		    CAP_5 : S_CAP 
				GENERIC MAP (m)
					PORT MAP( 
						clk,  rst,  reg_out(4),  
						reg_out5(I-1),  
						data_in_mapf5((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapi5((I*32*m)-1 DOWNTO (I-1)*32*m),
						data_in_mapo5((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapg5((I*32*m)-1 DOWNTO (I-1)*32*m),  
						data_out_mapf5((I*32)-1 DOWNTO (I-1)*32),data_out_mapi5((I*32)-1 DOWNTO (I-1)*32),
						data_out_mapo5((I*32)-1 DOWNTO (I-1)*32),data_out_mapg5((I*32)-1 DOWNTO (I-1)*32)
						);
			END GENERATE CAP_5s;			
	
		bus_map6_to_map7 : my_bus 
			GENERIC map( m,
					num_cap5,
					num_cap6)
			PORT map( data_out_mapf5, data_out_mapi5,data_out_mapo5,data_out_mapg5,
				   data_in_mapf6, data_in_mapi6,data_in_mapo6,data_in_mapg6);
				   				   
		CAP_6s: FOR I IN 1 TO num_cap6 GENERATE
		    CAP_6 : S_CAP 
				GENERIC MAP (m)
					PORT MAP( 
						clk,  rst,  reg_out(5),  
						reg_out6(I-1),  
						data_in_mapf6((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapi6((I*32*m)-1 DOWNTO (I-1)*32*m),
						data_in_mapo6((I*32*m)-1 DOWNTO (I-1)*32*m),data_in_mapg6((I*32*m)-1 DOWNTO (I-1)*32*m),  
						data_out_mapf6((I*32)-1 DOWNTO (I-1)*32),data_out_mapi6((I*32)-1 DOWNTO (I-1)*32),
						data_out_mapo6((I*32)-1 DOWNTO (I-1)*32),data_out_mapg6((I*32)-1 DOWNTO (I-1)*32)
						);
			END GENERATE CAP_6s;				
	
	data_in_mapf_f <= data_in_mapf1 when n = 2 else
					  data_in_mapf2 when n = 3 else
					  data_in_mapf3 when n = 4 else
					  data_in_mapf4 when n = 5 else
					  data_in_mapf5 when n = 6 else
					  data_in_mapf6 when n = 7 else
					  (others => '0');
	data_in_mapi_f <= data_in_mapi1 when n = 2 else
					  data_in_mapi2 when n = 3 else
					  data_in_mapi3 when n = 4 else
					  data_in_mapi4 when n = 5 else
					  data_in_mapi5 when n = 6 else
					  data_in_mapi6 when n = 7 else
					  (others => '0');
	data_in_mapo_f <= data_in_mapo1 when n = 2 else
					  data_in_mapo2 when n = 3 else
					  data_in_mapo3 when n = 4 else
					  data_in_mapo4 when n = 5 else
					  data_in_mapo5 when n = 6 else
					  data_in_mapo6 when n = 7 else
					  (others => '0');
	data_in_mapg_f <= data_in_mapo1 when n = 2 else
					  data_in_mapo2 when n = 3 else
					  data_in_mapo3 when n = 4 else
					  data_in_mapo4 when n = 5 else
					  data_in_mapo5 when n = 6 else
					  data_in_mapo6 when n = 7 else
					  (others => '0');
					  
	CAP_f : S_CAP 
				GENERIC MAP (m)
					PORT MAP( clk,  rst,  reg_out(n-1),  
						regout,  
						data_in_mapf_f, data_in_mapi_f,data_in_mapo_f,data_in_mapg_f,   
						doutF, doutI, doutG, doutO );	
end	behavioural;
--------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY tb_MAP_n_m IS
END tb_MAP_n_m;
architecture tb of tb_MAP_n_m is 
	component MAP_n_m IS
		GENERIC( n : INTEGER := 3; --- number of dimension
		  m : INTEGER := 8; ---D(0)
		  num_map1 : INTEGER := 100; --- col / d0
		  num_cap1 : INTEGER := 10;  --- col / d0**2
		  num_cap2 : INTEGER := 1;  --- col / d0**3
		  num_cap3 : INTEGER := 1;  --- col / d0**4
		  num_cap4 : INTEGER := 1;  --- col / d0**5
		  num_cap5 : INTEGER := 1;  --- col / d0**6
		  num_cap6 : INTEGER := 1;  --- col / d0**7
		  addr_col  : INTEGER := 10; -- required bits to store 16 elements
		  col : INTEGER := 1023;
		  addr_row  : INTEGER := 4; -- required bits to store 16 elements
		  row : INTEGER :=12 );-- = n
		PORT ( clk,  rst,  run : IN STD_LOGIC ;
		  regout : OUT STD_LOGIC;
		  din : IN STD_LOGIC_VECTOR(16*num_map1 -1 DOWNTO 0);
		  doutF, doutI, doutG, doutO : OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END component;

	signal clk,  rst,  run : STD_LOGIC := '1';
	signal regout : STD_LOGIC;
	signal din : STD_LOGIC_VECTOR(16*89 -1 DOWNTO 0):= "10101010101010101010101001000000000001010101010101010010101001010101010000000000000000000000000000000000000101001010101010010101001001010101010101010101010101010101010010000000000010101010101010100101010010101010100000000000000000000000000000000000001010010101010100101010010010101010101010101010101010101010100100000000000101010101010101001010100101010101000000000000000000000000000000000000010100101010101001010100100101010101010101010101010101010101001000000000001010101010101010010101001010101010000000000000000000000000000000000000101001010101010010101001001010101010101010101010101010101010010000000000010101010101010100101010010101010100000000000000000000000000000000000001010010101010100101010010010101010101010101010101010101010100100000000000101010101010101001010100101010101000000000000000000000000000000000000010100101010101001010100100101010101010101010101010101010101001000000000001010101010101010010101001010101010000000000000000000000000000000000000101001010101010010101001001010101010101010101010101010101010010000000000010101010101010100101010010101010100000000000000000000000000000000000001010010101010100101010010010101010101010101010101010101010100100000000000101010101010101001010100101010101000000000000000000000000000000000000010100101010101001010100100101010101010101010101010101010101001000000000001010101010101010010101001010101010000000000000000000000000000000000000101001010101010010101001001010";
	signal doutF, doutI, doutG, doutO : STD_LOGIC_VECTOR (31 DOWNTO 0);
begin 
	clk <= not clk after 1 ns;
	rst <= '0' after 15 ns;
	run <= '1' after 17 ns, '0' after 19 ns;
	my_mapn : MAP_n_m 
		GENERIC map( 4, 6 ,89, 15,3, 1, 1, 1,1,10,1023, 4,12 )
		PORT map(clk,  rst,  run,
		  regout ,
		  din ,
		  doutF, doutI, doutG, doutO );
end tb;