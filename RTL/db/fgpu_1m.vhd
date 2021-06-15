-- libraries --------------------------------------------------------------------------------- {{{
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library fgpu;
use fgpu.definitions.all;
use fgpu.components.all;
------------------------------------------------------------------------------------------------- }}}

entity fgpu_1m is
  -- ports {{{
  port (
    -- Users to add ports here
    -- User ports ends

    -- Do not modify the ports beyond this line

    -- zulberti
    axi_clk     : in std_logic;
    axi_aresetn : in std_logic;

    -- Ports of Axi Slave Bus Interface S0 {{{
    s_awaddr  : in std_logic_vector(15 downto 0);
    s_awprot  : in std_logic_vector(2 downto 0);
    s_awvalid  : in std_logic;
    s_awready  : out std_logic;
    s_wdata    : in std_logic_vector(31 downto 0);
    s_wstrb    : in std_logic_vector(3 downto 0);
    s_wvalid  : in std_logic;
    s_wready  : out std_logic;
    s_bresp    : out std_logic_vector(1 downto 0);
    s_bvalid  : out std_logic;
    s_bready  : in std_logic;
    s_araddr  : in std_logic_vector(15 downto 0);
    s_arprot  : in std_logic_vector(2 downto 0);
    s_arvalid  : in std_logic;
    s_arready  : out std_logic;
    s_rdata    : out std_logic_vector(31 downto 0);
    s_rresp    : out std_logic_vector(1 downto 0);
    s_rvalid  : out std_logic;
    s_rready  : in std_logic;
    -- }}}

    -- Ports of Axi Master Bus Interface M0 {{{
    m0_awid    : out std_logic;
    m0_awaddr  : out std_logic_vector(31 downto 0);
    m0_awlen  : out std_logic_vector(7 downto 0);
    m0_awsize  : out std_logic_vector(2 downto 0);
    m0_awburst  : out std_logic_vector(1 downto 0);
    m0_awlock  : out std_logic;
    m0_awcache  : out std_logic_vector(3 downto 0);
    m0_awprot  : out std_logic_vector(2 downto 0);
    m0_awqos  : out std_logic_vector(3 downto 0);
    m0_awvalid  : out std_logic;
    m0_awready  : in std_logic;
    m0_wdata  : out std_logic_vector(63 downto 0);
    m0_wstrb  : out std_logic_vector(7 downto 0);
    m0_wlast  : out std_logic;
    m0_wvalid  : out std_logic;
    m0_wready  : in std_logic;
    m0_bid    : in std_logic;
    m0_bresp  : in std_logic_vector(1 downto 0);
    m0_bvalid  : in std_logic;
    m0_bready  : out std_logic;
    m0_arid    : out std_logic;
    m0_araddr  : out std_logic_vector(31 downto 0);
    m0_arlen  : out std_logic_vector(7 downto 0);
    m0_arsize  : out std_logic_vector(2 downto 0);
    m0_arburst  : out std_logic_vector(1 downto 0);
    m0_arlock  : out std_logic;
    m0_arcache  : out std_logic_vector(3 downto 0);
    m0_arprot  : out std_logic_vector(2 downto 0);
    m0_arqos  : out std_logic_vector(3 downto 0);
    m0_arvalid  : out std_logic;
    m0_arready  : in std_logic;
    m0_rid    : in std_logic;
    m0_rdata  : in std_logic_vector(63 downto 0);
    m0_rresp  : in std_logic_vector(1 downto 0);
    m0_rlast  : in std_logic;
    m0_rvalid  : in std_logic;
    m0_rready  : out std_logic
    --}}}
  ); --}}}
end fgpu_1m;

architecture arch_imp of fgpu_1m is
  signal nrst : std_logic;
