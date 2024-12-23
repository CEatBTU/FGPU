-- The init_alu_en_ram is a memory that contains ...
-- The memory has 2**(PHASE_W+N_WF_CU_W) words, each one of CV_size bits (64x8).
-- When the start signal is high, the memory is initialized according to the WG size and number of WFs.
-- In the initializtion phase, the first (#WFs-1) words are initialized with all bits set to '1'.
-- For the last WF, if the WI are less than the size of a WF, the words are initialized with zeros.

-- libraries -------------------------------------------------------------------------------------------{{{
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library fgpu;
use fgpu.definitions.all;
use fgpu.components.all;
---------------------------------------------------------------------------------------------------------}}}
entity init_alu_en_ram is -- {{{
generic(
  N_RD_PORTS          : natural := 4
    -- number of CU
);
port(
  start               : in std_logic;
    -- start signal
  finish              : out std_logic;
    -- finish signal
  clear_finish        : in std_logic;
    -- input signal to clear finish flag
  wg_size             : in unsigned(N_WF_CU_W+WF_SIZE_W downto 0);
    -- WG size
  sch_rqst_n_WFs_m1   : in unsigned(N_WF_CU_W-1 downto 0);
    -- number of WFs in the WG to be scheduled
  rdData_alu_en       : out alu_en_vec_type(N_RD_PORTS-1 downto 0); -- level 3
    -- alu enable read data for each CU
  rdAddr_alu_en       : in alu_en_rdAddr_type(N_RD_PORTS-1 downto 0); -- level 1
    -- alu enable read address for each CU
  clk, nrst           : in std_logic
);
end entity; --}}}
architecture behavioural of init_alu_en_ram is

  -- signal definitions -----------------------------------------------------------------------------------{{{
  type st_alu_en_type is (idle, set_till_last_wf, check_last_wf);

  signal st_alu_en, st_alu_en_n           : st_alu_en_type;
    -- state of alu enable FSM
  signal alu_en_ram                       : alu_en_vec_type(2**(PHASE_W+N_WF_CU_W)-1 downto 0) := (others => (others => '0'));
    -- alu enable ram memory: 2**(PHASE_W+N_WF_CU_W) words of CV size bits
  signal wrData_alu_en, wrData_alu_en_n   : std_logic_vector(CV_SIZE-1 downto 0);
    -- alu enable ram write data
  signal wrAddr_alu_en, wrAddr_alu_en_n   : unsigned(PHASE_W+N_WF_CU_W downto 0);
    -- alu enable ram write address
  signal we_alu_en, we_alu_en_n           : std_logic;
    -- alu enable ram write enable
  signal alu_count, alu_count_n           : unsigned(WF_SIZE_W-1 downto 0);
    -- counter of number of WIs within a WF
  signal finish_n, finish_i               : std_logic;
  signal n_complete_wfs, n_complete_wfs_n : integer range 0 to 2**N_WF_CU_W;
    -- signal used to extract the number of WF within the WG
  signal rdData_alu_en_n                  : alu_en_vec_type(N_RD_PORTS-1 downto 0);
    -- alu enable read data
  ---------------------------------------------------------------------------------------------------------}}}

begin
  finish <= finish_i;

  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        rdData_alu_en   <= (others => (others => '0')); -- NOT NEEDED
        rdData_alu_en_n <= (others => (others => '0')); -- NOT NEEDED
      else
        rdData_alu_en <= rdData_alu_en_n;
        for i in 0 to N_RD_PORTS-1 loop
          rdData_alu_en_n(i) <= alu_en_ram(to_integer(rdAddr_alu_en(i)));
        end loop;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if we_alu_en = '1' then
        alu_en_ram(to_integer(wrAddr_alu_en(PHASE_W+N_WF_CU_W-1 downto 0))) <= wrData_alu_en;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        st_alu_en <= idle;
        we_alu_en <= '0';
        alu_count <= (others => '0');
        finish_i <= '0';
        wrAddr_alu_en <= (others => '0');
        wrData_alu_en <= (others => '0');
        n_complete_wfs <= 0;
      else
        st_alu_en <= st_alu_en_n;
        wrAddr_alu_en <= wrAddr_alu_en_n;
        wrData_alu_en <= wrData_alu_en_n;
        we_alu_en <= we_alu_en_n;
        alu_count <= alu_count_n;
        finish_i <= finish_n;
        n_complete_wfs <= n_complete_wfs_n;
        if clear_finish = '1' then
          finish_i <= '0';
        end if;
      end if;
    end if;
  end process;

  process(start , st_alu_en, wrData_alu_en, wrAddr_alu_en, sch_rqst_n_WFs_m1, alu_count, wg_size, finish_i, wrAddr_alu_en_n, n_complete_wfs)
  begin
    st_alu_en_n <= st_alu_en;
    wrData_alu_en_n <= wrData_alu_en;
    wrAddr_alu_en_n <= wrAddr_alu_en;
    we_alu_en_n <= '0';
    alu_count_n <= alu_count;
    finish_n <= finish_i;
    n_complete_wfs_n <= n_complete_wfs;

    case st_alu_en is

      when idle =>
        if start = '1' then
          st_alu_en_n <= set_till_last_wf;
          wrAddr_alu_en_n <= (others => '1');
          alu_count_n <= (others => '0');
          finish_n <= '0';
          if to_integer(wg_size(WF_SIZE_W-1 downto 0)) = 0 then
            n_complete_wfs_n <= to_integer(sch_rqst_n_WFs_m1) + 1;
          else
            n_complete_wfs_n <= to_integer(sch_rqst_n_WFs_m1);
          end if;
        end if;

      when set_till_last_wf =>
        wrAddr_alu_en_n <= wrAddr_alu_en + 1;
        if wrAddr_alu_en_n(PHASE_W+N_WF_CU_W downto PHASE_W) /= n_complete_wfs then
          wrData_alu_en_n <= (others => '1');
          we_alu_en_n <= '1';
        else
          if to_integer(wg_size(WF_SIZE_W-1 downto 0)) = 0 then
            st_alu_en_n <= idle;
            finish_n <= '1';
          else
            st_alu_en_n <= check_last_wf;
          end if;
        end if;

      when check_last_wf =>
        wrAddr_alu_en_n(PHASE_W-1 downto 0) <= alu_count(PHASE_W+CV_W-1 downto CV_W);
        if to_integer(alu_count) < wg_size(WF_SIZE_W-1 downto 0) then
          wrData_alu_en_n(to_integer(alu_count(CV_W-1 downto 0))) <= '1';
        else
          wrData_alu_en_n(to_integer(alu_count(CV_W-1 downto 0))) <= '0';
        end if;
        if to_integer(alu_count(CV_W-1 downto 0)) = CV_SIZE-1 then
          we_alu_en_n <= '1';
        end if;
        alu_count_n <= alu_count + 1;
        if to_integer(alu_count) = WF_SIZE-1 then
          st_alu_en_n <= idle;
          finish_n <= '1';
        end if;

    end case;
  end process;

end architecture;
