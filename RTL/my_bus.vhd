LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY my_bus IS
	GENERIC (n : INTEGER := 4;
			cs : INTEGER := 15;
			ns : INTEGER := 4);
	PORT ( data_in_mapf, data_in_mapi,data_in_mapo,data_in_mapg : IN STD_LOGIC_VECTOR(cs*32-1 DOWNTO 0);
		   data_out_mapf, data_out_mapi,data_out_mapo,data_out_mapg : OUT STD_LOGIC_VECTOR (ns*n*32-1 DOWNTO 0));
END my_bus;

ARCHITECTURE behavioural OF my_bus IS
	SIGNAL concat : std_logic_vector (((ns*n)-cs)*32 downto 0);
BEGIN
	concat <= (others =>'0');
	
	PROCESS (data_in_mapf, data_in_mapi,data_in_mapo,data_in_mapg)
	BEGIN
		IF (ns*n) = cs THEN
			data_out_mapf<= data_in_mapf;
			data_out_mapi<= data_in_mapi;
			data_out_mapo<= data_in_mapo;
			data_out_mapg<= data_in_mapg;
		ELSE
			data_out_mapf<= data_in_mapf& concat(((ns*n)-cs)*32-1 downto 0);
			data_out_mapi<= data_in_mapi& concat(((ns*n)-cs)*32-1 downto 0);
			data_out_mapo<= data_in_mapo& concat(((ns*n)-cs)*32-1 downto 0);
			data_out_mapg<= data_in_mapg& concat(((ns*n)-cs)*32-1 downto 0);
		END IF;
	END PROCESS;
end	behavioural;

-------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY tb_my_bus IS
	
END tb_my_bus;
ARCHITECTURE tb OF tb_my_bus IS

component my_bus IS
	GENERIC (n : INTEGER := 4;
			cs : INTEGER := 15;
			ns : INTEGER := 4);
	PORT ( data_in_mapf, data_in_mapi,data_in_mapo,data_in_mapg : IN STD_LOGIC_VECTOR(cs*32-1 DOWNTO 0);
		   data_out_mapf, data_out_mapi,data_out_mapo,data_out_mapg : OUT STD_LOGIC_VECTOR (ns*n*32-1 DOWNTO 0));
END component;

signal data_in_mapf, data_in_mapi,data_in_mapo,data_in_mapg : STD_LOGIC_VECTOR(15*32-1 DOWNTO 0) := "010100111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111010100111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100";
signal data_out_mapf, data_out_mapi,data_out_mapo,data_out_mapg : STD_LOGIC_VECTOR (4*4*32-1 DOWNTO 0);

begin

bs : my_bus 
	GENERIC map ( 4, 15, 4)
	PORT map ( data_in_mapf, data_in_mapi,data_in_mapo,data_in_mapg ,
		   data_out_mapf, data_out_mapi,data_out_mapo,data_out_mapg );


end tb;