begin
  -- fixed signals ------------------------------------------------------------------------------------{{{
  -- m0 {{{
  m0_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m0_awcache  <= "0010";
  m0_awprot <= "000";
  m0_awqos <= X"0";
  m0_arlock <= '0';
  m0_arcache <= "0010";
  m0_arprot <= "000";
  m0_arqos <= X"0";
  -- }}}
  -- }}}
  ---------------------------------------------------------------------------------------------------------}}}

  -- zulberti
  process(axi_clk, axi_aresetn)
  begin
    if axi_aresetn = '0' then
      nrst <= '0';
    else
      if rising_edge(axi_clk) then
        nrst <= '1';
      end if;
    end if;
  end process;

  uut: fgpu_top
  port map (
    clk => axi_clk,
    nrst => nrst,

    -- slave axi {{{
    s_awaddr => s_awaddr(15 downto 2),
    s_awprot => s_awprot,
    s_awvalid => s_awvalid,
    s_awready => s_awready,

    s_wdata => s_wdata,
    s_wstrb => s_wstrb,
    s_wvalid => s_wvalid,
    s_wready => s_wready,

    s_bresp => s_bresp,
    s_bvalid => s_bvalid,
    s_bready => s_bready,

    s_araddr => s_araddr(15 downto 2),
    s_arprot => s_arprot,
    s_arvalid => s_arvalid,
    s_arready => s_arready,

    s_rdata => s_rdata,
    s_rresp => s_rresp,
    s_rvalid => s_rvalid,
    s_rready => s_rready,
    -- }}}
    -- axi master 0 connections {{{
    -- ar channel
    m0_araddr => m0_araddr,
    m0_arlen => m0_arlen,
    m0_arsize => m0_arsize,
    m0_arburst => m0_arburst,
    m0_arvalid => m0_arvalid,
    m0_arready => m0_arready,
    m0_arid(0) => m0_arid,
    -- r channel
    m0_rdata => m0_rdata,
    m0_rresp => m0_rresp,
    m0_rlast => m0_rlast,
    m0_rvalid => m0_rvalid,
    m0_rready => m0_rready,
    m0_rid(0) => m0_rid,
    -- aw channel
    m0_awvalid => m0_awvalid,
    m0_awaddr => m0_awaddr,
    m0_awready => m0_awready,
    m0_awlen => m0_awlen,
    m0_awsize => m0_awsize,
    m0_awburst => m0_awburst,
    m0_awid(0) => m0_awid,
    -- w channel
    m0_wdata => m0_wdata,
    m0_wstrb => m0_wstrb,
    m0_wlast => m0_wlast,
    m0_wvalid => m0_wvalid,
    m0_wready => m0_wready,
    -- b channel
    m0_bvalid => m0_bvalid,
    m0_bready => m0_bready,
    m0_bid(0) => m0_bid,
    -- }}}
    -- axi master 1 connections {{{
    -- ar channel
    m1_araddr => open,
    m1_arlen => open,
    m1_arsize => open,
    m1_arburst => open,
    m1_arvalid => open,
    m1_arready => '0',
    m1_arid => open,
    -- r channel
    m1_rdata => (others => '0'),
    m1_rresp => (others => '0'),
    m1_rlast => '0',
    m1_rvalid => '0',
    m1_rready => open,
    m1_rid => (others => '0'),
    -- aw channel
    m1_awvalid => open,
    m1_awaddr => open,
    m1_awready => '0',
    m1_awlen => open,
    m1_awsize => open,
    m1_awburst => open,
    m1_awid => open,
    -- w channel
    m1_wdata => open,
    m1_wstrb => open,
    m1_wlast => open,
    m1_wvalid => open,
    m1_wready => '0',
    -- b channel
    m1_bvalid => '0',
    m1_bready => open,
    m1_bid => (others => '0'),
    -- }}}
    -- axi master 2 connections {{{
    -- ar channel
    m2_araddr => open,
    m2_arlen => open,
    m2_arsize => open,
    m2_arburst => open,
    m2_arvalid => open,
    m2_arready => '0',
    m2_arid => open,
    -- r channel
    m2_rdata => (others => '0'),
    m2_rresp => (others => '0'),
    m2_rlast => '0',
    m2_rvalid => '0',
    m2_rready => open,
    m2_rid => (others => '0'),
    -- aw channel
    m2_awvalid => open,
    m2_awaddr => open,
    m2_awready => '0',
    m2_awlen => open,
    m2_awsize => open,
    m2_awburst => open,
    m2_awid => open,
    -- w channel
    m2_wdata => open,
    m2_wstrb => open,
    m2_wlast => open,
    m2_wvalid => open,
    m2_wready => '0',
    -- b channel
    m2_bvalid => '0',
    m2_bready => open,
    m2_bid => (others => '0'),
    -- }}}
    -- axi master 3 connections {{{
    -- ar channel
    m3_araddr => open,
    m3_arlen => open,
    m3_arsize => open,
    m3_arburst => open,
    m3_arvalid => open,
    m3_arready => '0',
    m3_arid => open,
    -- r channel
    m3_rdata => (others => '0'),
    m3_rresp => (others => '0'),
    m3_rlast => '0',
    m3_rvalid => '0',
    m3_rready => open,
    m3_rid => (others => '0'),
    -- aw channel
    m3_awvalid => open,
    m3_awaddr => open,
    m3_awready => '0',
    m3_awlen => open,
    m3_awsize => open,
    m3_awburst => open,
    m3_awid => open,
    -- w channel
    m3_wdata => open,
    m3_wstrb => open,
    m3_wlast => open,
    m3_wvalid => open,
    m3_wready => '0',
    -- b channel
    m3_bvalid => '0',
    m3_bready => open,
    m3_bid => (others => '0')
    -- }}}
  );

end arch_imp;
