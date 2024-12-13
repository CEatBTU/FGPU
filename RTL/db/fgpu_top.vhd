-- libraries --------------------------------------------------------------------------------- {{{
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library fgpu;
use fgpu.definitions.all;
use fgpu.components.all;
------------------------------------------------------------------------------------------------- }}}
entity fgpu_top is
-- Generics & ports {{{
generic (
  DEBUG_MODE : boolean := false
);
port(
  clk  : in  std_logic;
  nrst : in  std_logic;
  -- Contorl Interface - AXI LITE SLAVE {{{
  s_awaddr           : in std_logic_vector(INTERFCE_W_ADDR_W-1 downto 0);
  s_awprot           : in std_logic_vector(2 downto 0);
  s_awvalid          : in std_logic;
  s_awready          : out std_logic;

  s_wdata            : in std_logic_vector(DATA_W-1 downto 0);
  s_wstrb            : in std_logic_vector((DATA_W/8)-1 downto 0);
  s_wvalid           : in std_logic;
  s_wready           : out std_logic;

  s_bresp            : out std_logic_vector(1 downto 0);
  s_bvalid           : out std_logic;
  s_bready           : in std_logic;

  s_araddr           : in std_logic_vector(INTERFCE_W_ADDR_W-1 downto 0);
  s_arprot           : in std_logic_vector(2 downto 0);
  s_arvalid          : in std_logic;
  s_arready          : out std_logic;

  s_rdata            : out std_logic_vector(DATA_W-1 downto 0);
  s_rresp            : out std_logic_vector(1 downto 0);
  s_rvalid           : out std_logic;
  s_rready           : in std_logic;
  -- }}}
  m00_araddr  : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m00_arlen   : out std_logic_vector(7 downto 0);
  m00_arsize  : out std_logic_vector(2 downto 0);
  m00_arburst : out std_logic_vector(1 downto 0);
  m00_arvalid : out std_logic;
  m00_arready : in std_logic;
  m00_arid    : out std_logic_vector(ID_WIDTH-1 downto 0);
  m00_rdata   : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m00_rresp   : in std_logic_vector(1 downto 0);
  m00_rlast   : in std_logic;
  m00_rvalid  : in std_logic;
  m00_rready  : out std_logic;
  m00_rid     : in std_logic_vector(ID_WIDTH-1 downto 0);
  m00_awaddr  : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m00_awvalid : out std_logic;
  m00_awready : in std_logic;
  m00_awlen   : out std_logic_vector(7 downto 0);
  m00_awsize  : out std_logic_vector(2 downto 0);
  m00_awburst : out std_logic_vector(1 downto 0);
  m00_awid    : out std_logic_vector(ID_WIDTH-1 downto 0);
  m00_wdata   : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m00_wstrb   : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m00_wlast   : out std_logic;
  m00_wvalid  : out std_logic;
  m00_wready  : in std_logic;
  m00_bvalid  : in std_logic;
  m00_bready  : out std_logic;
  m00_bid     : in std_logic_vector(ID_WIDTH-1 downto 0);

  m01_araddr  : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m01_arlen   : out std_logic_vector(7 downto 0);
  m01_arsize  : out std_logic_vector(2 downto 0);
  m01_arburst : out std_logic_vector(1 downto 0);
  m01_arvalid : out std_logic;
  m01_arready : in std_logic;
  m01_arid    : out std_logic_vector(ID_WIDTH-1 downto 0);
  m01_rdata   : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m01_rresp   : in std_logic_vector(1 downto 0);
  m01_rlast   : in std_logic;
  m01_rvalid  : in std_logic;
  m01_rready  : out std_logic;
  m01_rid     : in std_logic_vector(ID_WIDTH-1 downto 0);
  m01_awaddr  : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m01_awvalid : out std_logic;
  m01_awready : in std_logic;
  m01_awlen   : out std_logic_vector(7 downto 0);
  m01_awsize  : out std_logic_vector(2 downto 0);
  m01_awburst : out std_logic_vector(1 downto 0);
  m01_awid    : out std_logic_vector(ID_WIDTH-1 downto 0);
  m01_wdata   : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m01_wstrb   : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m01_wlast   : out std_logic;
  m01_wvalid  : out std_logic;
  m01_wready  : in std_logic;
  m01_bvalid  : in std_logic;
  m01_bready  : out std_logic;
  m01_bid     : in std_logic_vector(ID_WIDTH-1 downto 0);

  m02_araddr  : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m02_arlen   : out std_logic_vector(7 downto 0);
  m02_arsize  : out std_logic_vector(2 downto 0);
  m02_arburst : out std_logic_vector(1 downto 0);
  m02_arvalid : out std_logic;
  m02_arready : in std_logic;
  m02_arid    : out std_logic_vector(ID_WIDTH-1 downto 0);
  m02_rdata   : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m02_rresp   : in std_logic_vector(1 downto 0);
  m02_rlast   : in std_logic;
  m02_rvalid  : in std_logic;
  m02_rready  : out std_logic;
  m02_rid     : in std_logic_vector(ID_WIDTH-1 downto 0);
  m02_awaddr  : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m02_awvalid : out std_logic;
  m02_awready : in std_logic;
  m02_awlen   : out std_logic_vector(7 downto 0);
  m02_awsize  : out std_logic_vector(2 downto 0);
  m02_awburst : out std_logic_vector(1 downto 0);
  m02_awid    : out std_logic_vector(ID_WIDTH-1 downto 0);
  m02_wdata   : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m02_wstrb   : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m02_wlast   : out std_logic;
  m02_wvalid  : out std_logic;
  m02_wready  : in std_logic;
  m02_bvalid  : in std_logic;
  m02_bready  : out std_logic;
  m02_bid     : in std_logic_vector(ID_WIDTH-1 downto 0);

  m03_araddr  : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m03_arlen   : out std_logic_vector(7 downto 0);
  m03_arsize  : out std_logic_vector(2 downto 0);
  m03_arburst : out std_logic_vector(1 downto 0);
  m03_arvalid : out std_logic;
  m03_arready : in std_logic;
  m03_arid    : out std_logic_vector(ID_WIDTH-1 downto 0);
  m03_rdata   : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m03_rresp   : in std_logic_vector(1 downto 0);
  m03_rlast   : in std_logic;
  m03_rvalid  : in std_logic;
  m03_rready  : out std_logic;
  m03_rid     : in std_logic_vector(ID_WIDTH-1 downto 0);
  m03_awaddr  : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m03_awvalid : out std_logic;
  m03_awready : in std_logic;
  m03_awlen   : out std_logic_vector(7 downto 0);
  m03_awsize  : out std_logic_vector(2 downto 0);
  m03_awburst : out std_logic_vector(1 downto 0);
  m03_awid    : out std_logic_vector(ID_WIDTH-1 downto 0);
  m03_wdata   : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m03_wstrb   : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m03_wlast   : out std_logic;
  m03_wvalid  : out std_logic;
  m03_wready  : in std_logic;
  m03_bvalid  : in std_logic;
  m03_bready  : out std_logic;
  m03_bid     : in std_logic_vector(ID_WIDTH-1 downto 0);

  m04_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m04_arlen            : out std_logic_vector(7 downto 0);
  m04_arsize           : out std_logic_vector(2 downto 0);
  m04_arburst          : out std_logic_vector(1 downto 0);
  m04_arvalid          : out std_logic;
  m04_arready          : in std_logic;
  m04_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m04_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m04_rresp            : in std_logic_vector(1 downto 0);
  m04_rlast            : in std_logic;
  m04_rvalid           : in std_logic;
  m04_rready           : out std_logic;
  m04_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m04_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m04_awvalid          : out std_logic;
  m04_awready          : in std_logic;
  m04_awlen            : out std_logic_vector(7 downto 0);
  m04_awsize           : out std_logic_vector(2 downto 0);
  m04_awburst          : out std_logic_vector(1 downto 0);
  m04_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m04_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m04_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m04_wlast            : out std_logic;
  m04_wvalid           : out std_logic;
  m04_wready           : in std_logic;
  m04_bvalid           : in std_logic;
  m04_bready           : out std_logic;
  m04_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m05_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m05_arlen            : out std_logic_vector(7 downto 0);
  m05_arsize           : out std_logic_vector(2 downto 0);
  m05_arburst          : out std_logic_vector(1 downto 0);
  m05_arvalid          : out std_logic;
  m05_arready          : in std_logic;
  m05_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m05_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m05_rresp            : in std_logic_vector(1 downto 0);
  m05_rlast            : in std_logic;
  m05_rvalid           : in std_logic;
  m05_rready           : out std_logic;
  m05_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m05_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m05_awvalid          : out std_logic;
  m05_awready          : in std_logic;
  m05_awlen            : out std_logic_vector(7 downto 0);
  m05_awsize           : out std_logic_vector(2 downto 0);
  m05_awburst          : out std_logic_vector(1 downto 0);
  m05_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m05_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m05_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m05_wlast            : out std_logic;
  m05_wvalid           : out std_logic;
  m05_wready           : in std_logic;
  m05_bvalid           : in std_logic;
  m05_bready           : out std_logic;
  m05_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m06_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m06_arlen            : out std_logic_vector(7 downto 0);
  m06_arsize           : out std_logic_vector(2 downto 0);
  m06_arburst          : out std_logic_vector(1 downto 0);
  m06_arvalid          : out std_logic;
  m06_arready          : in std_logic;
  m06_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m06_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m06_rresp            : in std_logic_vector(1 downto 0);
  m06_rlast            : in std_logic;
  m06_rvalid           : in std_logic;
  m06_rready           : out std_logic;
  m06_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m06_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m06_awvalid          : out std_logic;
  m06_awready          : in std_logic;
  m06_awlen            : out std_logic_vector(7 downto 0);
  m06_awsize           : out std_logic_vector(2 downto 0);
  m06_awburst          : out std_logic_vector(1 downto 0);
  m06_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m06_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m06_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m06_wlast            : out std_logic;
  m06_wvalid           : out std_logic;
  m06_wready           : in std_logic;
  m06_bvalid           : in std_logic;
  m06_bready           : out std_logic;
  m06_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m07_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m07_arlen            : out std_logic_vector(7 downto 0);
  m07_arsize           : out std_logic_vector(2 downto 0);
  m07_arburst          : out std_logic_vector(1 downto 0);
  m07_arvalid          : out std_logic;
  m07_arready          : in std_logic;
  m07_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m07_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m07_rresp            : in std_logic_vector(1 downto 0);
  m07_rlast            : in std_logic;
  m07_rvalid           : in std_logic;
  m07_rready           : out std_logic;
  m07_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m07_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m07_awvalid          : out std_logic;
  m07_awready          : in std_logic;
  m07_awlen            : out std_logic_vector(7 downto 0);
  m07_awsize           : out std_logic_vector(2 downto 0);
  m07_awburst          : out std_logic_vector(1 downto 0);
  m07_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m07_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m07_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m07_wlast            : out std_logic;
  m07_wvalid           : out std_logic;
  m07_wready           : in std_logic;
  m07_bvalid           : in std_logic;
  m07_bready           : out std_logic;
  m07_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m08_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m08_arlen            : out std_logic_vector(7 downto 0);
  m08_arsize           : out std_logic_vector(2 downto 0);
  m08_arburst          : out std_logic_vector(1 downto 0);
  m08_arvalid          : out std_logic;
  m08_arready          : in std_logic;
  m08_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m08_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m08_rresp            : in std_logic_vector(1 downto 0);
  m08_rlast            : in std_logic;
  m08_rvalid           : in std_logic;
  m08_rready           : out std_logic;
  m08_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m08_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m08_awvalid          : out std_logic;
  m08_awready          : in std_logic;
  m08_awlen            : out std_logic_vector(7 downto 0);
  m08_awsize           : out std_logic_vector(2 downto 0);
  m08_awburst          : out std_logic_vector(1 downto 0);
  m08_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m08_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m08_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m08_wlast            : out std_logic;
  m08_wvalid           : out std_logic;
  m08_wready           : in std_logic;
  m08_bvalid           : in std_logic;
  m08_bready           : out std_logic;
  m08_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m09_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m09_arlen            : out std_logic_vector(7 downto 0);
  m09_arsize           : out std_logic_vector(2 downto 0);
  m09_arburst          : out std_logic_vector(1 downto 0);
  m09_arvalid          : out std_logic;
  m09_arready          : in std_logic;
  m09_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m09_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m09_rresp            : in std_logic_vector(1 downto 0);
  m09_rlast            : in std_logic;
  m09_rvalid           : in std_logic;
  m09_rready           : out std_logic;
  m09_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m09_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m09_awvalid          : out std_logic;
  m09_awready          : in std_logic;
  m09_awlen            : out std_logic_vector(7 downto 0);
  m09_awsize           : out std_logic_vector(2 downto 0);
  m09_awburst          : out std_logic_vector(1 downto 0);
  m09_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m09_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m09_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m09_wlast            : out std_logic;
  m09_wvalid           : out std_logic;
  m09_wready           : in std_logic;
  m09_bvalid           : in std_logic;
  m09_bready           : out std_logic;
  m09_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m10_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m10_arlen            : out std_logic_vector(7 downto 0);
  m10_arsize           : out std_logic_vector(2 downto 0);
  m10_arburst          : out std_logic_vector(1 downto 0);
  m10_arvalid          : out std_logic;
  m10_arready          : in std_logic;
  m10_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m10_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m10_rresp            : in std_logic_vector(1 downto 0);
  m10_rlast            : in std_logic;
  m10_rvalid           : in std_logic;
  m10_rready           : out std_logic;
  m10_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m10_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m10_awvalid          : out std_logic;
  m10_awready          : in std_logic;
  m10_awlen            : out std_logic_vector(7 downto 0);
  m10_awsize           : out std_logic_vector(2 downto 0);
  m10_awburst          : out std_logic_vector(1 downto 0);
  m10_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m10_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m10_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m10_wlast            : out std_logic;
  m10_wvalid           : out std_logic;
  m10_wready           : in std_logic;
  m10_bvalid           : in std_logic;
  m10_bready           : out std_logic;
  m10_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m11_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m11_arlen            : out std_logic_vector(7 downto 0);
  m11_arsize           : out std_logic_vector(2 downto 0);
  m11_arburst          : out std_logic_vector(1 downto 0);
  m11_arvalid          : out std_logic;
  m11_arready          : in std_logic;
  m11_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m11_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m11_rresp            : in std_logic_vector(1 downto 0);
  m11_rlast            : in std_logic;
  m11_rvalid           : in std_logic;
  m11_rready           : out std_logic;
  m11_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m11_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m11_awvalid          : out std_logic;
  m11_awready          : in std_logic;
  m11_awlen            : out std_logic_vector(7 downto 0);
  m11_awsize           : out std_logic_vector(2 downto 0);
  m11_awburst          : out std_logic_vector(1 downto 0);
  m11_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m11_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m11_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m11_wlast            : out std_logic;
  m11_wvalid           : out std_logic;
  m11_wready           : in std_logic;
  m11_bvalid           : in std_logic;
  m11_bready           : out std_logic;
  m11_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m12_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m12_arlen            : out std_logic_vector(7 downto 0);
  m12_arsize           : out std_logic_vector(2 downto 0);
  m12_arburst          : out std_logic_vector(1 downto 0);
  m12_arvalid          : out std_logic;
  m12_arready          : in std_logic;
  m12_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m12_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m12_rresp            : in std_logic_vector(1 downto 0);
  m12_rlast            : in std_logic;
  m12_rvalid           : in std_logic;
  m12_rready           : out std_logic;
  m12_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m12_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m12_awvalid          : out std_logic;
  m12_awready          : in std_logic;
  m12_awlen            : out std_logic_vector(7 downto 0);
  m12_awsize           : out std_logic_vector(2 downto 0);
  m12_awburst          : out std_logic_vector(1 downto 0);
  m12_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m12_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m12_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m12_wlast            : out std_logic;
  m12_wvalid           : out std_logic;
  m12_wready           : in std_logic;
  m12_bvalid           : in std_logic;
  m12_bready           : out std_logic;
  m12_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m13_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m13_arlen            : out std_logic_vector(7 downto 0);
  m13_arsize           : out std_logic_vector(2 downto 0);
  m13_arburst          : out std_logic_vector(1 downto 0);
  m13_arvalid          : out std_logic;
  m13_arready          : in std_logic;
  m13_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m13_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m13_rresp            : in std_logic_vector(1 downto 0);
  m13_rlast            : in std_logic;
  m13_rvalid           : in std_logic;
  m13_rready           : out std_logic;
  m13_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m13_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m13_awvalid          : out std_logic;
  m13_awready          : in std_logic;
  m13_awlen            : out std_logic_vector(7 downto 0);
  m13_awsize           : out std_logic_vector(2 downto 0);
  m13_awburst          : out std_logic_vector(1 downto 0);
  m13_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m13_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m13_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m13_wlast            : out std_logic;
  m13_wvalid           : out std_logic;
  m13_wready           : in std_logic;
  m13_bvalid           : in std_logic;
  m13_bready           : out std_logic;
  m13_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m14_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m14_arlen            : out std_logic_vector(7 downto 0);
  m14_arsize           : out std_logic_vector(2 downto 0);
  m14_arburst          : out std_logic_vector(1 downto 0);
  m14_arvalid          : out std_logic;
  m14_arready          : in std_logic;
  m14_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m14_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m14_rresp            : in std_logic_vector(1 downto 0);
  m14_rlast            : in std_logic;
  m14_rvalid           : in std_logic;
  m14_rready           : out std_logic;
  m14_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m14_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m14_awvalid          : out std_logic;
  m14_awready          : in std_logic;
  m14_awlen            : out std_logic_vector(7 downto 0);
  m14_awsize           : out std_logic_vector(2 downto 0);
  m14_awburst          : out std_logic_vector(1 downto 0);
  m14_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m14_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m14_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m14_wlast            : out std_logic;
  m14_wvalid           : out std_logic;
  m14_wready           : in std_logic;
  m14_bvalid           : in std_logic;
  m14_bready           : out std_logic;
  m14_bid              : in std_logic_vector(ID_WIDTH-1 downto 0);

  m15_araddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0);
  m15_arlen            : out std_logic_vector(7 downto 0);
  m15_arsize           : out std_logic_vector(2 downto 0);
  m15_arburst          : out std_logic_vector(1 downto 0);
  m15_arvalid          : out std_logic;
  m15_arready          : in std_logic;
  m15_arid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;

  m15_rdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
  m15_rresp            : in std_logic_vector(1 downto 0);
  m15_rlast            : in std_logic;
  m15_rvalid           : in std_logic;
  m15_rready           : out std_logic;
  m15_rid              : in std_logic_vector(ID_WIDTH-1 downto 0);
  m15_awaddr           : out std_logic_vector(GMEM_ADDR_W-1 downto 0) ;
  m15_awvalid          : out std_logic;
  m15_awready          : in std_logic;
  m15_awlen            : out std_logic_vector(7 downto 0);
  m15_awsize           : out std_logic_vector(2 downto 0);
  m15_awburst          : out std_logic_vector(1 downto 0);
  m15_awid             : out std_logic_vector(ID_WIDTH-1 downto 0) ;
  m15_wdata            : out std_logic_vector(DATA_W*GMEM_N_BANK-1 downto 0);
  m15_wstrb            : out std_logic_vector(DATA_W*GMEM_N_BANK/8-1 downto 0);
  m15_wlast            : out std_logic;
  m15_wvalid           : out std_logic;
  m15_wready           : in std_logic;
  m15_bvalid           : in std_logic;
  m15_bready           : out std_logic;
  m15_bid              : in std_logic_vector(ID_WIDTH-1 downto 0)
  );
-- ports }}}
end entity;

