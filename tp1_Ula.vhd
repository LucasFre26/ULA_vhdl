LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY tp1_Ula IS
    PORT (
        a_in, b_in   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        op_sel       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        c_in         : IN  STD_LOGIC;
        r_out        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        c_out, z_out, v_out : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE arch OF tp1_Ula IS
    SIGNAL aux          	: STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL aux_soma     	: INTEGER RANGE 0 TO 255;
    SIGNAL aux_sub      	: INTEGER RANGE 0 TO 255;
    SIGNAL carry_in     	: STD_LOGIC;
    
BEGIN

    aux_soma	<= TO_INTEGER(UNSIGNED(a_in)) + TO_INTEGER(UNSIGNED(b_in));
    aux_sub  	<= TO_INTEGER(UNSIGNED(a_in)) - TO_INTEGER(UNSIGNED(b_in));
    
    -- Carry_in pra ADDC, SUBC E RRC
    carry_in <= '1' WHEN ((op_sel = "0101") AND (c_in = '1')) OR ((op_sel = "0111") AND (c_in = '1')) OR ((op_sel = "1011") AND (c_in = '1')) ELSE '0';

    WITH op_sel SELECT
        aux <=  '0' & (a_in AND b_in) WHEN "0000",                                 -- AND
                '0' & (a_in OR b_in) WHEN "0001",                                  -- OR
                '0' & (a_in XOR b_in) WHEN "0010",                                 -- XOR
                '0' & NOT a_in WHEN "0011",                                        -- NOT
                '0' & STD_LOGIC_VECTOR(TO_UNSIGNED(aux_soma , 8)) WHEN "0100",     -- ADD s/carry 
                ('0' & a_in) + ('0' & b_in) + ('0' & carry_in) WHEN "0101",        -- ADDC 
                '0' & STD_LOGIC_VECTOR(TO_UNSIGNED(aux_sub, 8)) WHEN "0110",       -- SUB s/carry 
                ('0' & a_in) - ('0' & b_in) - ('0' & carry_in) WHEN "0111",        -- SUBC 
                
                -- IMPLEMENTAR OUTRAS OPERACOES
                '0' & (a_in OR b_in) WHEN "1000",                                  -- RL
                '0' & (a_in XOR b_in) WHEN "1001",                                 -- RR
                '0' & NOT a_in WHEN "1010",                                        -- RLC
                '0' & a_in + b_in WHEN "1011",                                     -- RRC    
                ('0' & a_in) + ('0' & b_in) WHEN "1100",                           -- SLL
                '0' & a_in - b_in WHEN "1101",                                     -- SRL
                ('0' & a_in) - ('0' & b_in) WHEN "1110",                           -- SRA    
                ('0' & a_in) - ('0' & b_in) WHEN "1111";                           -- PASS_B        
                                     
    r_out <= aux(7 DOWNTO 0);
    c_out <= aux(8);
    
    -- Overflow operacoes de Soma/Subtracao (com/sem carry)
    v_out <= '1' WHEN (((op_sel="0100" OR op_sel="0101") AND (a_in(0)='0' AND b_in(0)='0' AND aux(0)='1')) OR
						((op_sel="0100" OR op_sel="0101") AND (a_in(0)='1' AND b_in(0)='1' AND aux(0)='0')) OR
							((op_sel="0110" OR op_sel="0111") AND (a_in(0)='0' AND b_in(0)='1' AND aux(0)='1')) OR
							((op_sel="0110" OR op_sel="0111") AND (a_in(0)='1' AND b_in(0)='0' AND aux(0)='0')));
							
    z_out <= '1' WHEN aux(7 DOWNTO 0) = "00000000" ELSE '0';
    
END arch;