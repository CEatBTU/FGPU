-- libraries --------------------------------------------------------------------------------- {{{
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library fgpu;
use fgpu.definitions.all;
use fgpu.components.all;
------------------------------------------------------------------------------------------------- }}}

entity fgpu_wrapper is
  -- ports {{{
  port (
    -- Users to add ports here
    -- User ports ends

    -- Do not modify the ports beyond this line

	-- Please note: the bitwidth of the AXI ID port (e.g: m00_bid, m00_rid, ..) is hardwired to simplify the IP creation process.
	--			    This value must be sized considering the maximum value of N_CU (8 in this case).


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
    m00_awid    : out std_logic_vector(3 downto 0);
    m00_awaddr  : out std_logic_vector(31 downto 0);
    m00_awlen  : out std_logic_vector(7 downto 0);
    m00_awsize  : out std_logic_vector(2 downto 0);
    m00_awburst  : out std_logic_vector(1 downto 0);
    m00_awlock  : out std_logic;
    m00_awcache  : out std_logic_vector(3 downto 0);
    m00_awprot  : out std_logic_vector(2 downto 0);
    m00_awqos  : out std_logic_vector(3 downto 0);
    m00_awvalid  : out std_logic;
    m00_awready  : in std_logic;
    m00_wdata  : out std_logic_vector(63 downto 0);
    m00_wstrb  : out std_logic_vector(7 downto 0);
    m00_wlast  : out std_logic;
    m00_wvalid  : out std_logic;
    m00_wready  : in std_logic;
    m00_bid    : in std_logic_vector(3 downto 0);
    m00_bresp  : in std_logic_vector(1 downto 0);
    m00_bvalid  : in std_logic;
    m00_bready  : out std_logic;
    m00_arid    : out std_logic_vector(3 downto 0);
    m00_araddr  : out std_logic_vector(31 downto 0);
    m00_arlen  : out std_logic_vector(7 downto 0);
    m00_arsize  : out std_logic_vector(2 downto 0);
    m00_arburst  : out std_logic_vector(1 downto 0);
    m00_arlock  : out std_logic;
    m00_arcache  : out std_logic_vector(3 downto 0);
    m00_arprot  : out std_logic_vector(2 downto 0);
    m00_arqos  : out std_logic_vector(3 downto 0);
    m00_arvalid  : out std_logic;
    m00_arready  : in std_logic;
    m00_rid    : in std_logic_vector(3 downto 0);
    m00_rdata  : in std_logic_vector(63 downto 0);
    m00_rresp  : in std_logic_vector(1 downto 0);
    m00_rlast  : in std_logic;
    m00_rvalid  : in std_logic;
    m00_rready  : out std_logic;
    -- }}}

    -- Ports of Axi Master Bus Interface M1 {{{
    m01_awid    : out std_logic_vector(3 downto 0);
    m01_awaddr  : out std_logic_vector(31 downto 0);
    m01_awlen  : out std_logic_vector(7 downto 0);
    m01_awsize  : out std_logic_vector(2 downto 0);
    m01_awburst  : out std_logic_vector(1 downto 0);
    m01_awlock  : out std_logic;
    m01_awcache  : out std_logic_vector(3 downto 0);
    m01_awprot  : out std_logic_vector(2 downto 0);
    m01_awqos  : out std_logic_vector(3 downto 0);
    m01_awvalid  : out std_logic;
    m01_awready  : in std_logic;
    m01_wdata  : out std_logic_vector(63 downto 0);
    m01_wstrb  : out std_logic_vector(7 downto 0);
    m01_wlast  : out std_logic;
    m01_wvalid  : out std_logic;
    m01_wready  : in std_logic;
    m01_bid    : in std_logic_vector(3 downto 0);
    m01_bresp  : in std_logic_vector(1 downto 0);
    m01_bvalid  : in std_logic;
    m01_bready  : out std_logic;
    m01_arid    : out std_logic_vector(3 downto 0);
    m01_araddr  : out std_logic_vector(31 downto 0);
    m01_arlen  : out std_logic_vector(7 downto 0);
    m01_arsize  : out std_logic_vector(2 downto 0);
    m01_arburst  : out std_logic_vector(1 downto 0);
    m01_arlock  : out std_logic;
    m01_arcache  : out std_logic_vector(3 downto 0);
    m01_arprot  : out std_logic_vector(2 downto 0);
    m01_arqos  : out std_logic_vector(3 downto 0);
    m01_arvalid  : out std_logic;
    m01_arready  : in std_logic;
    m01_rid    : in std_logic_vector(3 downto 0);
    m01_rdata  : in std_logic_vector(63 downto 0);
    m01_rresp  : in std_logic_vector(1 downto 0);
    m01_rlast  : in std_logic;
    m01_rvalid  : in std_logic;
    m01_rready  : out std_logic;
    -- }}}

    -- Ports of Axi Master Bus Interface M2 {{{
    m02_awid    : out std_logic_vector(3 downto 0);
    m02_awaddr  : out std_logic_vector(31 downto 0);
    m02_awlen  : out std_logic_vector(7 downto 0);
    m02_awsize  : out std_logic_vector(2 downto 0);
    m02_awburst  : out std_logic_vector(1 downto 0);
    m02_awlock  : out std_logic;
    m02_awcache  : out std_logic_vector(3 downto 0);
    m02_awprot  : out std_logic_vector(2 downto 0);
    m02_awqos  : out std_logic_vector(3 downto 0);
    m02_awvalid  : out std_logic;
    m02_awready  : in std_logic;
    m02_wdata  : out std_logic_vector(63 downto 0);
    m02_wstrb  : out std_logic_vector(7 downto 0);
    m02_wlast  : out std_logic;
    m02_wvalid  : out std_logic;
    m02_wready  : in std_logic;
    m02_bid    : in std_logic_vector(3 downto 0);
    m02_bresp  : in std_logic_vector(1 downto 0);
    m02_bvalid  : in std_logic;
    m02_bready  : out std_logic;
    m02_arid    : out std_logic_vector(3 downto 0);
    m02_araddr  : out std_logic_vector(31 downto 0);
    m02_arlen  : out std_logic_vector(7 downto 0);
    m02_arsize  : out std_logic_vector(2 downto 0);
    m02_arburst  : out std_logic_vector(1 downto 0);
    m02_arlock  : out std_logic;
    m02_arcache  : out std_logic_vector(3 downto 0);
    m02_arprot  : out std_logic_vector(2 downto 0);
    m02_arqos  : out std_logic_vector(3 downto 0);
    m02_arvalid  : out std_logic;
    m02_arready  : in std_logic;
    m02_rid    : in std_logic_vector(3 downto 0);
    m02_rdata  : in std_logic_vector(63 downto 0);
    m02_rresp  : in std_logic_vector(1 downto 0);
    m02_rlast  : in std_logic;
    m02_rvalid  : in std_logic;
    m02_rready  : out std_logic;
    -- }}}

    -- Ports of Axi Master Bus Interface M3 {{{
    m03_awid    : out std_logic_vector(3 downto 0);
    m03_awaddr  : out std_logic_vector(31 downto 0);
    m03_awlen  : out std_logic_vector(7 downto 0);
    m03_awsize  : out std_logic_vector(2 downto 0);
    m03_awburst  : out std_logic_vector(1 downto 0);
    m03_awlock  : out std_logic;
    m03_awcache  : out std_logic_vector(3 downto 0);
    m03_awprot  : out std_logic_vector(2 downto 0);
    m03_awqos  : out std_logic_vector(3 downto 0);
    m03_awvalid  : out std_logic;
    m03_awready  : in std_logic;
    m03_wdata  : out std_logic_vector(63 downto 0);
    m03_wstrb  : out std_logic_vector(7 downto 0);
    m03_wlast  : out std_logic;
    m03_wvalid  : out std_logic;
    m03_wready  : in std_logic;
    m03_bid    : in std_logic_vector(3 downto 0);
    m03_bresp  : in std_logic_vector(1 downto 0);
    m03_bvalid  : in std_logic;
    m03_bready  : out std_logic;
    m03_arid    : out std_logic_vector(3 downto 0);
    m03_araddr  : out std_logic_vector(31 downto 0);
    m03_arlen  : out std_logic_vector(7 downto 0);
    m03_arsize  : out std_logic_vector(2 downto 0);
    m03_arburst  : out std_logic_vector(1 downto 0);
    m03_arlock  : out std_logic;
    m03_arcache  : out std_logic_vector(3 downto 0);
    m03_arprot  : out std_logic_vector(2 downto 0);
    m03_arqos  : out std_logic_vector(3 downto 0);
    m03_arvalid  : out std_logic;
    m03_arready  : in std_logic;
    m03_rid    : in std_logic_vector(3 downto 0);
    m03_rdata  : in std_logic_vector(63 downto 0);
    m03_rresp  : in std_logic_vector(1 downto 0);
    m03_rlast  : in std_logic;
    m03_rvalid  : in std_logic;
    m03_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M4 {{{
    m04_awid    : out std_logic_vector(3 downto 0);
    m04_awaddr  : out std_logic_vector(31 downto 0);
    m04_awlen  : out std_logic_vector(7 downto 0);
    m04_awsize  : out std_logic_vector(2 downto 0);
    m04_awburst  : out std_logic_vector(1 downto 0);
    m04_awlock  : out std_logic;
    m04_awcache  : out std_logic_vector(3 downto 0);
    m04_awprot  : out std_logic_vector(2 downto 0);
    m04_awqos  : out std_logic_vector(3 downto 0);
    m04_awvalid  : out std_logic;
    m04_awready  : in std_logic;
    m04_wdata  : out std_logic_vector(63 downto 0);
    m04_wstrb  : out std_logic_vector(7 downto 0);
    m04_wlast  : out std_logic;
    m04_wvalid  : out std_logic;
    m04_wready  : in std_logic;
    m04_bid    : in std_logic_vector(3 downto 0);
    m04_bresp  : in std_logic_vector(1 downto 0);
    m04_bvalid  : in std_logic;
    m04_bready  : out std_logic;
    m04_arid    : out std_logic_vector(3 downto 0);
    m04_araddr  : out std_logic_vector(31 downto 0);
    m04_arlen  : out std_logic_vector(7 downto 0);
    m04_arsize  : out std_logic_vector(2 downto 0);
    m04_arburst  : out std_logic_vector(1 downto 0);
    m04_arlock  : out std_logic;
    m04_arcache  : out std_logic_vector(3 downto 0);
    m04_arprot  : out std_logic_vector(2 downto 0);
    m04_arqos  : out std_logic_vector(3 downto 0);
    m04_arvalid  : out std_logic;
    m04_arready  : in std_logic;
    m04_rid    : in std_logic_vector(3 downto 0);
    m04_rdata  : in std_logic_vector(63 downto 0);
    m04_rresp  : in std_logic_vector(1 downto 0);
    m04_rlast  : in std_logic;
    m04_rvalid  : in std_logic;
    m04_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M5 {{{
    m05_awid    : out std_logic_vector(3 downto 0);
    m05_awaddr  : out std_logic_vector(31 downto 0);
    m05_awlen  : out std_logic_vector(7 downto 0);
    m05_awsize  : out std_logic_vector(2 downto 0);
    m05_awburst  : out std_logic_vector(1 downto 0);
    m05_awlock  : out std_logic;
    m05_awcache  : out std_logic_vector(3 downto 0);
    m05_awprot  : out std_logic_vector(2 downto 0);
    m05_awqos  : out std_logic_vector(3 downto 0);
    m05_awvalid  : out std_logic;
    m05_awready  : in std_logic;
    m05_wdata  : out std_logic_vector(63 downto 0);
    m05_wstrb  : out std_logic_vector(7 downto 0);
    m05_wlast  : out std_logic;
    m05_wvalid  : out std_logic;
    m05_wready  : in std_logic;
    m05_bid    : in std_logic_vector(3 downto 0);
    m05_bresp  : in std_logic_vector(1 downto 0);
    m05_bvalid  : in std_logic;
    m05_bready  : out std_logic;
    m05_arid    : out std_logic_vector(3 downto 0);
    m05_araddr  : out std_logic_vector(31 downto 0);
    m05_arlen  : out std_logic_vector(7 downto 0);
    m05_arsize  : out std_logic_vector(2 downto 0);
    m05_arburst  : out std_logic_vector(1 downto 0);
    m05_arlock  : out std_logic;
    m05_arcache  : out std_logic_vector(3 downto 0);
    m05_arprot  : out std_logic_vector(2 downto 0);
    m05_arqos  : out std_logic_vector(3 downto 0);
    m05_arvalid  : out std_logic;
    m05_arready  : in std_logic;
    m05_rid    : in std_logic_vector(3 downto 0);
    m05_rdata  : in std_logic_vector(63 downto 0);
    m05_rresp  : in std_logic_vector(1 downto 0);
    m05_rlast  : in std_logic;
    m05_rvalid  : in std_logic;
    m05_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M6 {{{
    m06_awid    : out std_logic_vector(3 downto 0);
    m06_awaddr  : out std_logic_vector(31 downto 0);
    m06_awlen  : out std_logic_vector(7 downto 0);
    m06_awsize  : out std_logic_vector(2 downto 0);
    m06_awburst  : out std_logic_vector(1 downto 0);
    m06_awlock  : out std_logic;
    m06_awcache  : out std_logic_vector(3 downto 0);
    m06_awprot  : out std_logic_vector(2 downto 0);
    m06_awqos  : out std_logic_vector(3 downto 0);
    m06_awvalid  : out std_logic;
    m06_awready  : in std_logic;
    m06_wdata  : out std_logic_vector(63 downto 0);
    m06_wstrb  : out std_logic_vector(7 downto 0);
    m06_wlast  : out std_logic;
    m06_wvalid  : out std_logic;
    m06_wready  : in std_logic;
    m06_bid    : in std_logic_vector(3 downto 0);
    m06_bresp  : in std_logic_vector(1 downto 0);
    m06_bvalid  : in std_logic;
    m06_bready  : out std_logic;
    m06_arid    : out std_logic_vector(3 downto 0);
    m06_araddr  : out std_logic_vector(31 downto 0);
    m06_arlen  : out std_logic_vector(7 downto 0);
    m06_arsize  : out std_logic_vector(2 downto 0);
    m06_arburst  : out std_logic_vector(1 downto 0);
    m06_arlock  : out std_logic;
    m06_arcache  : out std_logic_vector(3 downto 0);
    m06_arprot  : out std_logic_vector(2 downto 0);
    m06_arqos  : out std_logic_vector(3 downto 0);
    m06_arvalid  : out std_logic;
    m06_arready  : in std_logic;
    m06_rid    : in std_logic_vector(3 downto 0);
    m06_rdata  : in std_logic_vector(63 downto 0);
    m06_rresp  : in std_logic_vector(1 downto 0);
    m06_rlast  : in std_logic;
    m06_rvalid  : in std_logic;
    m06_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M7 {{{
    m07_awid    : out std_logic_vector(3 downto 0);
    m07_awaddr  : out std_logic_vector(31 downto 0);
    m07_awlen  : out std_logic_vector(7 downto 0);
    m07_awsize  : out std_logic_vector(2 downto 0);
    m07_awburst  : out std_logic_vector(1 downto 0);
    m07_awlock  : out std_logic;
    m07_awcache  : out std_logic_vector(3 downto 0);
    m07_awprot  : out std_logic_vector(2 downto 0);
    m07_awqos  : out std_logic_vector(3 downto 0);
    m07_awvalid  : out std_logic;
    m07_awready  : in std_logic;
    m07_wdata  : out std_logic_vector(63 downto 0);
    m07_wstrb  : out std_logic_vector(7 downto 0);
    m07_wlast  : out std_logic;
    m07_wvalid  : out std_logic;
    m07_wready  : in std_logic;
    m07_bid    : in std_logic_vector(3 downto 0);
    m07_bresp  : in std_logic_vector(1 downto 0);
    m07_bvalid  : in std_logic;
    m07_bready  : out std_logic;
    m07_arid    : out std_logic_vector(3 downto 0);
    m07_araddr  : out std_logic_vector(31 downto 0);
    m07_arlen  : out std_logic_vector(7 downto 0);
    m07_arsize  : out std_logic_vector(2 downto 0);
    m07_arburst  : out std_logic_vector(1 downto 0);
    m07_arlock  : out std_logic;
    m07_arcache  : out std_logic_vector(3 downto 0);
    m07_arprot  : out std_logic_vector(2 downto 0);
    m07_arqos  : out std_logic_vector(3 downto 0);
    m07_arvalid  : out std_logic;
    m07_arready  : in std_logic;
    m07_rid    : in std_logic_vector(3 downto 0);
    m07_rdata  : in std_logic_vector(63 downto 0);
    m07_rresp  : in std_logic_vector(1 downto 0);
    m07_rlast  : in std_logic;
    m07_rvalid  : in std_logic;
    m07_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M8 {{{
    m08_awid    : out std_logic_vector(3 downto 0);
    m08_awaddr  : out std_logic_vector(31 downto 0);
    m08_awlen  : out std_logic_vector(7 downto 0);
    m08_awsize  : out std_logic_vector(2 downto 0);
    m08_awburst  : out std_logic_vector(1 downto 0);
    m08_awlock  : out std_logic;
    m08_awcache  : out std_logic_vector(3 downto 0);
    m08_awprot  : out std_logic_vector(2 downto 0);
    m08_awqos  : out std_logic_vector(3 downto 0);
    m08_awvalid  : out std_logic;
    m08_awready  : in std_logic;
    m08_wdata  : out std_logic_vector(63 downto 0);
    m08_wstrb  : out std_logic_vector(7 downto 0);
    m08_wlast  : out std_logic;
    m08_wvalid  : out std_logic;
    m08_wready  : in std_logic;
    m08_bid    : in std_logic_vector(3 downto 0);
    m08_bresp  : in std_logic_vector(1 downto 0);
    m08_bvalid  : in std_logic;
    m08_bready  : out std_logic;
    m08_arid    : out std_logic_vector(3 downto 0);
    m08_araddr  : out std_logic_vector(31 downto 0);
    m08_arlen  : out std_logic_vector(7 downto 0);
    m08_arsize  : out std_logic_vector(2 downto 0);
    m08_arburst  : out std_logic_vector(1 downto 0);
    m08_arlock  : out std_logic;
    m08_arcache  : out std_logic_vector(3 downto 0);
    m08_arprot  : out std_logic_vector(2 downto 0);
    m08_arqos  : out std_logic_vector(3 downto 0);
    m08_arvalid  : out std_logic;
    m08_arready  : in std_logic;
    m08_rid    : in std_logic_vector(3 downto 0);
    m08_rdata  : in std_logic_vector(63 downto 0);
    m08_rresp  : in std_logic_vector(1 downto 0);
    m08_rlast  : in std_logic;
    m08_rvalid  : in std_logic;
    m08_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M9 {{{
    m09_awid    : out std_logic_vector(3 downto 0);
    m09_awaddr  : out std_logic_vector(31 downto 0);
    m09_awlen  : out std_logic_vector(7 downto 0);
    m09_awsize  : out std_logic_vector(2 downto 0);
    m09_awburst  : out std_logic_vector(1 downto 0);
    m09_awlock  : out std_logic;
    m09_awcache  : out std_logic_vector(3 downto 0);
    m09_awprot  : out std_logic_vector(2 downto 0);
    m09_awqos  : out std_logic_vector(3 downto 0);
    m09_awvalid  : out std_logic;
    m09_awready  : in std_logic;
    m09_wdata  : out std_logic_vector(63 downto 0);
    m09_wstrb  : out std_logic_vector(7 downto 0);
    m09_wlast  : out std_logic;
    m09_wvalid  : out std_logic;
    m09_wready  : in std_logic;
    m09_bid    : in std_logic_vector(3 downto 0);
    m09_bresp  : in std_logic_vector(1 downto 0);
    m09_bvalid  : in std_logic;
    m09_bready  : out std_logic;
    m09_arid    : out std_logic_vector(3 downto 0);
    m09_araddr  : out std_logic_vector(31 downto 0);
    m09_arlen  : out std_logic_vector(7 downto 0);
    m09_arsize  : out std_logic_vector(2 downto 0);
    m09_arburst  : out std_logic_vector(1 downto 0);
    m09_arlock  : out std_logic;
    m09_arcache  : out std_logic_vector(3 downto 0);
    m09_arprot  : out std_logic_vector(2 downto 0);
    m09_arqos  : out std_logic_vector(3 downto 0);
    m09_arvalid  : out std_logic;
    m09_arready  : in std_logic;
    m09_rid    : in std_logic_vector(3 downto 0);
    m09_rdata  : in std_logic_vector(63 downto 0);
    m09_rresp  : in std_logic_vector(1 downto 0);
    m09_rlast  : in std_logic;
    m09_rvalid  : in std_logic;
    m09_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M10 {{{
    m10_awid    : out std_logic_vector(3 downto 0);
    m10_awaddr  : out std_logic_vector(31 downto 0);
    m10_awlen  : out std_logic_vector(7 downto 0);
    m10_awsize  : out std_logic_vector(2 downto 0);
    m10_awburst  : out std_logic_vector(1 downto 0);
    m10_awlock  : out std_logic;
    m10_awcache  : out std_logic_vector(3 downto 0);
    m10_awprot  : out std_logic_vector(2 downto 0);
    m10_awqos  : out std_logic_vector(3 downto 0);
    m10_awvalid  : out std_logic;
    m10_awready  : in std_logic;
    m10_wdata  : out std_logic_vector(63 downto 0);
    m10_wstrb  : out std_logic_vector(7 downto 0);
    m10_wlast  : out std_logic;
    m10_wvalid  : out std_logic;
    m10_wready  : in std_logic;
    m10_bid    : in std_logic_vector(3 downto 0);
    m10_bresp  : in std_logic_vector(1 downto 0);
    m10_bvalid  : in std_logic;
    m10_bready  : out std_logic;
    m10_arid    : out std_logic_vector(3 downto 0);
    m10_araddr  : out std_logic_vector(31 downto 0);
    m10_arlen  : out std_logic_vector(7 downto 0);
    m10_arsize  : out std_logic_vector(2 downto 0);
    m10_arburst  : out std_logic_vector(1 downto 0);
    m10_arlock  : out std_logic;
    m10_arcache  : out std_logic_vector(3 downto 0);
    m10_arprot  : out std_logic_vector(2 downto 0);
    m10_arqos  : out std_logic_vector(3 downto 0);
    m10_arvalid  : out std_logic;
    m10_arready  : in std_logic;
    m10_rid    : in std_logic_vector(3 downto 0);
    m10_rdata  : in std_logic_vector(63 downto 0);
    m10_rresp  : in std_logic_vector(1 downto 0);
    m10_rlast  : in std_logic;
    m10_rvalid  : in std_logic;
    m10_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M11 {{{
    m11_awid    : out std_logic_vector(3 downto 0);
    m11_awaddr  : out std_logic_vector(31 downto 0);
    m11_awlen  : out std_logic_vector(7 downto 0);
    m11_awsize  : out std_logic_vector(2 downto 0);
    m11_awburst  : out std_logic_vector(1 downto 0);
    m11_awlock  : out std_logic;
    m11_awcache  : out std_logic_vector(3 downto 0);
    m11_awprot  : out std_logic_vector(2 downto 0);
    m11_awqos  : out std_logic_vector(3 downto 0);
    m11_awvalid  : out std_logic;
    m11_awready  : in std_logic;
    m11_wdata  : out std_logic_vector(63 downto 0);
    m11_wstrb  : out std_logic_vector(7 downto 0);
    m11_wlast  : out std_logic;
    m11_wvalid  : out std_logic;
    m11_wready  : in std_logic;
    m11_bid    : in std_logic_vector(3 downto 0);
    m11_bresp  : in std_logic_vector(1 downto 0);
    m11_bvalid  : in std_logic;
    m11_bready  : out std_logic;
    m11_arid    : out std_logic_vector(3 downto 0);
    m11_araddr  : out std_logic_vector(31 downto 0);
    m11_arlen  : out std_logic_vector(7 downto 0);
    m11_arsize  : out std_logic_vector(2 downto 0);
    m11_arburst  : out std_logic_vector(1 downto 0);
    m11_arlock  : out std_logic;
    m11_arcache  : out std_logic_vector(3 downto 0);
    m11_arprot  : out std_logic_vector(2 downto 0);
    m11_arqos  : out std_logic_vector(3 downto 0);
    m11_arvalid  : out std_logic;
    m11_arready  : in std_logic;
    m11_rid    : in std_logic_vector(3 downto 0);
    m11_rdata  : in std_logic_vector(63 downto 0);
    m11_rresp  : in std_logic_vector(1 downto 0);
    m11_rlast  : in std_logic;
    m11_rvalid  : in std_logic;
    m11_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M12 {{{
    m12_awid    : out std_logic_vector(3 downto 0);
    m12_awaddr  : out std_logic_vector(31 downto 0);
    m12_awlen  : out std_logic_vector(7 downto 0);
    m12_awsize  : out std_logic_vector(2 downto 0);
    m12_awburst  : out std_logic_vector(1 downto 0);
    m12_awlock  : out std_logic;
    m12_awcache  : out std_logic_vector(3 downto 0);
    m12_awprot  : out std_logic_vector(2 downto 0);
    m12_awqos  : out std_logic_vector(3 downto 0);
    m12_awvalid  : out std_logic;
    m12_awready  : in std_logic;
    m12_wdata  : out std_logic_vector(63 downto 0);
    m12_wstrb  : out std_logic_vector(7 downto 0);
    m12_wlast  : out std_logic;
    m12_wvalid  : out std_logic;
    m12_wready  : in std_logic;
    m12_bid    : in std_logic_vector(3 downto 0);
    m12_bresp  : in std_logic_vector(1 downto 0);
    m12_bvalid  : in std_logic;
    m12_bready  : out std_logic;
    m12_arid    : out std_logic_vector(3 downto 0);
    m12_araddr  : out std_logic_vector(31 downto 0);
    m12_arlen  : out std_logic_vector(7 downto 0);
    m12_arsize  : out std_logic_vector(2 downto 0);
    m12_arburst  : out std_logic_vector(1 downto 0);
    m12_arlock  : out std_logic;
    m12_arcache  : out std_logic_vector(3 downto 0);
    m12_arprot  : out std_logic_vector(2 downto 0);
    m12_arqos  : out std_logic_vector(3 downto 0);
    m12_arvalid  : out std_logic;
    m12_arready  : in std_logic;
    m12_rid    : in std_logic_vector(3 downto 0);
    m12_rdata  : in std_logic_vector(63 downto 0);
    m12_rresp  : in std_logic_vector(1 downto 0);
    m12_rlast  : in std_logic;
    m12_rvalid  : in std_logic;
    m12_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M13 {{{
    m13_awid    : out std_logic_vector(3 downto 0);
    m13_awaddr  : out std_logic_vector(31 downto 0);
    m13_awlen  : out std_logic_vector(7 downto 0);
    m13_awsize  : out std_logic_vector(2 downto 0);
    m13_awburst  : out std_logic_vector(1 downto 0);
    m13_awlock  : out std_logic;
    m13_awcache  : out std_logic_vector(3 downto 0);
    m13_awprot  : out std_logic_vector(2 downto 0);
    m13_awqos  : out std_logic_vector(3 downto 0);
    m13_awvalid  : out std_logic;
    m13_awready  : in std_logic;
    m13_wdata  : out std_logic_vector(63 downto 0);
    m13_wstrb  : out std_logic_vector(7 downto 0);
    m13_wlast  : out std_logic;
    m13_wvalid  : out std_logic;
    m13_wready  : in std_logic;
    m13_bid    : in std_logic_vector(3 downto 0);
    m13_bresp  : in std_logic_vector(1 downto 0);
    m13_bvalid  : in std_logic;
    m13_bready  : out std_logic;
    m13_arid    : out std_logic_vector(3 downto 0);
    m13_araddr  : out std_logic_vector(31 downto 0);
    m13_arlen  : out std_logic_vector(7 downto 0);
    m13_arsize  : out std_logic_vector(2 downto 0);
    m13_arburst  : out std_logic_vector(1 downto 0);
    m13_arlock  : out std_logic;
    m13_arcache  : out std_logic_vector(3 downto 0);
    m13_arprot  : out std_logic_vector(2 downto 0);
    m13_arqos  : out std_logic_vector(3 downto 0);
    m13_arvalid  : out std_logic;
    m13_arready  : in std_logic;
    m13_rid    : in std_logic_vector(3 downto 0);
    m13_rdata  : in std_logic_vector(63 downto 0);
    m13_rresp  : in std_logic_vector(1 downto 0);
    m13_rlast  : in std_logic;
    m13_rvalid  : in std_logic;
    m13_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M14 {{{
    m14_awid    : out std_logic_vector(3 downto 0);
    m14_awaddr  : out std_logic_vector(31 downto 0);
    m14_awlen  : out std_logic_vector(7 downto 0);
    m14_awsize  : out std_logic_vector(2 downto 0);
    m14_awburst  : out std_logic_vector(1 downto 0);
    m14_awlock  : out std_logic;
    m14_awcache  : out std_logic_vector(3 downto 0);
    m14_awprot  : out std_logic_vector(2 downto 0);
    m14_awqos  : out std_logic_vector(3 downto 0);
    m14_awvalid  : out std_logic;
    m14_awready  : in std_logic;
    m14_wdata  : out std_logic_vector(63 downto 0);
    m14_wstrb  : out std_logic_vector(7 downto 0);
    m14_wlast  : out std_logic;
    m14_wvalid  : out std_logic;
    m14_wready  : in std_logic;
    m14_bid    : in std_logic_vector(3 downto 0);
    m14_bresp  : in std_logic_vector(1 downto 0);
    m14_bvalid  : in std_logic;
    m14_bready  : out std_logic;
    m14_arid    : out std_logic_vector(3 downto 0);
    m14_araddr  : out std_logic_vector(31 downto 0);
    m14_arlen  : out std_logic_vector(7 downto 0);
    m14_arsize  : out std_logic_vector(2 downto 0);
    m14_arburst  : out std_logic_vector(1 downto 0);
    m14_arlock  : out std_logic;
    m14_arcache  : out std_logic_vector(3 downto 0);
    m14_arprot  : out std_logic_vector(2 downto 0);
    m14_arqos  : out std_logic_vector(3 downto 0);
    m14_arvalid  : out std_logic;
    m14_arready  : in std_logic;
    m14_rid    : in std_logic_vector(3 downto 0);
    m14_rdata  : in std_logic_vector(63 downto 0);
    m14_rresp  : in std_logic_vector(1 downto 0);
    m14_rlast  : in std_logic;
    m14_rvalid  : in std_logic;
    m14_rready  : out std_logic;
    -- }}}
    -- Ports of Axi Master Bus Interface M15 {{{
    m15_awid    : out std_logic_vector(3 downto 0);
    m15_awaddr  : out std_logic_vector(31 downto 0);
    m15_awlen  : out std_logic_vector(7 downto 0);
    m15_awsize  : out std_logic_vector(2 downto 0);
    m15_awburst  : out std_logic_vector(1 downto 0);
    m15_awlock  : out std_logic;
    m15_awcache  : out std_logic_vector(3 downto 0);
    m15_awprot  : out std_logic_vector(2 downto 0);
    m15_awqos  : out std_logic_vector(3 downto 0);
    m15_awvalid  : out std_logic;
    m15_awready  : in std_logic;
    m15_wdata  : out std_logic_vector(63 downto 0);
    m15_wstrb  : out std_logic_vector(7 downto 0);
    m15_wlast  : out std_logic;
    m15_wvalid  : out std_logic;
    m15_wready  : in std_logic;
    m15_bid    : in std_logic_vector(3 downto 0);
    m15_bresp  : in std_logic_vector(1 downto 0);
    m15_bvalid  : in std_logic;
    m15_bready  : out std_logic;
    m15_arid    : out std_logic_vector(3 downto 0);
    m15_araddr  : out std_logic_vector(31 downto 0);
    m15_arlen  : out std_logic_vector(7 downto 0);
    m15_arsize  : out std_logic_vector(2 downto 0);
    m15_arburst  : out std_logic_vector(1 downto 0);
    m15_arlock  : out std_logic;
    m15_arcache  : out std_logic_vector(3 downto 0);
    m15_arprot  : out std_logic_vector(2 downto 0);
    m15_arqos  : out std_logic_vector(3 downto 0);
    m15_arvalid  : out std_logic;
    m15_arready  : in std_logic;
    m15_rid    : in std_logic_vector(3 downto 0);
    m15_rdata  : in std_logic_vector(63 downto 0);
    m15_rresp  : in std_logic_vector(1 downto 0);
    m15_rlast  : in std_logic;
    m15_rvalid  : in std_logic;
    m15_rready  : out std_logic
    -- }}}
  ); --}}}
end fgpu_wrapper;

architecture arch_imp of fgpu_wrapper is
  signal nrst      : std_logic;
  signal nrst_sync : std_logic;
begin
  -- fixed signals ------------------------------------------------------------------------------------{{{
  -- m0 {{{
  m00_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m00_awcache  <= "0010";
  m00_awprot <= "000";
  m00_awqos <= X"0";
  m00_arlock <= '0';
  m00_arcache <= "0010";
  m00_arprot <= "000";
  m00_arqos <= X"0";
  -- }}}
  -- m1 {{{
  m01_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m01_awcache  <= "0010";
  m01_awprot <= "000";
  m01_awqos <= X"0";
  m01_arlock <= '0';
  m01_arcache <= "0010";
  m01_arprot <= "000";
  m01_arqos <= X"0";
  -- }}}
  -- m2 {{{
  m02_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m02_awcache  <= "0010";
  m02_awprot <= "000";
  m02_awqos <= X"0";
  m02_arlock <= '0';
  m02_arcache <= "0010";
  m02_arprot <= "000";
  m02_arqos <= X"0";
  -- }}}
  -- m3 {{{
  m03_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m03_awcache  <= "0010";
  m03_awprot <= "000";
  m03_awqos <= X"0";
  m03_arlock <= '0';
  m03_arcache <= "0010";
  m03_arprot <= "000";
  m03_arqos <= X"0";
  -- }}}
    -- m4 {{{
  m04_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m04_awcache  <= "0010";
  m04_awprot <= "000";
  m04_awqos <= X"0";
  m04_arlock <= '0';
  m04_arcache <= "0010";
  m04_arprot <= "000";
  m04_arqos <= X"0";
  -- }}}
    -- m5 {{{
  m05_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m05_awcache  <= "0010";
  m05_awprot <= "000";
  m05_awqos <= X"0";
  m05_arlock <= '0';
  m05_arcache <= "0010";
  m05_arprot <= "000";
  m05_arqos <= X"0";
  -- }}}
    -- m6 {{{
  m06_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m06_awcache  <= "0010";
  m06_awprot <= "000";
  m06_awqos <= X"0";
  m06_arlock <= '0';
  m06_arcache <= "0010";
  m06_arprot <= "000";
  m06_arqos <= X"0";
  -- }}}
    -- m7 {{{
  m07_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m07_awcache  <= "0010";
  m07_awprot <= "000";
  m07_awqos <= X"0";
  m07_arlock <= '0';
  m07_arcache <= "0010";
  m07_arprot <= "000";
  m07_arqos <= X"0";
  -- }}}
    -- m8 {{{
  m08_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m08_awcache  <= "0010";
  m08_awprot <= "000";
  m08_awqos <= X"0";
  m08_arlock <= '0';
  m08_arcache <= "0010";
  m08_arprot <= "000";
  m08_arqos <= X"0";
  -- }}}
    -- m9 {{{
  m09_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m09_awcache  <= "0010";
  m09_awprot <= "000";
  m09_awqos <= X"0";
  m09_arlock <= '0';
  m09_arcache <= "0010";
  m09_arprot <= "000";
  m09_arqos <= X"0";
  -- }}}
    -- m10 {{{
  m10_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m10_awcache  <= "0010";
  m10_awprot <= "000";
  m10_awqos <= X"0";
  m10_arlock <= '0';
  m10_arcache <= "0010";
  m10_arprot <= "000";
  m10_arqos <= X"0";
  -- }}}
    -- m11 {{{
  m11_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m11_awcache  <= "0010";
  m11_awprot <= "000";
  m11_awqos <= X"0";
  m11_arlock <= '0';
  m11_arcache <= "0010";
  m11_arprot <= "000";
  m11_arqos <= X"0";
  -- }}}
    -- m12 {{{
  m12_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m12_awcache  <= "0010";
  m12_awprot <= "000";
  m12_awqos <= X"0";
  m12_arlock <= '0';
  m12_arcache <= "0010";
  m12_arprot <= "000";
  m12_arqos <= X"0";
  -- }}}
    -- m13 {{{
  m13_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m13_awcache  <= "0010";
  m13_awprot <= "000";
  m13_awqos <= X"0";
  m13_arlock <= '0';
  m13_arcache <= "0010";
  m13_arprot <= "000";
  m13_arqos <= X"0";
  -- }}}
    -- m14 {{{
  m14_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m14_awcache  <= "0010";
  m14_awprot <= "000";
  m14_awqos <= X"0";
  m14_arlock <= '0';
  m14_arcache <= "0010";
  m14_arprot <= "000";
  m14_arqos <= X"0";
  -- }}}
    -- m15 {{{
  m15_awlock <= '0';
  --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
  m15_awcache  <= "0010";
  m15_awprot <= "000";
  m15_awqos <= X"0";
  m15_arlock <= '0';
  m15_arcache <= "0010";
  m15_arprot <= "000";
  m15_arqos <= X"0";
  -- }}}
  -- }}}
  ---------------------------------------------------------------------------------------------------------}}}


  process(axi_clk, axi_aresetn)
  begin
    if axi_aresetn = '0' then
      nrst      <= '0';
      nrst_sync <= '0';
    else
      if rising_edge(axi_clk) then
        nrst      <= '1';
        nrst_sync <= nrst;
      end if;
    end if;
  end process;

  uut: fgpu_top
  port map (
    clk => axi_clk,
    nrst => nrst_sync,

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
    m00_araddr => m00_araddr,
    m00_arlen => m00_arlen,
    m00_arsize => m00_arsize,
    m00_arburst => m00_arburst,
    m00_arvalid => m00_arvalid,
    m00_arready => m00_arready,
    m00_arid => m00_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m00_rdata => m00_rdata,
    m00_rresp => m00_rresp,
    m00_rlast => m00_rlast,
    m00_rvalid => m00_rvalid,
    m00_rready => m00_rready,
    m00_rid => m00_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m00_awvalid => m00_awvalid,
    m00_awaddr => m00_awaddr,
    m00_awready => m00_awready,
    m00_awlen => m00_awlen,
    m00_awsize => m00_awsize,
    m00_awburst => m00_awburst,
    m00_awid => m00_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m00_wdata => m00_wdata,
    m00_wstrb => m00_wstrb,
    m00_wlast => m00_wlast,
    m00_wvalid => m00_wvalid,
    m00_wready => m00_wready,
    -- b channel
    m00_bvalid => m00_bvalid,
    m00_bready => m00_bready,
    m00_bid => m00_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 1 connections {{{
    -- ar channel
    m01_araddr => m01_araddr,
    m01_arlen => m01_arlen,
    m01_arsize => m01_arsize,
    m01_arburst => m01_arburst,
    m01_arvalid => m01_arvalid,
    m01_arready => m01_arready,
    m01_arid => m01_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m01_rdata => m01_rdata,
    m01_rresp => m01_rresp,
    m01_rlast => m01_rlast,
    m01_rvalid => m01_rvalid,
    m01_rready => m01_rready,
    m01_rid => m01_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m01_awvalid => m01_awvalid,
    m01_awaddr => m01_awaddr,
    m01_awready => m01_awready,
    m01_awlen => m01_awlen,
    m01_awsize => m01_awsize,
    m01_awburst => m01_awburst,
    m01_awid => m01_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m01_wdata => m01_wdata,
    m01_wstrb => m01_wstrb,
    m01_wlast => m01_wlast,
    m01_wvalid => m01_wvalid,
    m01_wready => m01_wready,
    -- b channel
    m01_bvalid => m01_bvalid,
    m01_bready => m01_bready,
    m01_bid => m01_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 2 connections {{{
    -- ar channel
    m02_araddr => m02_araddr,
    m02_arlen => m02_arlen,
    m02_arsize => m02_arsize,
    m02_arburst => m02_arburst,
    m02_arvalid => m02_arvalid,
    m02_arready => m02_arready,
    m02_arid => m02_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m02_rdata => m02_rdata,
    m02_rresp => m02_rresp,
    m02_rlast => m02_rlast,
    m02_rvalid => m02_rvalid,
    m02_rready => m02_rready,
    m02_rid => m02_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m02_awvalid => m02_awvalid,
    m02_awaddr => m02_awaddr,
    m02_awready => m02_awready,
    m02_awlen => m02_awlen,
    m02_awsize => m02_awsize,
    m02_awburst => m02_awburst,
    m02_awid => m02_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m02_wdata => m02_wdata,
    m02_wstrb => m02_wstrb,
    m02_wlast => m02_wlast,
    m02_wvalid => m02_wvalid,
    m02_wready => m02_wready,
    -- b channel
    m02_bvalid => m02_bvalid,
    m02_bready => m02_bready,
    m02_bid => m02_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 3 connections {{{
    -- ar channel
    m03_araddr => m03_araddr,
    m03_arlen => m03_arlen,
    m03_arsize => m03_arsize,
    m03_arburst => m03_arburst,
    m03_arvalid => m03_arvalid,
    m03_arready => m03_arready,
    m03_arid => m03_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m03_rdata => m03_rdata,
    m03_rresp => m03_rresp,
    m03_rlast => m03_rlast,
    m03_rvalid => m03_rvalid,
    m03_rready => m03_rready,
    m03_rid => m03_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m03_awvalid => m03_awvalid,
    m03_awaddr => m03_awaddr,
    m03_awready => m03_awready,
    m03_awlen => m03_awlen,
    m03_awsize => m03_awsize,
    m03_awburst => m03_awburst,
    m03_awid => m03_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m03_wdata => m03_wdata,
    m03_wstrb => m03_wstrb,
    m03_wlast => m03_wlast,
    m03_wvalid => m03_wvalid,
    m03_wready => m03_wready,
    -- b channel
    m03_bvalid => m03_bvalid,
    m03_bready => m03_bready,
    m03_bid => m03_bid(ID_WIDTH-1 downto 0), 
    -- }}}
    -- axi master 4 connections {{{
    -- ar channel
    m04_araddr => m04_araddr,
    m04_arlen => m04_arlen,
    m04_arsize => m04_arsize,
    m04_arburst => m04_arburst,
    m04_arvalid => m04_arvalid,
    m04_arready => m04_arready,
    m04_arid => m04_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m04_rdata => m04_rdata,
    m04_rresp => m04_rresp,
    m04_rlast => m04_rlast,
    m04_rvalid => m04_rvalid,
    m04_rready => m04_rready,
    m04_rid => m04_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m04_awvalid => m04_awvalid,
    m04_awaddr => m04_awaddr,
    m04_awready => m04_awready,
    m04_awlen => m04_awlen,
    m04_awsize => m04_awsize,
    m04_awburst => m04_awburst,
    m04_awid => m04_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m04_wdata => m04_wdata,
    m04_wstrb => m04_wstrb,
    m04_wlast => m04_wlast,
    m04_wvalid => m04_wvalid,
    m04_wready => m04_wready,
    -- b channel
    m04_bvalid => m04_bvalid,
    m04_bready => m04_bready,
    m04_bid => m04_bid(ID_WIDTH-1 downto 0),
    -- }}}    
    -- axi master 5 connections {{{
    -- ar channel
    m05_araddr => m05_araddr,
    m05_arlen => m05_arlen,
    m05_arsize => m05_arsize,
    m05_arburst => m05_arburst,
    m05_arvalid => m05_arvalid,
    m05_arready => m05_arready,
    m05_arid => m05_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m05_rdata => m05_rdata,
    m05_rresp => m05_rresp,
    m05_rlast => m05_rlast,
    m05_rvalid => m05_rvalid,
    m05_rready => m05_rready,
    m05_rid => m05_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m05_awvalid => m05_awvalid,
    m05_awaddr => m05_awaddr,
    m05_awready => m05_awready,
    m05_awlen => m05_awlen,
    m05_awsize => m05_awsize,
    m05_awburst => m05_awburst,
    m05_awid => m05_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m05_wdata => m05_wdata,
    m05_wstrb => m05_wstrb,
    m05_wlast => m05_wlast,
    m05_wvalid => m05_wvalid,
    m05_wready => m05_wready,
    -- b channel
    m05_bvalid => m05_bvalid,
    m05_bready => m05_bready,
    m05_bid => m05_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 6 connections {{{
    -- ar channel
    m06_araddr => m06_araddr,
    m06_arlen => m06_arlen,
    m06_arsize => m06_arsize,
    m06_arburst => m06_arburst,
    m06_arvalid => m06_arvalid,
    m06_arready => m06_arready,
    m06_arid => m06_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m06_rdata => m06_rdata,
    m06_rresp => m06_rresp,
    m06_rlast => m06_rlast,
    m06_rvalid => m06_rvalid,
    m06_rready => m06_rready,
    m06_rid => m06_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m06_awvalid => m06_awvalid,
    m06_awaddr => m06_awaddr,
    m06_awready => m06_awready,
    m06_awlen => m06_awlen,
    m06_awsize => m06_awsize,
    m06_awburst => m06_awburst,
    m06_awid => m06_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m06_wdata => m06_wdata,
    m06_wstrb => m06_wstrb,
    m06_wlast => m06_wlast,
    m06_wvalid => m06_wvalid,
    m06_wready => m06_wready,
    -- b channel
    m06_bvalid => m06_bvalid,
    m06_bready => m06_bready,
    m06_bid => m06_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 7 connections {{{
    -- ar channel
    m07_araddr => m07_araddr,
    m07_arlen => m07_arlen,
    m07_arsize => m07_arsize,
    m07_arburst => m07_arburst,
    m07_arvalid => m07_arvalid,
    m07_arready => m07_arready,
    m07_arid => m07_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m07_rdata => m07_rdata,
    m07_rresp => m07_rresp,
    m07_rlast => m07_rlast,
    m07_rvalid => m07_rvalid,
    m07_rready => m07_rready,
    m07_rid => m07_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m07_awvalid => m07_awvalid,
    m07_awaddr => m07_awaddr,
    m07_awready => m07_awready,
    m07_awlen => m07_awlen,
    m07_awsize => m07_awsize,
    m07_awburst => m07_awburst,
    m07_awid => m07_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m07_wdata => m07_wdata,
    m07_wstrb => m07_wstrb,
    m07_wlast => m07_wlast,
    m07_wvalid => m07_wvalid,
    m07_wready => m07_wready,
    -- b channel
    m07_bvalid => m07_bvalid,
    m07_bready => m07_bready,
    m07_bid => m07_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 8 connections {{{
    -- ar channel
    m08_araddr => m08_araddr,
    m08_arlen => m08_arlen,
    m08_arsize => m08_arsize,
    m08_arburst => m08_arburst,
    m08_arvalid => m08_arvalid,
    m08_arready => m08_arready,
    m08_arid => m08_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m08_rdata => m08_rdata,
    m08_rresp => m08_rresp,
    m08_rlast => m08_rlast,
    m08_rvalid => m08_rvalid,
    m08_rready => m08_rready,
    m08_rid => m08_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m08_awvalid => m08_awvalid,
    m08_awaddr => m08_awaddr,
    m08_awready => m08_awready,
    m08_awlen => m08_awlen,
    m08_awsize => m08_awsize,
    m08_awburst => m08_awburst,
    m08_awid => m08_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m08_wdata => m08_wdata,
    m08_wstrb => m08_wstrb,
    m08_wlast => m08_wlast,
    m08_wvalid => m08_wvalid,
    m08_wready => m08_wready,
    -- b channel
    m08_bvalid => m08_bvalid,
    m08_bready => m08_bready,
    m08_bid => m08_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 9 connections {{{
    -- ar channel
    m09_araddr => m09_araddr,
    m09_arlen => m09_arlen,
    m09_arsize => m09_arsize,
    m09_arburst => m09_arburst,
    m09_arvalid => m09_arvalid,
    m09_arready => m09_arready,
    m09_arid => m09_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m09_rdata => m09_rdata,
    m09_rresp => m09_rresp,
    m09_rlast => m09_rlast,
    m09_rvalid => m09_rvalid,
    m09_rready => m09_rready,
    m09_rid => m09_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m09_awvalid => m09_awvalid,
    m09_awaddr => m09_awaddr,
    m09_awready => m09_awready,
    m09_awlen => m09_awlen,
    m09_awsize => m09_awsize,
    m09_awburst => m09_awburst,
    m09_awid => m09_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m09_wdata => m09_wdata,
    m09_wstrb => m09_wstrb,
    m09_wlast => m09_wlast,
    m09_wvalid => m09_wvalid,
    m09_wready => m09_wready,
    -- b channel
    m09_bvalid => m09_bvalid,
    m09_bready => m09_bready,
    m09_bid => m09_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 10 connections {{{
    -- ar channel
    m10_araddr => m10_araddr,
    m10_arlen => m10_arlen,
    m10_arsize => m10_arsize,
    m10_arburst => m10_arburst,
    m10_arvalid => m10_arvalid,
    m10_arready => m10_arready,
    m10_arid => m10_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m10_rdata => m10_rdata,
    m10_rresp => m10_rresp,
    m10_rlast => m10_rlast,
    m10_rvalid => m10_rvalid,
    m10_rready => m10_rready,
    m10_rid => m10_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m10_awvalid => m10_awvalid,
    m10_awaddr => m10_awaddr,
    m10_awready => m10_awready,
    m10_awlen => m10_awlen,
    m10_awsize => m10_awsize,
    m10_awburst => m10_awburst,
    m10_awid => m10_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m10_wdata => m10_wdata,
    m10_wstrb => m10_wstrb,
    m10_wlast => m10_wlast,
    m10_wvalid => m10_wvalid,
    m10_wready => m10_wready,
    -- b channel
    m10_bvalid => m10_bvalid,
    m10_bready => m10_bready,
    m10_bid => m10_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 11 connections {{{
    -- ar channel
    m11_araddr => m11_araddr,
    m11_arlen => m11_arlen,
    m11_arsize => m11_arsize,
    m11_arburst => m11_arburst,
    m11_arvalid => m11_arvalid,
    m11_arready => m11_arready,
    m11_arid => m11_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m11_rdata => m11_rdata,
    m11_rresp => m11_rresp,
    m11_rlast => m11_rlast,
    m11_rvalid => m11_rvalid,
    m11_rready => m11_rready,
    m11_rid => m11_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m11_awvalid => m11_awvalid,
    m11_awaddr => m11_awaddr,
    m11_awready => m11_awready,
    m11_awlen => m11_awlen,
    m11_awsize => m11_awsize,
    m11_awburst => m11_awburst,
    m11_awid => m11_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m11_wdata => m11_wdata,
    m11_wstrb => m11_wstrb,
    m11_wlast => m11_wlast,
    m11_wvalid => m11_wvalid,
    m11_wready => m11_wready,
    -- b channel
    m11_bvalid => m11_bvalid,
    m11_bready => m11_bready,
    m11_bid => m11_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 12 connections {{{
    -- ar channel
    m12_araddr => m12_araddr,
    m12_arlen => m12_arlen,
    m12_arsize => m12_arsize,
    m12_arburst => m12_arburst,
    m12_arvalid => m12_arvalid,
    m12_arready => m12_arready,
    m12_arid => m12_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m12_rdata => m12_rdata,
    m12_rresp => m12_rresp,
    m12_rlast => m12_rlast,
    m12_rvalid => m12_rvalid,
    m12_rready => m12_rready,
    m12_rid => m12_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m12_awvalid => m12_awvalid,
    m12_awaddr => m12_awaddr,
    m12_awready => m12_awready,
    m12_awlen => m12_awlen,
    m12_awsize => m12_awsize,
    m12_awburst => m12_awburst,
    m12_awid => m12_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m12_wdata => m12_wdata,
    m12_wstrb => m12_wstrb,
    m12_wlast => m12_wlast,
    m12_wvalid => m12_wvalid,
    m12_wready => m12_wready,
    -- b channel
    m12_bvalid => m12_bvalid,
    m12_bready => m12_bready,
    m12_bid => m12_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 13 connections {{{
    -- ar channel
    m13_araddr => m13_araddr,
    m13_arlen => m13_arlen,
    m13_arsize => m13_arsize,
    m13_arburst => m13_arburst,
    m13_arvalid => m13_arvalid,
    m13_arready => m13_arready,
    m13_arid => m13_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m13_rdata => m13_rdata,
    m13_rresp => m13_rresp,
    m13_rlast => m13_rlast,
    m13_rvalid => m13_rvalid,
    m13_rready => m13_rready,
    m13_rid => m13_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m13_awvalid => m13_awvalid,
    m13_awaddr => m13_awaddr,
    m13_awready => m13_awready,
    m13_awlen => m13_awlen,
    m13_awsize => m13_awsize,
    m13_awburst => m13_awburst,
    m13_awid => m13_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m13_wdata => m13_wdata,
    m13_wstrb => m13_wstrb,
    m13_wlast => m13_wlast,
    m13_wvalid => m13_wvalid,
    m13_wready => m13_wready,
    -- b channel
    m13_bvalid => m13_bvalid,
    m13_bready => m13_bready,
    m13_bid => m13_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 14 connections {{{
    -- ar channel
    m14_araddr => m14_araddr,
    m14_arlen => m14_arlen,
    m14_arsize => m14_arsize,
    m14_arburst => m14_arburst,
    m14_arvalid => m14_arvalid,
    m14_arready => m14_arready,
    m14_arid => m14_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m14_rdata => m14_rdata,
    m14_rresp => m14_rresp,
    m14_rlast => m14_rlast,
    m14_rvalid => m14_rvalid,
    m14_rready => m14_rready,
    m14_rid => m14_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m14_awvalid => m14_awvalid,
    m14_awaddr => m14_awaddr,
    m14_awready => m14_awready,
    m14_awlen => m14_awlen,
    m14_awsize => m14_awsize,
    m14_awburst => m14_awburst,
    m14_awid => m14_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m14_wdata => m14_wdata,
    m14_wstrb => m14_wstrb,
    m14_wlast => m14_wlast,
    m14_wvalid => m14_wvalid,
    m14_wready => m14_wready,
    -- b channel
    m14_bvalid => m14_bvalid,
    m14_bready => m14_bready,
    m14_bid => m14_bid(ID_WIDTH-1 downto 0),
    -- }}}
    -- axi master 15 connections {{{
    -- ar channel
    m15_araddr => m15_araddr,
    m15_arlen => m15_arlen,
    m15_arsize => m15_arsize,
    m15_arburst => m15_arburst,
    m15_arvalid => m15_arvalid,
    m15_arready => m15_arready,
    m15_arid => m15_arid(ID_WIDTH-1 downto 0),
    -- r channel
    m15_rdata => m15_rdata,
    m15_rresp => m15_rresp,
    m15_rlast => m15_rlast,
    m15_rvalid => m15_rvalid,
    m15_rready => m15_rready,
    m15_rid => m15_rid(ID_WIDTH-1 downto 0),
    -- aw channel
    m15_awvalid => m15_awvalid,
    m15_awaddr => m15_awaddr,
    m15_awready => m15_awready,
    m15_awlen => m15_awlen,
    m15_awsize => m15_awsize,
    m15_awburst => m15_awburst,
    m15_awid => m15_awid(ID_WIDTH-1 downto 0),
    -- w channel
    m15_wdata => m15_wdata,
    m15_wstrb => m15_wstrb,
    m15_wlast => m15_wlast,
    m15_wvalid => m15_wvalid,
    m15_wready => m15_wready,
    -- b channel
    m15_bvalid => m15_bvalid,
    m15_bready => m15_bready,
    m15_bid => m15_bid(ID_WIDTH-1 downto 0)
    -- }}}
  );

    --to manage the ID_WIDTH, without modifying the top
  id_width_check: if ID_WIDTH /= 4 generate
    id_width_adapter: for i in 3 downto ID_WIDTH generate
      m00_arid(i) <= '0';
      m00_awid(i) <= '0';
      m01_arid(i) <= '0';
      m01_awid(i) <= '0';
      m02_arid(i) <= '0';
      m02_awid(i) <= '0';
      m03_arid(i) <= '0';
      m03_awid(i) <= '0';
      m04_arid(i) <= '0';
      m04_awid(i) <= '0';
      m05_arid(i) <= '0';
      m05_awid(i) <= '0';
      m06_arid(i) <= '0';
      m06_awid(i) <= '0';
      m07_arid(i) <= '0';
      m07_awid(i) <= '0';
      m08_arid(i) <= '0';
      m08_awid(i) <= '0';
      m09_arid(i) <= '0';
      m09_awid(i) <= '0';
      m10_arid(i) <= '0';
      m10_awid(i) <= '0';
      m11_arid(i) <= '0';
      m11_awid(i) <= '0';
      m12_arid(i) <= '0';
      m12_awid(i) <= '0';
      m13_arid(i) <= '0';
      m13_awid(i) <= '0';
      m14_arid(i) <= '0';
      m14_awid(i) <= '0';
      m15_arid(i) <= '0';
      m15_awid(i) <= '0';
    end generate;
  end generate;

end arch_imp;