architecture Behavioral of fgpu_top is

  -- slave axi interface {{{
  signal mainProc_we                      : std_logic;
    -- LRAM/CRAM/Reg files write enable
  signal mainProc_wrAddr                  : unsigned(INTERFCE_W_ADDR_W-1 downto 0);
    -- LRAM/CRAM/Reg files write address
  signal mainProc_rdAddr                  : unsigned(INTERFCE_W_ADDR_W-1 downto 0);
    -- LRAM/CRAM/Reg files read address
  signal s_rvalid_vec                     : std_logic_vector(3 downto 0);
    -- signal used to add latency on r channel (wait 2 cycles after ar channel completes)
  signal s_wdata_d0                       : std_logic_vector(DATA_W-1 downto 0);
    -- registered s_wdata
  signal s_awready_i                      : std_logic;
    -- AXI slave port write address ready
  signal s_bvalid_i                       : std_logic;
    -- AXI slave port bvalid
  signal s_wready_i                       : std_logic;
    -- AXI slave port write ready
  signal s_arready_i                      : std_logic;
    -- AXI slave port read address ready
  -- }}}

  -- Link RAM {{{
  -- signal KRNL_SCHEDULER_RAM              : KRNL_SCHEDULER_RAM_type := init_krnl_ram("krnl_ram.mif");
  signal krnl_scheduler_ram               : krnl_scheduler_ram_type := (others => (others => '0'));
    -- Link RAM memory
  signal krnl_sch_we                      : std_logic;
    -- LRAM write enable
  signal krnl_sch_rdData_n                : std_logic_vector(DATA_W-1 downto 0);
    -- LRAM read data
  signal krnl_sch_rdData                  : std_logic_vector(DATA_W-1 downto 0);
    -- registered krnl_sch_rdData_n
  signal krnl_sch_rdAddr                  : unsigned(KRNL_SCH_ADDR_W-1 downto 0);
    -- LRAM read address
  signal krnl_sch_rdAddr_WGD              : std_logic_vector(KRNL_SCH_ADDR_W-1 downto 0);
  -- }}}

  -- Code RAM {{{
  -- signal cram_b1                          : CRAM_type := init_CRAM("cram.mif", 3000);
  signal cram_b1                          : cram_type := (others => (others => '0'));
    -- Code RAM memory
  signal cram_we                          : std_logic;
  -- signal cram_rdData, cram_rdData_n       : SLV32_ARRAY(CRAM_BLOCKS-1 downto 0);
  -- signal cram_rdAddr, cram_rdAddr_d0      : CRAM_ADDR_ARRAY(CRAM_BLOCKS-1 downto 0);
  signal cram_rdData, cram_rdData_n       : std_logic_vector(DATA_W-1 downto 0);
    -- CRAM read data
  signal cram_rdData_vec                  : slv32_array(max(N_CU-1, 0) downto 0);
    -- cram_rdData_vec(N_CU-1 downto 0) <= cram_rdData & cram_rdData_vec(N_CU-1 downto 1)
  signal cram_rdAddr, cram_rdAddr_d0      : unsigned(CRAM_ADDR_W-1 downto 0);
    -- CRAM read address
  signal cram_rdAddr_d0_vec               : cram_addr_array(max(N_CU-1, 0) downto 0);
	-- cram_rdAddr_d0_vec(N_CU-1 downto 0) <= cram_rdAddr_d0 & cram_rdAddr_d0_vec(N_CU-1 downto 1)
  -- }}}

  -- Register File {{{
  signal regFile_we                       : std_logic;
    -- register file write enable
  signal Rstat                            : std_logic_vector(NEW_KRNL_MAX_INDX-1 downto 0);
    -- Rstat register
  signal Rstart                           : std_logic_vector(NEW_KRNL_MAX_INDX-1 downto 0);
    -- Rstart register
  signal RcleanCache                      : std_logic_vector(NEW_KRNL_MAX_INDX-1 downto 0);
    -- RcleanCache register
  signal RInitiate                        : std_logic_vector(NEW_KRNL_MAX_INDX-1 downto 0);
    -- RInitiate register
  -- signal regFile_we_d0                 : std_logic;
  -- }}}

  -- WG dispatcher FSM {{{

  type WG_dispatcher_state_type is (idle, st1_dispatch);
  type wg_req_vec_type is array(natural range <>) of std_logic_vector(N_CU-1 downto 0);
  type sch_rqst_n_WFs_m01_vec_type is array (natural range <>) of unsigned(N_WF_CU_W-1 downto 0);
  type rtm_addr_vec_type is array (natural range<>) of unsigned(RTM_ADDR_W-1 downto 0);

  signal st_wg_disp, st_wg_disp_n         : WG_dispatcher_state_type;
    -- state of the WG dispatcher

  signal new_krnl_indx                    : integer range 0 to NEW_KRNL_MAX_INDX-1;
    -- index of the new kernel to be executed (extracted from the Rstart control register)

  signal start_kernel                     : std_logic;
    -- signal set to '1' when the WG Dispatcher FSM leaves the "idle" state
  signal clean_cache                      : std_logic;
    -- signal set to '1' to flush the cache into the global memory when starting a new kernel
  signal start_CUs                        : std_logic;
    -- signal set to '1' when entering the WG dispatcher scheduling phase
  signal initialize_d0                    : std_logic;
    -- initialize flag for the new kernel to be executed extracted from the Rinitiate control register
  signal start_CUs_vec                    : std_logic_vector(max(N_CU-1, 0) downto 0); -- to improve timing
	-- start_CUs_vec(N_CU-1 downto 0) <= start_CUs & start_CUs_vec(N_CU-1 downto 1)
  signal finish_exec, finish_exec_d0      : std_logic;
    -- signal high when execution of a kernel is done
  signal WGsDispatched                    : std_logic;
    -- signal high when WG Dispatcher has scheduled all WGs
  signal finish_krnl_indx                 : integer range 0 to NEW_KRNL_MAX_INDX-1;
    -- i-th set to '1' when the i-th kernel has been processed (provided by the WG Dispatcher)
  signal wg_req                           : std_logic_vector(N_CU-1 downto 0);
    -- request signal to allocate WGs on CUs
  signal wg_ack                           : std_logic_vector(N_CU-1 downto 0);
    -- signal from CUs to acknowledge the scheduling request
  signal wg_req_vec                       : wg_req_vec_type(max(N_CU-1, 0) downto 0);
    -- wg_req_vec(N_CU-1 downto 0) <= wg_req & wg_req_vec(N_CU-1 downto 1)
  signal wg_ack_vec                       : wg_req_vec_type(max(N_CU-1, 0) downto 0);
    -- ..                                                                                                                ---------------------------------- Unused signal
  signal CU_cram_rqst                     : std_logic_vector(N_CU-1 downto 0);
    -- CU request signal to read CRAM
  signal sch_rqst_n_WFs_m1                : unsigned(N_WF_CU_W-1 downto 0);
    -- number of WFs in the WG to be scheduled
  signal sch_rqst_n_WFs_m01_vec            : sch_rqst_n_WFs_m01_vec_type(max(N_CU-1, 0) downto 0);
	-- sch_rqst_n_WFs_m01_vec(N_CU-1 downto 0) <= sch_rqst_n_WFs_m1 & sch_rqst_n_WFs_m01_vec(N_CU-1 downto 1)
  signal cram_served_CUs                  : std_logic;
    -- one-bit-toggle to serve different CUs when fetching instructions

  signal CU_cram_rdAddr                   : cram_addr_array(N_CU-1 downto 0);
    -- CRAM read address vector provided by the CUs
  signal start_addr                       : unsigned(CRAM_ADDR_W-1 downto 0);
    -- the address of the first instruction to be fetched, provided by the WG dispatcher
  signal start_addr_vec                   : cram_addr_array(max(N_CU-1, 0) downto 0); -- just to improve timing
	-- start_addr_vec(N_CU-1 downto 0) <= start_addr & start_addr_vec(N_CU-1 downto 1)


  signal rdData_alu_en                    : alu_en_vec_type(N_CU-1 downto 0);
    -- read data alu enable
  signal rdAddr_alu_en                    : alu_en_rdAddr_type(N_CU-1 downto 0);
    -- read address alu enable

  signal rtm_wrAddr_wg                    : unsigned(RTM_ADDR_W-1 downto 0);
    -- RTM wg write address
  signal rtm_wrAddr_wg_vec                : rtm_addr_vec_type(max(N_CU-1, 0) downto 0);
	-- rtm_wrAddr_wg_vec(N_CU-1 downto 0) <= rtm_wrAddr_wg & rtm_wrAddr_wg_vec(N_CU-1 downto 1)
  signal rtm_wrData_wg                    : unsigned(RTM_DATA_W-1 downto 0);
    -- RTM wg write data
  signal rtm_wrData_wg_vec                : rtm_ram_type(max(N_CU-1, 0) downto 0);
    -- rtm_wrData_wg_vec(N_CU-1 downto 0) <= rtm_wrData_wg & rtm_wrData_wg_vec(N_CU-1 downto 0)
  signal rtm_we_wg                        : std_logic;
    -- RTM write enable
  signal rtm_we_wg_vec                    : std_logic_vector(max(N_CU-1, 0) downto 0) := (others => '0');
    -- rtm_we_wg_vec(N_CU-1 downto 0) <= rtm_we_wg & rtm_we_wg_vec(N_CU-1 downto 1)
  signal wg_info                          : unsigned(DATA_W-1 downto 0);
    -- offset of the dispatched WG along D0/D1/D2 direction
  signal wg_info_vec                      : slv32_array(max(N_CU-1, 0) downto 0);
    -- wg_info_vec(N_CU-1 downto 0) <= wg_info & wg_info_vec(N_CU-1 downto 1)
  -- }}}

  -- debug {{{
  signal debug_cache_miss_counter           : unsigned(DATA_W-1 downto 0);
  signal debug_gmem_read_counter_per_cu     : debug_counter(N_CU-1 downto 0);
  signal debug_gmem_write_counter_per_cu    : debug_counter(N_CU-1 downto 0);
  signal debug_op_counter_per_cu            : debug_counter(N_CU-1 downto 0);

  signal debug_gmem_read_counter     : unsigned(2*DATA_W-1 downto 0);
  signal debug_gmem_write_counter    : unsigned(2*DATA_W-1 downto 0);

  signal debug_op_counter            : unsigned(2*DATA_W-1 downto 0);

  signal debug_reset_all_counters    : std_logic;
  -- }}}

  -- global memory ---------------------------------------------------- {{{

  type rdData_v_vec_type is array(natural range <>) of std_logic_vector(N_CU-1 downto 0);
  type atomic_sgntr_vec_type is array(natural range <>) of std_logic_vector(N_CU_STATIONS_W-1 downto 0);
  type cache_rdData_vec_type is array(natural range <>) of std_logic_vector(DATA_W*CACHE_N_BANKS-1 downto 0);

  -- cache signals
  function distribute_cache_rd_ports_on_CUs (n_cus: integer) return nat_array is -- {{{
    variable res: nat_array(n_cus-1 downto 0);
  -- res(0) will have the maximum distance to the global memory controller
  begin
    for i in 0 to n_cus-1 loop
      res(i) := n_cus/2*(i mod 2) + (i/2);
	  -- e.g.: n_cus = 8
	  -- res(0) = 0
	  -- res(1) = 4
	  -- res(2) = 1
	  -- res(3) = 5
	  -- res(4) = 2
	  -- res(5) = 6
	  -- res(6) = 3
	  -- res(7) = 7
    end loop;
    return res;
  end; -- }}}

  constant cache_rd_port_to_CU            : nat_array(N_CU-1 downto 0) := distribute_cache_rd_ports_on_CUs(N_CU);
    -- constant used to distribute cache signals on the CUs

  signal cache_rdData_out                 : std_logic_vector(DATA_W*CACHE_N_BANKS-1 downto 0);
    -- cache read data
  signal cache_rdAddr_out                 : unsigned(GMEM_WORD_ADDR_W-CACHE_N_BANKS_W-1 downto 0);
    -- cache read address (line)
  signal cache_rdAck_out                  : std_logic_vector(N_CU-1 downto 0);
    -- cache read acknowledge for the CUs
  signal cache_rdData_vec                 : cache_rdData_vec_type(N_CU downto 0);
	-- cache_rdData_vec(N_CU downto 0) <= cache_rdData & cache_rdData_vec(N_CU downto 1), each clock cycle the elements are shifted to the right
  signal cache_rdAddr_vec                 : GMEM_ADDR_ARRAY_NO_BANK(N_CU downto 0);
	-- cache_rdAddr_vec(N_CU downto 0) <= cache_rdAddr_out & cache_rdAddr_vec(N_CU downto 1), each clock cycle the elements are shifted to the right
  signal cache_rdAck_vec                  : rdData_v_vec_type(N_CU downto 0);
	-- cache_rdAck_vec(N_CU downto 0) <= cache_rdAck_out & cache_rdAck_vec(N_CU downto 1), each clock cycle the elements are shifted to the right

  signal atomic_rdData                    : std_logic_vector(DATA_W-1 downto 0);
    -- atomic units read data
  signal atomic_rdData_vec                : slv32_array(N_CU downto 0);
    -- atomic_rdData_vec(N_CU downto 0) <= atomic_rdData & atomic_rdData_vec(N_CU downto 1)
  signal atomic_rdData_v                  : std_logic_vector(N_CU-1 downto 0);
    -- atomic units read data valid
  signal atomic_rdData_v_vec              : rdData_v_vec_type(N_CU downto 0);
    --
  signal atomic_sgntr                     : std_logic_vector(N_CU_STATIONS_W-1 downto 0);
    -- signal used to identify the CU that requested the atomic operation                                                ---------------------------------- Check comment
  signal atomic_sgntr_vec                 : atomic_sgntr_vec_type(N_CU downto 0);
    -- atomic_sgntr_vec(N_CU downto 0) <= atomic_sgntr & atomic_sgntr_vec(N_CU downto 1)

  signal cu_gmem_valid                    : std_logic_vector(N_CU-1 downto 0);
    -- CUs valid signal to global memory
  signal cu_gmem_ready                    : std_logic_vector(N_CU-1 downto 0);
    -- CUs ready signal to global memory
  signal cu_gmem_we                       : be_array(N_CU-1 downto 0);
    -- CUs byte write-enable array
  signal cu_gmem_rnw                      : std_logic_vector(N_CU-1 downto 0);
    -- bit coming from the fifo within the CU memory controller                                                          ---------------------------------- Add comment
  signal cu_gmem_atomic      			  : std_logic_vector(N_CU-1 downto 0);
    -- bit coming from the fifo within the CU memory controller                                                          ---------------------------------- Add comment
  signal cu_gmem_atomic_sgntr             : atomic_sgntr_array(N_CU-1 downto 0);
    -- atomic signatur coming from the fifo within the CU memory controller                                              ---------------------------------- Add comment
  signal cu_rqst_addr                     : GMEM_WORD_ADDR_ARRAY(N_CU-1 downto 0);
    -- address of the global memory requests performed by the CUs
  signal cu_gmem_wrData                   : SLV32_ARRAY(N_CU-1 downto 0);
    -- data to be written in the global memory by the CUs
  signal wf_active                        : wf_active_array(N_CU-1 downto 0);
    -- wf_active(i)(j) is set to '1' by the CU if the j-th WF of the i-th CU is active
  signal CU_gmem_idle                     : std_logic_vector(N_CU-1 downto 0);
    -- signal set to '1' by the CU when there is no operation towards the global memory to be served
  signal CUs_gmem_idle                    : std_logic;
    -- signal set to '1' when all the CUs have no operation towards the global memory to be served

  signal axi_araddr                       : GMEM_ADDR_ARRAY(N_AXI-1 downto 0);
    -- AXI master ports read address
  signal axi_arvalid                      : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports read address valid
  signal axi_arready                      : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports read address valid
  signal axi_rdata                        : gmem_word_array(N_AXI-1 downto 0);
    -- AXI master ports read data
  signal axi_rlast                        : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports rlast signal
  signal axi_rvalid                       : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports read valid
  signal axi_rready                       : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports read ready
  signal axi_awaddr                       : GMEM_ADDR_ARRAY(N_AXI-1 downto 0);
    -- AXI master ports write address
  signal axi_awvalid                      : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports write address valid
  signal axi_awready                      : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports write address ready
  signal axi_wdata                        : gmem_word_array(N_AXI-1 downto 0);
    -- AXI master ports write data
  signal axi_wstrb                        : gmem_be_array(N_AXI-1 downto 0);
    -- AXI master ports wstrb
  signal axi_wlast                        : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports wlast
  signal axi_wvalid                       : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports write valid
  signal axi_wready                       : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports write ready
  signal axi_bvalid                       : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports bvalid
  signal axi_bready                       : std_logic_vector(N_AXI-1 downto 0);
    -- AXI master ports bready
  signal axi_arid                         : id_array(N_AXI-1 downto 0);
    -- AXI master ports read address ID
  signal axi_rid                          : id_array(N_AXI-1 downto 0);
    -- AXI master ports read ID tag
  signal axi_awid                         : id_array(N_AXI-1 downto 0);
    -- AXI master ports write address ID
  signal axi_bid                          : id_array(N_AXI-1 downto 0);
    -- AXI response ID tag
  -- }}}

  attribute mark_debug : string;
  attribute mark_debug of Rstart : signal is "true";
  attribute mark_debug of RInitiate : signal is "true";
  attribute mark_debug of RcleanCache : signal is "true";
  attribute mark_debug of Rstat: signal is "true";

