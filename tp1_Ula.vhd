LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
----------------------------------------------------------------------------------
ENTITY tp1_Ula IS
    PORT (
		--ENTRADAS
        a_in		: IN  STD_LOGIC_VECTOR(7 DOWNTO 0); --ENTRADA 'A'
        b_in   		: IN  STD_LOGIC_VECTOR(7 DOWNTO 0); --ENTRADA 'B'
        c_in        : IN  STD_LOGIC;					--CARRY_IN
        op_sel      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); --SELETOR DE OPERAÇÃO					
        
        --SAÍDAS
        r_out       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);	--RESULTADO
        c_out		: OUT STD_LOGIC;					--CARRY OUT
        z_out       : OUT STD_LOGIC;					--SERÁ '1' QUANDO A SAÍDA FOR '0'
        v_out 		: OUT STD_LOGIC						--SERÁ '1' QUANDO HOUVER OVERFLOW
    );
END ENTITY;
----------------------------------------------------------------------------------
ARCHITECTURE arch OF tp1_Ula IS
    SIGNAL aux          	: STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL aux_soma     	: INTEGER RANGE 0 TO 255;
    SIGNAL aux_sub      	: INTEGER RANGE 0 TO 255;
    SIGNAL carry_in     	: STD_LOGIC;
    
BEGIN
    aux_soma	<= TO_INTEGER(UNSIGNED(a_in)) + TO_INTEGER(UNSIGNED(b_in));
    aux_sub  	<= TO_INTEGER(UNSIGNED(a_in)) - TO_INTEGER(UNSIGNED(b_in));
    
    -- CARRY_IN PARA ADDC, SUBC E RRC
    carry_in <= '1' WHEN ((op_sel = "0100") AND (c_in = '1')) OR ((op_sel = "0101") AND (c_in = '1')) OR ((op_sel = "0110") AND (c_in = '1')) OR ((op_sel = "0111") AND (c_in = '1')) ELSE '0';
    		
    -- SELETOR DE OPERAÇÕES
    WITH op_sel SELECT
        aux <=  '0' & (a_in AND b_in) 								WHEN "0000", --AND
                '0' & (a_in OR b_in) 								WHEN "0001", --OR
                '0' & (a_in XOR b_in) 								WHEN "0010", --XOR
                '0' & NOT a_in 										WHEN "0011", --NOT
                '0' & STD_LOGIC_VECTOR(TO_UNSIGNED(aux_soma , 8)) 	WHEN "0100", --ADD SEM CARRY 
                ('0' & a_in) + ('0' & b_in) + ('0' & carry_in) 		WHEN "0101", --ADD COM CARRY
                '0' & STD_LOGIC_VECTOR(TO_UNSIGNED(aux_sub, 8)) 	WHEN "0110", --SUB SEM CARRY
                ('0' & a_in) - ('0' & b_in) - ('0' & carry_in) 		WHEN "0111", --SUB COM CARRY
                a_in(7) & a_in(6 downto 0) & a_in(7) 				WHEN "1000", --RL
                a_in(0) & a_in(0) & a_in(7 downto 1)				WHEN "1001", --RR
                a_in(7) & a_in(6 downto 0) & carry_in 				WHEN "1010", --RLC
                a_in(0) & carry_in & a_in(7 downto 1)				WHEN "1011", --RRC    
                a_in(7) & a_in(6 downto 0) & '0' 					WHEN "1100", --SLL
                a_in(0) & '0' & a_in(7 downto 1) 					WHEN "1101", --SRL
                a_in(0) & a_in(7) & a_in(7 downto 1)				WHEN "1110", --SRA    
				'0' & b_in											WHEN "1111"; --PASS_B                                    
    r_out <= aux(7 DOWNTO 0);
    c_out <= aux(8);
    
    --OVERFLOW PARA OPERAÇÕES DE SUM/SUB (COM/SEM CARRY) de Soma/Subtracao (com/sem carry)
    v_out <= '1' WHEN 	(
						((op_sel="0100" OR op_sel="0101") AND (a_in(0)='0' AND b_in(0)='0' AND aux(0)='1')) OR --SUM DE (POSITIVO + POSITIVO = NEGATIVO)
						((op_sel="0100" OR op_sel="0101") AND (a_in(0)='1' AND b_in(0)='1' AND aux(0)='0')) OR --SUM DE (NEGATIVO + NEGATIVO = POSITIVO)
						((op_sel="0110" OR op_sel="0111") AND (a_in(0)='0' AND b_in(0)='1' AND aux(0)='1')) OR --SUB DE (POSITIVO - NEGATIVO = NEGATIVO)
						((op_sel="0110" OR op_sel="0111") AND (a_in(0)='1' AND b_in(0)='0' AND aux(0)='0'))	   --SUB DE (NEGATIVO - POSITIVO = POSITIVO)
						);
							
	--SAÍDA DE ZERO, SERÁ '1' QUANDO O RESULTADO FOR ZERO								
    z_out <= '1' WHEN aux(7 DOWNTO 0) = "00000000" ELSE '0';
    
END arch;