begin
  -- asserts -------------------------------------------------------------------------------------------{{{
  assert KRNL_SCH_ADDR_W <= CRAM_ADDR_W severity failure; --Code RAM is the biggest block
  assert CRAM_ADDR_W <= INTERFCE_W_ADDR_W-2 severity failure; --there should be two bits to choose among: HW_sch_RAM, CRAM and the register file
  assert DATA_W >= GMEM_ADDR_W report "the width bus between a gmem_ctrl_CV and gmem_ctrl is GMEM_DATA_W" severity failure;
  assert CV_SIZE = 8 or CV_SIZE = 4 severity failure;
  assert 2**N_CU_STATIONS_W >= N_STATIONS_ALU*CV_SIZE report "increase N_STATIONS_W" severity failure;
  assert N_TAG_MANAGERS_W > 0 report "There should be at least two tag managers" severity failure;
  assert DATA_W = 32;
  -- assert CRAM_BLOCKS = 1 or CRAM_BLOCKS = 2;
  -- assert N_AXI = 1 or N_AXI = 2;
  -- assert N_AXI = 1 or N_AXI = 2;
  ---------------------------------------------------------------------------------------------------------}}}

  -- interal signals assignments --------------------------------------------------------------------------{{{
  s_awready <= s_awready_i;
  s_bvalid <= s_bvalid_i;
  s_wready <= s_wready_i;
  s_arready <= s_arready_i;
  ---------------------------------------------------------------------------------------------------------}}}

  -- slave axi interface ----------------------------------------------------------------------------------{{{

  -- aw & w channels
  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        s_awready_i <= '0';
        s_wready_i  <= '0';
        mainProc_we     <= '0';
        mainProc_wrAddr <= (others => '0');
      else
        -- from AXI4Lite standard, there is no guarantee that the transaction
        -- on w and on aw must occur simultaneously. They can be in any order (TBC)
        if s_awready_i = '0' and s_awvalid = '1' and s_wvalid = '1' then
          s_awready_i <= '1';
          mainProc_wrAddr <= unsigned(s_awaddr);
          s_wready_i <= '1';
          mainProc_we <= '1';
        else
          s_awready_i <= '0';
          s_wready_i <= '0';
          mainProc_we <= '0';
        end if;
      end if;
    end if;
  end process;

  -- b channel
  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        s_bvalid_i <= '0';
      else
        if s_awready_i = '1' and s_awvalid = '1' and s_wready_i = '1' and s_wvalid = '1' and s_bvalid_i = '0' then
          s_bvalid_i <= '1';
        elsif s_bready = '1' and s_bvalid_i = '1' then
          s_bvalid_i <= '0';
        end if;
      end if;
    end if;
  end process;

  -- ar channel
  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then -- NOT NEEDED
        s_arready_i <= '0';
        mainProc_rdAddr <= (others => '0');
      else
        -- One cycle ready and one cycle not
        if s_arready_i = '0' and s_arvalid = '1' then
          s_arready_i    <= '1';
          mainProc_rdAddr <= unsigned(s_araddr);
        else
          s_arready_i <= '0';
        end if;
      end if;
    end if;
  end process;

  -- r channel
  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        -- s_rvalid_vec <= (others => '0');
        s_rvalid     <= '0';
      else
        if s_rvalid_vec(1) = '1' then
          s_rvalid <= '1';
        end if;
        if s_rvalid_vec(0) = '1' then
          if s_rready = '1' then
            s_rvalid <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  --to add latency on r channel, wait 2 cycles after ar channel completes
  process(clk)
  begin
    if rising_edge(clk) then
      s_rvalid_vec(s_rvalid_vec'high-1 downto 0) <= s_rvalid_vec(s_rvalid_vec'high downto 1);
      if s_arready_i = '1' and s_arvalid = '1' and s_rvalid_vec(s_rvalid_vec'high) = '0' then
        s_rvalid_vec(s_rvalid_vec'high) <= '1';
      else
        s_rvalid_vec(s_rvalid_vec'high) <= '0';
      end if;
      if s_rvalid_vec(0) = '1' then
        if s_rready = '0' then
          s_rvalid_vec(0) <= '1';
        end if;
      end if;
    end if;
  end process;

  --to assign s_rdata, this is the reason for the 2 cycles of delay
  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        s_rdata <= (others => '0');
      else
        if mainProc_rdAddr(INTERFCE_W_ADDR_W-1 downto INTERFCE_W_ADDR_W-2) = "00" then -- HW_scheduler_ram
          s_rdata <= krnl_sch_rdData;
        elsif mainProc_rdAddr(INTERFCE_W_ADDR_W-1 downto INTERFCE_W_ADDR_W-2) = "01" then -- Code_ram
          s_rdata <= cram_rdData;
        -- s_rdata <= cram_rdData(0);
        elsif mainProc_rdAddr(INTERFCE_W_ADDR_W-1 downto INTERFCE_W_ADDR_W-2) = "10" then -- Control Registers
          case mainProc_rdAddr(1 downto 0) is
            when "00" =>
              s_rdata(NEW_KRNL_MAX_INDX-1 downto 0)  <= Rstat(NEW_KRNL_MAX_INDX-1 downto 0);
            when "10" =>
              s_rdata(NEW_KRNL_MAX_INDX-1 downto 0)  <= RcleanCache(NEW_KRNL_MAX_INDX-1 downto 0);
            when others =>
              s_rdata(NEW_KRNL_MAX_INDX-1 downto 0)  <= RInitiate(NEW_KRNL_MAX_INDX-1 downto 0);
          end case;
          s_rdata(DATA_W-1 downto NEW_KRNL_MAX_INDX) <= (others => '0');
        elsif mainProc_rdAddr(INTERFCE_W_ADDR_W-1 downto INTERFCE_W_ADDR_W-2) = "11" and DEBUG_IMPLEMENT /= 0 then -- Debug Registers
          case mainProc_rdAddr(2 downto 0) is
            when "000" =>    -- miss_counter
              s_rdata <= std_logic_vector(debug_cache_miss_counter);
            when "001" =>    -- gmem_read_counter[31:0]
              s_rdata <= std_logic_vector(debug_gmem_read_counter(DATA_W-1 downto 0));
            when "010" =>    -- gmem_read_counter[63:32]
              s_rdata <= std_logic_vector(debug_gmem_read_counter(2*DATA_W-1 downto DATA_W));
            when "011" =>    -- gmem_write_counter[31:0]
              s_rdata <= std_logic_vector(debug_gmem_write_counter(DATA_W-1 downto 0));
            when "100" =>    -- gmem_write_counter[63:32]
              s_rdata <= std_logic_vector(debug_gmem_write_counter(2*DATA_W-1 downto DATA_W));
            when "101" =>    -- op_counter[31:0]
              s_rdata <= std_logic_vector(debug_op_counter(DATA_W-1 downto 0));
            when "110" =>    -- op_counter[63:32]
              s_rdata <= std_logic_vector(debug_op_counter(2*DATA_W-1 downto DATA_W));
            when others =>
              s_rdata <= (others => '0');
          end case;
        end if;
      end if;
    end if;
  end process;
  ---------------------------------------------------------------------------------------------------------}}}

  -- fixed signals --------------------------------------------------------------------------------- {{{
  s_bresp   <= "00";
  s_rresp  <= "00";
  ------------------------------------------------------------------------------------------------- }}}

  -- HW Scheduler RAM  ----------------------------------------------------------------------------- {{{
  Krnl_Scheduler: process (clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        krnl_sch_rdData_n <= (others => '0'); -- NOT NEEDED
        krnl_sch_rdData   <= (others => '0'); -- NOT NEEDED
      else
        krnl_sch_rdData_n <= krnl_scheduler_ram(to_integer(krnl_sch_rdAddr));
        krnl_sch_rdData   <= krnl_sch_rdData_n;
        if krnl_sch_we = '1' then
          krnl_scheduler_ram(to_integer(mainProc_wrAddr(KRNL_SCH_ADDR_W-1 downto 0))) <= s_wdata_d0;
        end if;
      end if;
    end if;
  end process;

  krnl_sch_rdAddr <= mainProc_rdAddr(KRNL_SCH_ADDR_W-1 downto 0) when st_wg_disp = idle else unsigned(krnl_sch_rdAddr_WGD);

  krnl_sch_we  <= '1' when mainProc_wrAddr(INTERFCE_W_ADDR_W-1 downto INTERFCE_W_ADDR_W-2) = "00" and mainProc_we = '1' else '0';
  ------------------------------------------------------------------------------------------------- }}}

  -- Code RAM -------------------------------------------------------------------------------------- {{{
  CRAM_inst: process (clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        cram_rdData_n <= (others => '0'); -- NOT NEEDED
        cram_rdData   <= (others => '0'); -- NOT NEEDED
      else
        cram_rdData_n <= cram_b1(to_integer(cram_rdAddr));
        -- cram_rdData_n <= cram_b1(to_integer(cram_rdAddr(0)));
        -- cram_rdData_n(0) <= cram_b1(to_integer(cram_rdAddr(0)));
        if cram_we = '1' then
          cram_b1(to_integer(mainProc_wrAddr(CRAM_ADDR_W-1 downto 0))) <= s_wdata_d0;
        end if;

        -- if CRAM_BLOCKS > 1 then
        --   cram_rdData_n(CRAM_BLOCKS-1) <= cram_b2(to_integer(cram_rdAddr(CRAM_BLOCKS-1)));
        --   if CRAM_we = '1' then
        --     cram_b2(to_integer(unsigned(mainProc_wrAddr(CRAM_ADDR_W-1 downto 0)))) <= s_wdata_d0;
        --   end if;
        -- end if;

        cram_rdData <= cram_rdData_n;
      end if;
    end if;
  end process;

  cram_we <= '1' when mainProc_wrAddr(INTERFCE_W_ADDR_W-1 downto INTERFCE_W_ADDR_W-2) = "01" and mainProc_we = '1' else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        cram_rdAddr_d0  <= (others => '0'); -- NOT NEEDED
        cram_rdAddr     <= (others => '0'); -- NOT NEEDED
        cram_served_CUs <= '0';             -- NOT NEEDED
      else
        cram_rdAddr_d0 <= cram_rdAddr;
        cram_rdAddr    <= mainProc_rdAddr(CRAM_ADDR_W-1 downto 0);
        -- cram_rdAddr(0) <= mainProc_rdAddr(CRAM_ADDR_W-1 downto 0);
        cram_served_CUs <= not cram_served_CUs;
        if cram_served_CUs = '0' then
          for i in 0 to max(N_CU/2-1,0) loop
            if CU_cram_rqst(i) = '1' then
              cram_rdAddr <= CU_cram_rdAddr(i);
            -- cram_rdAddr(i mod CRAM_BLOCKS) <= CU_cram_rdAddr(i);
            end if;
          end loop;
        else
          for i in N_CU/2 to N_CU-1 loop
            if CU_cram_rqst(i) = '1' then
              cram_rdAddr <= CU_cram_rdAddr(i);
            -- cram_rdAddr(i mod CRAM_BLOCKS) <= CU_cram_rdAddr(i);
            end if;
          end loop;
        end if;
      end if;
    end if;
  end process;
  ------------------------------------------------------------------------------------------------- }}}

  -- WG dispatcher -------------------------------------------------------------------------------------- {{{
  wg_dispatcher_inst: wg_dispatcher
    port map(
      krnl_indx             => new_krnl_indx,
      start                 => start_kernel,
      initialize_d0         => initialize_d0,
      krnl_sch_rdAddr       => krnl_sch_rdAddr_WGD,
      krnl_sch_rdData       => krnl_sch_rdData,
      finish_krnl_indx      => finish_krnl_indx,

      -- to CUs
      start_exec            => start_CUs,
      req                   => wg_req,
      ack                   => wg_ack,
      rtm_wrAddr            => rtm_wrAddr_wg,
      rtm_wrData            => rtm_wrData_wg,
      rtm_we                => rtm_we_wg,
      sch_rqst_n_WFs_m1     => sch_rqst_n_WFs_m1,
      finish                => WGsDispatched,
      start_addr            => start_addr,
      rdData_alu_en         => rdData_alu_en,
      wg_info               => wg_info,
      -- from CUs
      wf_active             => wf_active,
      rdAddr_alu_en         => rdAddr_alu_en,


      clk                   => clk,
      nrst                  => nrst
      );
  ------------------------------------------------------------------------------------------------- }}}

  -- compute units  -------------------------------------------------------------------------------------- {{{
  cus_i: for i in 0 to N_CU-1 generate
  begin
    cu_inst: cu
      port map(
        clk                   => clk,
        wf_active             => wf_active(i),
        WGsDispatched         => WGsDispatched,
        nrst                  => nrst,
        cram_rdAddr           => CU_cram_rdAddr(i),
        cram_rdData           => cram_rdData_vec(i),
        -- cram_rdData           => cram_rdData(i mod CRAM_BLOCKS),
        cram_rqst             => CU_cram_rqst(i),
        cram_rdAddr_conf      => cram_rdAddr_d0_vec(i),
        -- cram_rdAddr_conf      => cram_rdAddr_d0(i mod CRAM_BLOCKS),
        start_addr            => start_addr_vec(i),

        start_CUs             => start_CUs_vec(i),
        sch_rqst_n_wfs_m1     => sch_rqst_n_WFs_m01_vec(i),
        sch_rqst              => wg_req_vec(i)(i),
        sch_ack               => wg_ack(i),
        wg_info               => unsigned(wg_info_vec(i)),
        rtm_wrAddr_wg         => rtm_wrAddr_wg_vec(i),
        rtm_wrData_wg         => rtm_wrData_wg_vec(i),
        rtm_we_wg             => rtm_we_wg_vec(i),
        rdData_alu_en         => rdData_alu_en(i),
        rdAddr_alu_en         => rdAddr_alu_en(i),

        gmem_valid            => cu_gmem_valid(i),
        gmem_we               => cu_gmem_we(i),
        gmem_rnw              => cu_gmem_rnw(i),
        gmem_atomic           => cu_gmem_atomic(i),
        gmem_atomic_sgntr     => cu_gmem_atomic_sgntr(i),
        gmem_rqst_addr        => cu_rqst_addr(i),
        gmem_ready            => cu_gmem_ready(i),
        gmem_wrData           => cu_gmem_wrData(i),
        --cache read data
        cache_rdAddr          => cache_rdAddr_vec(cache_rd_port_to_CU(i)),
        cache_rdAck           => cache_rdAck_vec(cache_rd_port_to_CU(i))(i),
        cache_rdData          => cache_rdData_vec(cache_rd_port_to_CU(i)),
        atomic_rdData         => atomic_rdData_vec(cache_rd_port_to_CU(i)),
        atomic_rdData_v       => atomic_rdData_v_vec(cache_rd_port_to_CU(i))(i),
        atomic_sgntr          => atomic_sgntr_vec(cache_rd_port_to_CU(i)),

        gmem_cntrl_idle       => CU_gmem_idle(i),


        finish_exec           => finish_exec,
        finish_exec_d0        => finish_exec_d0,

        -- debug
        debug_gmem_read_counter_per_cu  => debug_gmem_read_counter_per_cu(i),
        debug_gmem_write_counter_per_cu => debug_gmem_write_counter_per_cu(i),
        debug_op_counter_per_cu         => debug_op_counter_per_cu(i),
        debug_reset_all_counters        => debug_reset_all_counters

       -- loc_mem_rdAddr_dummy => loc_mem_rdAddr_dummy(DATA_W*(i+1)-1 downto i*DATA_W)
        );
  end generate;

  process(clk)
  begin
    if rising_edge(clk) then
      cache_rdAck_vec     <= cache_rdAck_out  & cache_rdAck_vec(cache_rdAck_vec'high downto 1);
      cache_rdAddr_vec    <= cache_rdAddr_out & cache_rdAddr_vec(cache_rdAddr_vec'high downto 1);
      cache_rdData_vec    <= cache_rdData_out & cache_rdData_vec(cache_rdData_vec'high downto 1);
      atomic_rdData_vec   <= atomic_rdData    & atomic_rdData_vec(atomic_rdData_vec'high downto 1);
      atomic_rdData_v_vec <= atomic_rdData_v  & atomic_rdData_v_vec(atomic_rdData_v_vec'high downto 1);
      atomic_sgntr_vec    <= atomic_sgntr     & atomic_sgntr_vec(atomic_sgntr_vec'high downto 1);
      start_addr_vec      <= start_addr       & start_addr_vec(start_addr_vec'high downto 1);
    end if;
  end process;

  fifos_one_cu: if N_CU = 1 generate
    process(clk)
    begin
      if rising_edge(clk) then
        start_CUs_vec(0) <= start_CUs;
        wg_req_vec(0) <= wg_req;
        wg_info_vec(0) <= std_logic_vector(wg_info);
        rtm_we_wg_vec(0) <= rtm_we_wg;
        sch_rqst_n_WFs_m01_vec(0) <= sch_rqst_n_WFs_m1;
        rtm_wrData_wg_vec(0) <= rtm_wrData_wg;
        rtm_wrAddr_wg_vec(0) <= rtm_wrAddr_wg;
        cram_rdData_vec(0) <= cram_rdData;
        cram_rdAddr_d0_vec(0) <= cram_rdAddr_d0;
      end if;
    end process;
  end generate;

  fifos_more_cu: if N_CU > 1 generate
    process(clk)
    begin
      if rising_edge(clk) then
        start_CUs_vec         <= start_CUs         & start_CUs_vec(start_CUs_vec'high downto 1);
        wg_req_vec            <= wg_req            & wg_req_vec(wg_req_vec'high downto 1);
        wg_info_vec           <= std_logic_vector(wg_info) & wg_info_vec(wg_info_vec'high downto 1);
        rtm_we_wg_vec         <= rtm_we_wg         & rtm_we_wg_vec(rtm_we_wg_vec'high downto 1);
        sch_rqst_n_WFs_m01_vec <= sch_rqst_n_WFs_m1 & sch_rqst_n_WFs_m01_vec(sch_rqst_n_WFs_m01_vec'high downto 1);
        rtm_wrData_wg_vec     <= rtm_wrData_wg     & rtm_wrData_wg_vec(rtm_wrData_wg_vec'high downto 1);
        rtm_wrAddr_wg_vec     <= rtm_wrAddr_wg     & rtm_wrAddr_wg_vec(rtm_wrAddr_wg_vec'high downto 1);
        cram_rdData_vec       <= cram_rdData       & cram_rdData_vec(cram_rdData_vec'high downto 1);
        cram_rdAddr_d0_vec    <= cram_rdAddr_d0    & cram_rdAddr_d0_vec(cram_rdAddr_d0_vec'high downto 1);
      end if;
    end process;
  end generate;

  process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        CUs_gmem_idle <= '0'; -- NOT NEEDED
      else
        if to_integer(unsigned(CU_gmem_idle)) = 2**N_CU-1 then
          CUs_gmem_idle <= '1';
        else
          CUs_gmem_idle <= '0';
        end if;
      end if;
    end if;
  end process;
  ------------------------------------------------------------------------------------------------- }}}

  -- global memory controller----------------------------------------------------------------------------------- {{{
  gmem_controller_inst: gmem_cntrl
    port map(
      clk               => clk,
      cu_valid          => cu_gmem_valid,
      cu_ready          => cu_gmem_ready,
      cu_we             => cu_gmem_we,
      cu_rnw            => cu_gmem_rnw,
      cu_atomic         => cu_gmem_atomic,
      cu_atomic_sgntr   => cu_gmem_atomic_sgntr,
      cu_rqst_addr      => cu_rqst_addr,
      cu_wrData         => cu_gmem_wrData,
      WGsDispatched     => WGsDispatched,
      finish_exec       => finish_exec,
      start_kernel      => start_kernel,
      clean_cache       => clean_cache,
      CUs_gmem_idle     => CUs_gmem_idle,

      -- read data from cache
      rdAck             => cache_rdAck_out,
      rdAddr            => cache_rdAddr_out,
      rdData            => cache_rdData_out,

      atomic_rdData     => atomic_rdData,
      atomic_rdData_v   => atomic_rdData_v,
      atomic_sgntr      => atomic_sgntr,
      -- read axi bus {{{
      --    ar channel
      axi_araddr        => axi_araddr,
      axi_arvalid       => axi_arvalid,
      axi_arready       => axi_arready,
      axi_arid          => axi_arid,
      --    r channel
      axi_rdata         => axi_rdata,
      axi_rlast         => axi_rlast,
      axi_rvalid        => axi_rvalid,
      axi_rready        => axi_rready,
      axi_rid           => axi_rid,
      --    aw channel
      axi_awaddr        => axi_awaddr,
      axi_awvalid       => axi_awvalid,
      axi_awready       => axi_awready,
      axi_awid          => axi_awid,
      --    w channel
      axi_wdata         => axi_wdata,
      axi_wstrb         => axi_wstrb,
      axi_wlast         => axi_wlast,
      axi_wvalid        => axi_wvalid,
      axi_wready        => axi_wready,
      -- b channel
      axi_bvalid        => axi_bvalid,
      axi_bready        => axi_bready,
      axi_bid           => axi_bid,
      --}}}

      debug_cache_miss_counter => debug_cache_miss_counter,
      debug_reset_all_counters => debug_reset_all_counters,

      nrst              => nrst
      );

  -- fixed signals assignments {{{
  m00_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m00_arlen'length));
  m01_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m01_arlen'length));
  m02_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m02_arlen'length));
  m03_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m03_arlen'length));
  m04_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m04_arlen'length));
  m05_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m05_arlen'length));
  m06_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m06_arlen'length));
  m07_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m07_arlen'length));
  m08_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m08_arlen'length));
  m09_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m09_arlen'length));
  m10_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m10_arlen'length));
  m11_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m11_arlen'length));
  m12_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m12_arlen'length));
  m13_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m13_arlen'length));
  m14_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m14_arlen'length));
  m15_arlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m15_arlen'length));
  m00_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m01_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m02_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m03_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m04_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m05_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m06_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m07_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m08_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m09_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m10_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m11_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m12_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m13_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m14_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m15_arsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m00_arburst  <= "01"; --INCR burst type
  m01_arburst  <= "01"; --INCR burst type
  m02_arburst  <= "01"; --INCR burst type
  m03_arburst  <= "01"; --INCR burst type
  m04_arburst  <= "01"; --INCR burst type
  m05_arburst  <= "01"; --INCR burst type
  m06_arburst  <= "01"; --INCR burst type
  m07_arburst  <= "01"; --INCR burst type
  m08_arburst  <= "01"; --INCR burst type
  m09_arburst  <= "01"; --INCR burst type
  m10_arburst  <= "01"; --INCR burst type
  m11_arburst  <= "01"; --INCR burst type
  m12_arburst  <= "01"; --INCR burst type
  m13_arburst  <= "01"; --INCR burst type
  m14_arburst  <= "01"; --INCR burst type
  m15_arburst  <= "01"; --INCR burst type
  m00_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m00_awlen'length));
  m01_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m01_awlen'length));
  m02_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m02_awlen'length));
  m03_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m03_awlen'length));
  m04_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m04_awlen'length));
  m05_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m05_awlen'length));
  m06_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m06_awlen'length));
  m07_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m07_awlen'length));
  m08_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m08_awlen'length));
  m09_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m09_awlen'length));
  m10_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m10_awlen'length));
  m11_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m11_awlen'length));
  m12_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m12_awlen'length));
  m13_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m13_awlen'length));
  m14_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m14_awlen'length));
  m15_awlen <= std_logic_vector(to_unsigned((2**BURST_W)-1, m15_awlen'length));
  m00_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m01_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m02_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m03_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m04_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m05_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m06_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m07_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m08_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m09_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m10_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m11_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m12_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m13_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m14_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m15_awsize <= std_logic_vector(to_unsigned(2+GMEM_N_BANK_W, 3)); -- in 2^n bytes,
  m00_awburst  <= "01"; --INCR burst type
  m01_awburst  <= "01"; --INCR burst type
  m02_awburst  <= "01"; --INCR burst type
  m03_awburst  <= "01"; --INCR burst type
  m04_awburst  <= "01"; --INCR burst type
  m05_awburst  <= "01"; --INCR burst type
  m06_awburst  <= "01"; --INCR burst type
  m07_awburst  <= "01"; --INCR burst type
  m08_awburst  <= "01"; --INCR burst type
  m09_awburst  <= "01"; --INCR burst type
  m10_awburst  <= "01"; --INCR burst type
  m11_awburst  <= "01"; --INCR burst type
  m12_awburst  <= "01"; --INCR burst type
  m13_awburst  <= "01"; --INCR burst type
  m14_awburst  <= "01"; --INCR burst type
  m15_awburst  <= "01"; --INCR burst type
  --}}}

  -- axi assignments {{{
  m00_araddr <= std_logic_vector(axi_araddr(0));
  m00_arvalid <= axi_arvalid(0);
  axi_arready(0) <= m00_arready;
  axi_rdata(0) <= m00_rdata;
  axi_rlast(0) <= m00_rlast;
  axi_rvalid(0) <= m00_rvalid;
  axi_rid(0) <= m00_rid;
  axi_bid(0) <= m00_bid;
  m00_awid <= axi_awid(0);
  m00_rready <= axi_rready(0);
  m00_arid <= axi_arid(0);
  m00_awaddr <= std_logic_vector(axi_awaddr(0));
  m00_awvalid <= axi_awvalid(0);
  axi_awready(0) <= m00_awready;
  m00_wdata <= axi_wdata(0);
  m00_wstrb <= axi_wstrb(0);
  m00_wlast <= axi_wlast(0);
  m00_wvalid <= axi_wvalid(0);
  axi_wready(0) <= m00_wready;
  axi_bvalid(0) <= m00_bvalid;
  m00_bready <= axi_bready(0);

  AXI_1: if N_AXI > 1 generate
    m01_araddr <= std_logic_vector(axi_araddr(1));
    m01_arvalid <= axi_arvalid(1);
    axi_arready(1) <= m01_arready;
    axi_rdata(1) <= m01_rdata;
    axi_rlast(1) <= m01_rlast;
    axi_rvalid(1) <= m01_rvalid;
    axi_rid(1) <= m01_rid;
    axi_bid(1) <= m01_bid;
    m01_awid <= axi_awid(1);
    m01_rready <= axi_rready(1);
    m01_arid <= axi_arid(1);
    m01_awaddr <= std_logic_vector(axi_awaddr(1));
    m01_awvalid <= axi_awvalid(1);
    axi_awready(1) <= m01_awready;
    m01_wdata <= axi_wdata(1);
    m01_wstrb <= axi_wstrb(1);
    m01_wlast <= axi_wlast(1);
    m01_wvalid <= axi_wvalid(1);
    axi_wready(1) <= m01_wready;
    axi_bvalid(1) <= m01_bvalid;
    m01_bready <= axi_bready(1);
  end generate;
  AXI_1_NOT: if N_AXI <= 1 generate
    m01_araddr  <= (others => '0');
    m01_arvalid <= '0';
    m01_awid    <= (others => '0');
    m01_rready  <= '0';
    m01_arid    <= (others => '0');
    m01_awaddr  <= (others => '0');
    m01_awvalid <= '0';
    m01_wdata   <= (others => '0');
    m01_wstrb   <= (others => '0');
    m01_wlast   <= '0';
    m01_wvalid  <= '0';
    m01_bready  <= '0';
  end generate;

  AXI_2: if N_AXI > 2 generate
    m02_araddr <= std_logic_vector(axi_araddr(2));
    m02_arvalid <= axi_arvalid(2);
    axi_arready(2) <= m02_arready;
    axi_rdata(2) <= m02_rdata;
    axi_rlast(2) <= m02_rlast;
    axi_rvalid(2) <= m02_rvalid;
    axi_rid(2) <= m02_rid;
    axi_bid(2) <= m02_bid;
    m02_awid <= axi_awid(2);
    m02_rready <= axi_rready(2);
    m02_arid <= axi_arid(2);
    m02_awaddr <= std_logic_vector(axi_awaddr(2));
    m02_awvalid <= axi_awvalid(2);
    axi_awready(2) <= m02_awready;
    m02_wdata <= axi_wdata(2);
    m02_wstrb <= axi_wstrb(2);
    m02_wlast <= axi_wlast(2);
    m02_wvalid <= axi_wvalid(2);
    axi_wready(2) <= m02_wready;
    axi_bvalid(2) <= m02_bvalid;
    m02_bready <= axi_bready(2);
  end generate;
  AXI_2_NOT: if N_AXI <= 2 generate
    m02_araddr  <= (others => '0');
    m02_arvalid <= '0';
    m02_awid    <= (others => '0');
    m02_rready  <= '0';
    m02_arid    <= (others => '0');
    m02_awaddr  <= (others => '0');
    m02_awvalid <= '0';
    m02_wdata   <= (others => '0');
    m02_wstrb   <= (others => '0');
    m02_wlast   <= '0';
    m02_wvalid  <= '0';
    m02_bready  <= '0';
  end generate;

  AXI_3: if N_AXI > 3 generate
    m03_araddr <= std_logic_vector(axi_araddr(3));
    m03_arvalid <= axi_arvalid(3);
    axi_arready(3) <= m03_arready;
    axi_rdata(3) <= m03_rdata;
    axi_rlast(3) <= m03_rlast;
    axi_rvalid(3) <= m03_rvalid;
    axi_rid(3) <= m03_rid;
    axi_bid(3) <= m03_bid;
    m03_awid <= axi_awid(3);
    m03_rready <= axi_rready(3);
    m03_arid <= axi_arid(3);
    m03_awaddr <= std_logic_vector(axi_awaddr(3));
    m03_awvalid <= axi_awvalid(3);
    axi_awready(3) <= m03_awready;
    m03_wdata <= axi_wdata(3);
    m03_wstrb <= axi_wstrb(3);
    m03_wlast <= axi_wlast(3);
    m03_wvalid <= axi_wvalid(3);
    axi_wready(3) <= m03_wready;
    axi_bvalid(3) <= m03_bvalid;
    m03_bready <= axi_bready(3);
  end generate;
  AXI_3_NOT: if N_AXI <= 3 generate
    m03_araddr  <= (others => '0');
    m03_arvalid <= '0';
    m03_awid    <= (others => '0');
    m03_rready  <= '0';
    m03_arid    <= (others => '0');
    m03_awaddr  <= (others => '0');
    m03_awvalid <= '0';
    m03_wdata   <= (others => '0');
    m03_wstrb   <= (others => '0');
    m03_wlast   <= '0';
    m03_wvalid  <= '0';
    m03_bready  <= '0';
  end generate;
  
  AXI_7: if N_AXI > 4 generate
    m04_araddr <= std_logic_vector(axi_araddr(4));
    m04_arvalid <= axi_arvalid(4);
    axi_arready(4) <= m04_arready;
    axi_rdata(4) <= m04_rdata;
    axi_rlast(4) <= m04_rlast;
    axi_rvalid(4) <= m04_rvalid;
    axi_rid(4) <= m04_rid;
    axi_bid(4) <= m04_bid;
    m04_awid <= axi_awid(4);
    m04_rready <= axi_rready(4);
    m04_arid <= axi_arid(4);
    m04_awaddr <= std_logic_vector(axi_awaddr(4));
    m04_awvalid <= axi_awvalid(4);
    axi_awready(4) <= m04_awready;
    m04_wdata <= axi_wdata(4);
    m04_wstrb <= axi_wstrb(4);
    m04_wlast <= axi_wlast(4);
    m04_wvalid <= axi_wvalid(4);
    axi_wready(4) <= m04_wready;
    axi_bvalid(4) <= m04_bvalid;
    m04_bready <= axi_bready(4);
    
    m05_araddr <= std_logic_vector(axi_araddr(5));
    m05_arvalid <= axi_arvalid(5);
    axi_arready(5) <= m05_arready;
    axi_rdata(5) <= m05_rdata;
    axi_rlast(5) <= m05_rlast;
    axi_rvalid(5) <= m05_rvalid;
    axi_rid(5) <= m05_rid;
    axi_bid(5) <= m05_bid;
    m05_awid <= axi_awid(5);
    m05_rready <= axi_rready(5);
    m05_arid <= axi_arid(5);
    m05_awaddr <= std_logic_vector(axi_awaddr(5));
    m05_awvalid <= axi_awvalid(5);
    axi_awready(5) <= m05_awready;
    m05_wdata <= axi_wdata(5);
    m05_wstrb <= axi_wstrb(5);
    m05_wlast <= axi_wlast(5);
    m05_wvalid <= axi_wvalid(5);
    axi_wready(5) <= m05_wready;
    axi_bvalid(5) <= m05_bvalid;
    m05_bready <= axi_bready(5);
    
    m06_araddr <= std_logic_vector(axi_araddr(6));
    m06_arvalid <= axi_arvalid(6);
    axi_arready(6) <= m06_arready;
    axi_rdata(6) <= m06_rdata;
    axi_rlast(6) <= m06_rlast;
    axi_rvalid(6) <= m06_rvalid;
    axi_rid(6) <= m06_rid;
    axi_bid(6) <= m06_bid;
    m06_awid <= axi_awid(6);
    m06_rready <= axi_rready(6);
    m06_arid <= axi_arid(6);
    m06_awaddr <= std_logic_vector(axi_awaddr(6));
    m06_awvalid <= axi_awvalid(6);
    axi_awready(6) <= m06_awready;
    m06_wdata <= axi_wdata(6);
    m06_wstrb <= axi_wstrb(6);
    m06_wlast <= axi_wlast(6);
    m06_wvalid <= axi_wvalid(6);
    axi_wready(6) <= m06_wready;
    axi_bvalid(6) <= m06_bvalid;
    m06_bready <= axi_bready(6);
    
    m07_araddr <= std_logic_vector(axi_araddr(7));
    m07_arvalid <= axi_arvalid(7);
    axi_arready(7) <= m07_arready;
    axi_rdata(7) <= m07_rdata;
    axi_rlast(7) <= m07_rlast;
    axi_rvalid(7) <= m07_rvalid;
    axi_rid(7) <= m07_rid;
    axi_bid(7) <= m07_bid;
    m07_awid <= axi_awid(7);
    m07_rready <= axi_rready(7);
    m07_arid <= axi_arid(7);
    m07_awaddr <= std_logic_vector(axi_awaddr(7));
    m07_awvalid <= axi_awvalid(7);
    axi_awready(7) <= m07_awready;
    m07_wdata <= axi_wdata(7);
    m07_wstrb <= axi_wstrb(7);
    m07_wlast <= axi_wlast(7);
    m07_wvalid <= axi_wvalid(7);
    axi_wready(7) <= m07_wready;
    axi_bvalid(7) <= m07_bvalid;
    m07_bready <= axi_bready(7);
  end generate;
  
  AXI_7_NOT: if N_AXI <= 4 generate
    m04_araddr  <= (others => '0');
    m04_arvalid <= '0';
    m04_awid    <= (others => '0');
    m04_rready  <= '0';
    m04_arid    <= (others => '0');
    m04_awaddr  <= (others => '0');
    m04_awvalid <= '0';
    m04_wdata   <= (others => '0');
    m04_wstrb   <= (others => '0');
    m04_wlast   <= '0';
    m04_wvalid  <= '0';
    m04_bready  <= '0';
    
    m05_araddr  <= (others => '0');
    m05_arvalid <= '0';
    m05_awid    <= (others => '0');
    m05_rready  <= '0';
    m05_arid    <= (others => '0');
    m05_awaddr  <= (others => '0');
    m05_awvalid <= '0';
    m05_wdata   <= (others => '0');
    m05_wstrb   <= (others => '0');
    m05_wlast   <= '0';
    m05_wvalid  <= '0';
    m05_bready  <= '0';
    
    m06_araddr  <= (others => '0');
    m06_arvalid <= '0';
    m06_awid    <= (others => '0');
    m06_rready  <= '0';
    m06_arid    <= (others => '0');
    m06_awaddr  <= (others => '0');
    m06_awvalid <= '0';
    m06_wdata   <= (others => '0');
    m06_wstrb   <= (others => '0');
    m06_wlast   <= '0';
    m06_wvalid  <= '0';
    m06_bready  <= '0'; 
    
    m07_araddr  <= (others => '0');
    m07_arvalid <= '0';
    m07_awid    <= (others => '0');
    m07_rready  <= '0';
    m07_arid    <= (others => '0');
    m07_awaddr  <= (others => '0');
    m07_awvalid <= '0';
    m07_wdata   <= (others => '0');
    m07_wstrb   <= (others => '0');
    m07_wlast   <= '0';
    m07_wvalid  <= '0';
    m07_bready  <= '0';       
  end generate;
  
  AXI_15: if N_AXI > 8 generate
    m08_araddr <= std_logic_vector(axi_araddr(8));
    m08_arvalid <= axi_arvalid(8);
    axi_arready(8) <= m08_arready;
    axi_rdata(8) <= m08_rdata;
    axi_rlast(8) <= m08_rlast;
    axi_rvalid(8) <= m08_rvalid;
    axi_rid(8) <= m08_rid;
    axi_bid(8) <= m08_bid;
    m08_awid <= axi_awid(8);
    m08_rready <= axi_rready(8);
    m08_arid <= axi_arid(8);
    m08_awaddr <= std_logic_vector(axi_awaddr(8));
    m08_awvalid <= axi_awvalid(8);
    axi_awready(8) <= m08_awready;
    m08_wdata <= axi_wdata(8);
    m08_wstrb <= axi_wstrb(8);
    m08_wlast <= axi_wlast(8);
    m08_wvalid <= axi_wvalid(8);
    axi_wready(8) <= m08_wready;
    axi_bvalid(8) <= m08_bvalid;
    m08_bready <= axi_bready(8);
    
    m09_araddr <= std_logic_vector(axi_araddr(9));
    m09_arvalid <= axi_arvalid(9);
    axi_arready(9) <= m09_arready;
    axi_rdata(9) <= m09_rdata;
    axi_rlast(9) <= m09_rlast;
    axi_rvalid(9) <= m09_rvalid;
    axi_rid(9) <= m09_rid;
    axi_bid(9) <= m09_bid;
    m09_awid <= axi_awid(9);
    m09_rready <= axi_rready(9);
    m09_arid <= axi_arid(9);
    m09_awaddr <= std_logic_vector(axi_awaddr(9));
    m09_awvalid <= axi_awvalid(9);
    axi_awready(9) <= m09_awready;
    m09_wdata <= axi_wdata(9);
    m09_wstrb <= axi_wstrb(9);
    m09_wlast <= axi_wlast(9);
    m09_wvalid <= axi_wvalid(9);
    axi_wready(9) <= m09_wready;
    axi_bvalid(9) <= m09_bvalid;
    m09_bready <= axi_bready(9);
    
    m10_araddr <= std_logic_vector(axi_araddr(10));
    m10_arvalid <= axi_arvalid(10);
    axi_arready(10) <= m10_arready;
    axi_rdata(10) <= m10_rdata;
    axi_rlast(10) <= m10_rlast;
    axi_rvalid(10) <= m10_rvalid;
    axi_rid(10) <= m10_rid;
    axi_bid(10) <= m10_bid;
    m10_awid <= axi_awid(10);
    m10_rready <= axi_rready(10);
    m10_arid <= axi_arid(10);
    m10_awaddr <= std_logic_vector(axi_awaddr(10));
    m10_awvalid <= axi_awvalid(10);
    axi_awready(10) <= m10_awready;
    m10_wdata <= axi_wdata(10);
    m10_wstrb <= axi_wstrb(10);
    m10_wlast <= axi_wlast(10);
    m10_wvalid <= axi_wvalid(10);
    axi_wready(10) <= m10_wready;
    axi_bvalid(10) <= m10_bvalid;
    m10_bready <= axi_bready(10);
    
    m11_araddr <= std_logic_vector(axi_araddr(11));
    m11_arvalid <= axi_arvalid(11);
    axi_arready(11) <= m11_arready;
    axi_rdata(11) <= m11_rdata;
    axi_rlast(11) <= m11_rlast;
    axi_rvalid(11) <= m11_rvalid;
    axi_rid(11) <= m11_rid;
    axi_bid(11) <= m11_bid;
    m11_awid <= axi_awid(11);
    m11_rready <= axi_rready(11);
    m11_arid <= axi_arid(11);
    m11_awaddr <= std_logic_vector(axi_awaddr(11));
    m11_awvalid <= axi_awvalid(11);
    axi_awready(11) <= m11_awready;
    m11_wdata <= axi_wdata(11);
    m11_wstrb <= axi_wstrb(11);
    m11_wlast <= axi_wlast(11);
    m11_wvalid <= axi_wvalid(11);
    axi_wready(11) <= m11_wready;
    axi_bvalid(11) <= m11_bvalid;
    m11_bready <= axi_bready(11);
    
    m12_araddr <= std_logic_vector(axi_araddr(12));
    m12_arvalid <= axi_arvalid(12);
    axi_arready(12) <= m12_arready;
    axi_rdata(12) <= m12_rdata;
    axi_rlast(12) <= m12_rlast;
    axi_rvalid(12) <= m12_rvalid;
    axi_rid(12) <= m12_rid;
    axi_bid(12) <= m12_bid;
    m12_awid <= axi_awid(12);
    m12_rready <= axi_rready(12);
    m12_arid <= axi_arid(12);
    m12_awaddr <= std_logic_vector(axi_awaddr(12));
    m12_awvalid <= axi_awvalid(12);
    axi_awready(12) <= m12_awready;
    m12_wdata <= axi_wdata(12);
    m12_wstrb <= axi_wstrb(12);
    m12_wlast <= axi_wlast(12);
    m12_wvalid <= axi_wvalid(12);
    axi_wready(12) <= m12_wready;
    axi_bvalid(12) <= m12_bvalid;
    m12_bready <= axi_bready(12);    
    
    m13_araddr <= std_logic_vector(axi_araddr(13));
    m13_arvalid <= axi_arvalid(13);
    axi_arready(13) <= m13_arready;
    axi_rdata(13) <= m13_rdata;
    axi_rlast(13) <= m13_rlast;
    axi_rvalid(13) <= m13_rvalid;
    axi_rid(13) <= m13_rid;
    axi_bid(13) <= m13_bid;
    m13_awid <= axi_awid(13);
    m13_rready <= axi_rready(13);
    m13_arid <= axi_arid(13);
    m13_awaddr <= std_logic_vector(axi_awaddr(13));
    m13_awvalid <= axi_awvalid(13);
    axi_awready(13) <= m13_awready;
    m13_wdata <= axi_wdata(13);
    m13_wstrb <= axi_wstrb(13);
    m13_wlast <= axi_wlast(13);
    m13_wvalid <= axi_wvalid(13);
    axi_wready(13) <= m13_wready;
    axi_bvalid(13) <= m13_bvalid;
    m13_bready <= axi_bready(13);    
    
    m14_araddr <= std_logic_vector(axi_araddr(14));
    m14_arvalid <= axi_arvalid(14);
    axi_arready(14) <= m14_arready;
    axi_rdata(14) <= m14_rdata;
    axi_rlast(14) <= m14_rlast;
    axi_rvalid(14) <= m14_rvalid;
    axi_rid(14) <= m14_rid;
    axi_bid(14) <= m14_bid;
    m14_awid <= axi_awid(14);
    m14_rready <= axi_rready(14);
    m14_arid <= axi_arid(14);
    m14_awaddr <= std_logic_vector(axi_awaddr(14));
    m14_awvalid <= axi_awvalid(14);
    axi_awready(14) <= m14_awready;
    m14_wdata <= axi_wdata(14);
    m14_wstrb <= axi_wstrb(14);
    m14_wlast <= axi_wlast(14);
    m14_wvalid <= axi_wvalid(14);
    axi_wready(14) <= m14_wready;
    axi_bvalid(14) <= m14_bvalid;
    m14_bready <= axi_bready(14);   
    
    m15_araddr <= std_logic_vector(axi_araddr(15));
    m15_arvalid <= axi_arvalid(15);
    axi_arready(15) <= m15_arready;
    axi_rdata(15) <= m15_rdata;
    axi_rlast(15) <= m15_rlast;
    axi_rvalid(15) <= m15_rvalid;
    axi_rid(15) <= m15_rid;
    axi_bid(15) <= m15_bid;
    m15_awid <= axi_awid(15);
    m15_rready <= axi_rready(15);
    m15_arid <= axi_arid(15);
    m15_awaddr <= std_logic_vector(axi_awaddr(15));
    m15_awvalid <= axi_awvalid(15);
    axi_awready(15) <= m15_awready;
    m15_wdata <= axi_wdata(15);
    m15_wstrb <= axi_wstrb(15);
    m15_wlast <= axi_wlast(15);
    m15_wvalid <= axi_wvalid(15);
    axi_wready(15) <= m15_wready;
    axi_bvalid(15) <= m15_bvalid;
    m15_bready <= axi_bready(15);     
  end generate;
  AXI_15_NOT: if N_AXI <= 8 generate
    m08_araddr  <= (others => '0');
    m08_arvalid <= '0';
    m08_awid    <= (others => '0');
    m08_rready  <= '0';
    m08_arid    <= (others => '0');
    m08_awaddr  <= (others => '0');
    m08_awvalid <= '0';
    m08_wdata   <= (others => '0');
    m08_wstrb   <= (others => '0');
    m08_wlast   <= '0';
    m08_wvalid  <= '0';
    m08_bready  <= '0';
    
    m09_araddr  <= (others => '0');
    m09_arvalid <= '0';
    m09_awid    <= (others => '0');
    m09_rready  <= '0';
    m09_arid    <= (others => '0');
    m09_awaddr  <= (others => '0');
    m09_awvalid <= '0';
    m09_wdata   <= (others => '0');
    m09_wstrb   <= (others => '0');
    m09_wlast   <= '0';
    m09_wvalid  <= '0';
    m09_bready  <= '0';
    
    m10_araddr  <= (others => '0');
    m10_arvalid <= '0';
    m10_awid    <= (others => '0');
    m10_rready  <= '0';
    m10_arid    <= (others => '0');
    m10_awaddr  <= (others => '0');
    m10_awvalid <= '0';
    m10_wdata   <= (others => '0');
    m10_wstrb   <= (others => '0');
    m10_wlast   <= '0';
    m10_wvalid  <= '0';
    m10_bready  <= '0'; 
    
    m11_araddr  <= (others => '0');
    m11_arvalid <= '0';
    m11_awid    <= (others => '0');
    m11_rready  <= '0';
    m11_arid    <= (others => '0');
    m11_awaddr  <= (others => '0');
    m11_awvalid <= '0';
    m11_wdata   <= (others => '0');
    m11_wstrb   <= (others => '0');
    m11_wlast   <= '0';
    m11_wvalid  <= '0';
    m11_bready  <= '0'; 

    m12_araddr  <= (others => '0');
    m12_arvalid <= '0';
    m12_awid    <= (others => '0');
    m12_rready  <= '0';
    m12_arid    <= (others => '0');
    m12_awaddr  <= (others => '0');
    m12_awvalid <= '0';
    m12_wdata   <= (others => '0');
    m12_wstrb   <= (others => '0');
    m12_wlast   <= '0';
    m12_wvalid  <= '0';
    m12_bready  <= '0'; 
    
    m13_araddr  <= (others => '0');
    m13_arvalid <= '0';
    m13_awid    <= (others => '0');
    m13_rready  <= '0';
    m13_arid    <= (others => '0');
    m13_awaddr  <= (others => '0');
    m13_awvalid <= '0';
    m13_wdata   <= (others => '0');
    m13_wstrb   <= (others => '0');
    m13_wlast   <= '0';
    m13_wvalid  <= '0';
    m13_bready  <= '0';    
    
    m14_araddr  <= (others => '0');
    m14_arvalid <= '0';
    m14_awid    <= (others => '0');
    m14_rready  <= '0';
    m14_arid    <= (others => '0');
    m14_awaddr  <= (others => '0');
    m14_awvalid <= '0';
    m14_wdata   <= (others => '0');
    m14_wstrb   <= (others => '0');
    m14_wlast   <= '0';
    m14_wvalid  <= '0';
    m14_bready  <= '0'; 
    
    m15_araddr  <= (others => '0');
    m15_arvalid <= '0';
    m15_awid    <= (others => '0');
    m15_rready  <= '0';
    m15_arid    <= (others => '0');
    m15_awaddr  <= (others => '0');
    m15_awvalid <= '0';
    m15_wdata   <= (others => '0');
    m15_wstrb   <= (others => '0');
    m15_wlast   <= '0';
    m15_wvalid  <= '0';
    m15_bready  <= '0';                    
  end generate;
  -- }}}
  ------------------------------------------------------------------------------------------------- }}}

  -- WG dispatcher FSM -------------------------------------------------------------------------------------- {{{
  regFile_we <= '1' when mainProc_wrAddr(INTERFCE_W_ADDR_W-1 downto INTERFCE_W_ADDR_W-2) = "10" and mainProc_we = '1' else '0';
  regs_trans: process(clk)
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        st_wg_disp    <= idle;
        Rstat         <= (others => '0');
        RcleanCache   <= (others => '0');
        Rstart        <= (others => '0');
        RInitiate     <= (others => '0');

        clean_cache    <= '0'; -- NOT NEEDED
        initialize_d0  <= '0'; -- NOT NEEDED
        s_wdata_d0    <= (others => '0'); -- NOT NEEDED
        finish_exec_d0 <= '0'; -- NOT NEEDED
      else
        s_wdata_d0    <= s_wdata; --to be moved to aw, w process
        finish_exec_d0 <= finish_exec;
        -- regFile_we_d0 <= regFile_we;

        if start_kernel = '1' then
          clean_cache   <= RcleanCache(new_krnl_indx);
          initialize_d0 <= RInitiate(new_krnl_indx);
        end if;

        st_wg_disp <= st_wg_disp_n;

        if start_kernel = '1' then
          Rstart(new_krnl_indx) <= '0';
        elsif regFile_we = '1' and to_integer(mainProc_wrAddr(N_REG_W-1 downto 0)) = Rstart_regFile_addr then
          Rstart <= s_wdata_d0(NEW_KRNL_MAX_INDX-1 downto 0); --written
                                                              --directly, is
                                                              --this safe?
        end if;

        if regFile_we = '1' and to_integer(mainProc_wrAddr(N_REG_W-1 downto 0)) = RcleanCache_regFile_addr then
          RcleanCache <= s_wdata_d0(NEW_KRNL_MAX_INDX-1 downto 0);
        end if;
        if regFile_we = '1' and to_integer(mainProc_wrAddr(N_REG_W-1 downto 0)) = RInitiate_regFile_addr then
          RInitiate <= s_wdata_d0(NEW_KRNL_MAX_INDX-1 downto 0);
        end if;

        if start_kernel = '1' then
          Rstat(new_krnl_indx) <= '0';
        elsif finish_exec = '1' and finish_exec_d0 = '0' then
          Rstat(finish_krnl_indx) <= '1';
        end if;
      end if;
    end if;
  end process;

  process(Rstart)
  begin
    new_krnl_indx <= 0;
    for i in NEW_KRNL_MAX_INDX-1 downto 0 loop
      if Rstart(i) = '1' then
        new_krnl_indx <= i;
      end if;
    end loop;
  end process;

  start_kernel <= '1' when st_wg_disp_n = st1_dispatch and st_wg_disp = idle else '0';

  --combinatorial part of the state machine (computes the next state)
  process(st_wg_disp, finish_exec, Rstart)
  begin
    st_wg_disp_n <= st_wg_disp;
    case(st_wg_disp) is
      when idle   =>
        if to_integer(unsigned(Rstart)) /= 0 then --new kernel to start
          st_wg_disp_n <= st1_dispatch;
        end if;
      when st1_dispatch =>
        if finish_exec = '1' then -- kernel is dispatched
          st_wg_disp_n <= idle;
        end if;
    end case;
  end process;
------------------------------------------------------------------------------------------------- }}}


-- debug -----------------------------------------------------------------------------------{{{

DEBUG_GEN_FALSE: if DEBUG_IMPLEMENT = 0 generate
  debug_gmem_read_counter    <= (others => '0');
  debug_gmem_write_counter   <= (others => '0');
  debug_op_counter           <= (others => '0');
  debug_reset_all_counters   <= '0';
end generate;

DEBUG_GEN_TRUE: if DEBUG_IMPLEMENT /= 0 generate

  -- combinatorial process that creates the debug_reset_all_counters flag
  process(Rstart)
  begin
    for i in 0 to NEW_KRNL_MAX_INDX-1 loop
      if (Rstart(i) = '1') then
        debug_reset_all_counters <= '1';
        exit;
      else
        debug_reset_all_counters <= '0';
      end if;
    end loop;
  end process;

  -- sequential process that gathers the counters of read/write operations on gmem from the CUs and sum them together
  process(clk)
    variable read_acc  : unsigned(2*DATA_W-1 downto 0) := (others => '0');
    variable write_acc : unsigned(2*DATA_W-1 downto 0) := (others => '0');
    variable op_acc    : unsigned(2*DATA_W-1 downto 0) := (others => '0');
  begin
    if rising_edge(clk) then
      if nrst = '0' then
        debug_gmem_read_counter <= (others => '0');
        debug_gmem_write_counter <= (others => '0');
        debug_op_counter <= (others => '0');
        read_acc := (others => '0');
        write_acc := (others => '0');
        op_acc := (others => '0');
      else
        if (debug_reset_all_counters = '1') then
          debug_gmem_read_counter <= (others => '0');
          debug_gmem_write_counter <= (others => '0');
          debug_op_counter <= (others => '0');
          read_acc := (others => '0');
          write_acc := (others => '0');
          op_acc := (others => '0');
        elsif finish_exec = '1' and finish_exec_d0 = '0' then
          for i in 0 to N_CU-1 loop
            read_acc := read_acc + to_integer(debug_gmem_read_counter_per_cu(i));
            write_acc := write_acc + to_integer(debug_gmem_write_counter_per_cu(i));
            op_acc := op_acc + to_integer(debug_op_counter_per_cu(i));
          end loop;
          debug_gmem_read_counter <= read_acc;
          debug_gmem_write_counter <= write_acc;
          debug_op_counter <= op_acc;
        end if;
      end if;
    end if;
  end process;


end generate;
--------------------------------------------------------------------------------------------}}}

end Behavioral;
