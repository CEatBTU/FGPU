library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library fgpu;
use fgpu.definitions.all;

package components is

  component fgpu_top
    port(
      clk  : in  std_logic;
      nrst : in  std_logic;

      s_awaddr  : in std_logic_vector(INTERFCE_W_ADDR_W-1 downto 0);
      s_awprot  : in std_logic_vector(2 downto 0);
      s_awvalid : in std_logic;
      s_awready : out std_logic;
      s_wdata   : in std_logic_vector(DATA_W-1 downto 0);
      s_wstrb   : in std_logic_vector((DATA_W/8)-1 downto 0);
      s_wvalid  : in std_logic;
      s_wready  : out std_logic;
      s_bresp   : out std_logic_vector(1 downto 0);
      s_bvalid  : out std_logic;
      s_bready  : in std_logic;
      s_araddr  : in std_logic_vector(INTERFCE_W_ADDR_W-1 downto 0);
      s_arprot  : in std_logic_vector(2 downto 0);
      s_arvalid : in std_logic;
      s_arready : out std_logic;
      s_rdata   : out std_logic_vector(DATA_W-1 downto 0);
      s_rresp   : out std_logic_vector(1 downto 0);
      s_rvalid  : out std_logic;
      s_rready  : in std_logic;

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
  end component;

  component div_unit
    port(
      clk, nrst        : in std_logic;

      div_a, div_b     : in std_logic_vector(DATA_W-1 downto 0);
      div_valid        : in std_logic;
      code             : in std_logic_vector(CODE_W-1 downto 0);

      res_div          : out std_logic_vector(DATA_W-1 downto 0)
    );
  end component;

  component float_units
    port(
      clk, nrst        : in std_logic;

      float_a, float_b : in SLV32_ARRAY(CV_SIZE-1 downto 0);
      fsub             : in std_logic;
      res_float        : out SLV32_ARRAY(CV_SIZE-1 downto 0);
      code             : in std_logic_vector(CODE_W-1 downto 0)
    );
  end component;

  component gmem_atomics
    port(
      clk, nrst           : in std_logic;
      rcv_atomic_type     : in be_array(N_RECEIVERS-1 downto 0);
      rcv_atomic_rqst     : in std_logic_vector(N_RECEIVERS-1 downto 0);
      rcv_gmem_addr       : in gmem_word_addr_array(N_RECEIVERS-1 downto 0);
      rcv_gmem_data       : in SLV32_ARRAY(N_RECEIVERS-1 downto 0);
      rcv_must_read       : out std_logic_vector(N_RECEIVERS-1 downto 0);
      rcv_atomic_ack      : out std_logic_vector(N_RECEIVERS-1 downto 0);
      gmem_rdAddr_p0      : in unsigned(GMEM_WORD_ADDR_W-N-1 downto 0);
      gmem_rdData         : in std_logic_vector(DATA_W*CACHE_N_BANKS-1 downto 0);
      gmem_rdData_v_p0    : in std_logic;
      atomic_rdData       : out std_logic_vector(DATA_W-1 downto 0);
      rcv_retire          : out std_logic_vector(N_RECEIVERS-1 downto 0);
      flush_v             : out std_logic;
      flush_gmem_addr     : out unsigned(GMEM_WORD_ADDR_W-1 downto 0);
      flush_data          : out std_logic_vector(DATA_W-1 downto 0);
      flush_ack           : in std_logic;
      flush_done          : in std_logic;
      finish              : in std_logic;
      atomic_can_finish   : out std_logic;
      WGsDispatched       : in std_logic
    );
  end component;

  component gmem_cntrl_tag
    port(
      clk, nrst                 : in std_logic;
      wr_fifo_free              : in std_logic_vector(N_WR_FIFOS-1 downto 0);
      wr_fifo_go                : out std_logic_vector(N_WR_FIFOS-1 downto 0);
      wr_fifo_cache_ack         : in std_logic_vector(N_WR_FIFOS-1 downto 0);
      axi_rdAddr                : out gmem_addr_array_no_bank(N_WR_FIFOS-1 downto 0);
      axi_writer_go             : out std_logic_vector(N_AXI-1 downto 0);
      axi_wrAddr                : out gmem_addr_array_no_bank(N_AXI-1 downto 0);
      axi_writer_free           : in std_logic_vector(N_AXI-1 downto 0);
      axi_rd_fifo_filled        : in std_logic_vector(N_AXI-1 downto 0);
      axi_wvalid                : in std_logic_vector(N_AXI-1 downto 0);
      axi_writer_ack            : in std_logic_vector(N_TAG_MANAGERS-1 downto 0);
      axi_writer_id             : out std_logic_vector(N_TAG_MANAGERS_W-1 downto 0);
      rcv_alloc_tag             : in std_logic_vector(N_RECEIVERS-1 downto 0);
      rcv_gmem_addr             : in gmem_word_addr_array(N_RECEIVERS-1 downto 0);
      rcv_rnw                   : in std_logic_vector(N_RECEIVERS-1 downto 0);
      rcv_tag_written           : out std_logic_vector(N_RECEIVERS-1 downto 0);
      rcv_tag_updated           : out std_logic_vector(N_RECEIVERS-1 downto 0);
      rcv_page_validated        : out std_logic_vector(N_RECEIVERS-1 downto 0);
      rcv_read_tag              : in std_logic_vector(N_RECEIVERS-1 downto 0);
      rcv_read_tag_ack          : out std_logic_vector(N_RECEIVERS-1 downto 0);
      rdData_page_v             : out std_logic_vector(N_RD_PORTS-1 downto 0);
      rdData_tag_v              : out std_logic_vector(N_RD_PORTS-1 downto 0);
      rdData_tag                : out tag_array(N_RD_PORTS-1 downto 0);
      cache_we                  : in std_logic;
      cache_addra               : in unsigned(M+L-1 downto 0);
      cache_wea                 : in std_logic_vector((2**N)*DATA_W/8-1 downto 0);
      WGsDispatched             : in std_logic;
      CUs_gmem_idle             : in std_logic;
      rcv_all_idle              : in std_logic;
      rcv_idle                  : in std_logic_vector(N_RECEIVERS-1 downto 0);
      finish_exec               : out std_logic;
      start_kernel              : in std_logic;
      clean_cache               : in std_logic;
      atomic_can_finish         : in std_logic;
      write_pipe_active         : in std_logic_vector(4 downto 0);
      write_pipe_wrTag          : in tag_addr_array(4 downto 0);
      debug_cache_miss_counter  : out unsigned(DATA_W-1 downto 0);
      debug_reset_all_counters  : in std_logic
    );
  end component;

  component gmem_cntrl
    port(
      clk                       : in std_logic;
      start_kernel              : in std_logic;
      clean_cache               : in std_logic;
      WGsDispatched             : in std_logic;
      CUs_gmem_idle             : in std_logic;
      finish_exec               : out std_logic;

      cu_valid                  : in std_logic_vector(N_CU-1 downto 0);
      cu_ready                  : out std_logic_vector(N_CU-1 downto 0);
      cu_we                     : in be_array(N_CU-1 downto 0);
      cu_rnw, cu_atomic         : in std_logic_vector(N_CU-1 downto 0);
      cu_atomic_sgntr           : in atomic_sgntr_array(N_CU-1 downto 0);
      cu_rqst_addr              : in GMEM_WORD_ADDR_ARRAY(N_CU-1 downto 0);
      cu_wrData                 : in SLV32_ARRAY(N_CU-1 downto 0);

      rdAck                     : out std_logic_vector(N_CU-1 downto 0);
      rdAddr                    : out unsigned(GMEM_WORD_ADDR_W-1-CACHE_N_BANKS_W downto 0);
      rdData                    : out std_logic_vector(DATA_W*CACHE_N_BANKS-1 downto 0);
      atomic_rdData             : out std_logic_vector(DATA_W-1 downto 0);
      atomic_rdData_v           : out std_logic_vector(N_CU-1 downto 0);
      atomic_sgntr              : out std_logic_vector(N_CU_STATIONS_W-1 downto 0);


      axi_araddr                : out GMEM_ADDR_ARRAY(N_AXI-1 downto 0);
      axi_arvalid               : out std_logic_vector(N_AXI-1 downto 0);
      axi_arready               : in std_logic_vector(N_AXI-1 downto 0);
      axi_arid                  : out id_array(N_AXI-1 downto 0);

      axi_rdata                 : in gmem_word_array(N_AXI-1 downto 0);
      axi_rlast                 : in std_logic_vector(N_AXI-1 downto 0);
      axi_rvalid                : in std_logic_vector(N_AXI-1 downto 0);
      axi_rready                : out std_logic_vector(N_AXI-1 downto 0);
      axi_rid                   : in id_array(N_AXI-1 downto 0);

      axi_awaddr                : out GMEM_ADDR_ARRAY(N_AXI-1 downto 0);
      axi_awvalid               : out std_logic_vector(N_AXI-1 downto 0);
      axi_awready               : in std_logic_vector(N_AXI-1 downto 0);
      axi_awid                  : out id_array(N_AXI-1 downto 0);

      axi_wdata                 : out gmem_word_array(N_AXI-1 downto 0);
      axi_wstrb                 : out gmem_be_array(N_AXI-1 downto 0);
      axi_wlast                 : out std_logic_vector(N_AXI-1 downto 0);
      axi_wvalid                : out std_logic_vector(N_AXI-1 downto 0);
      axi_wready                : in std_logic_vector(N_AXI-1 downto 0);

      axi_bvalid                : in std_logic_vector(N_AXI-1 downto 0);
      axi_bready                : out std_logic_vector(N_AXI-1 downto 0);
      axi_bid                   : in id_array(N_AXI-1 downto 0);


      debug_cache_miss_counter  : out unsigned(DATA_W-1 downto 0);
      debug_reset_all_counters  : in std_logic;

      nrst                      : in std_logic
    );
  end component;

  component init_alu_en_ram
    generic(
      N_RD_PORTS          : natural
    );
    port(
      start               : in std_logic;
      finish              : out std_logic;
      clear_finish        : in std_logic;
      wg_size             : in unsigned(N_WF_CU_W+WF_SIZE_W downto 0);
      sch_rqst_n_WFs_m1   : in unsigned(N_WF_CU_W-1 downto 0);
      rdData_alu_en       : out alu_en_vec_type(N_RD_PORTS-1 downto 0);
      rdAddr_alu_en       : in alu_en_rdAddr_type(N_RD_PORTS-1 downto 0);
      clk, nrst           : in std_logic
    );
  end component;

  component lmem
    port (
      clk                 : in std_logic;
      rqst, we            : in std_logic;
      alu_en              : in std_logic_vector(CV_SIZE-1 downto 0);
      wrData              : in SLV32_ARRAY(CV_SIZE-1 downto 0);
      rdData              : out SLV32_ARRAY(CV_SIZE-1 downto 0);
      rdData_v            : out std_logic;
      rdData_rd_addr      : out unsigned(REG_FILE_W-1 downto 0);
      rdData_alu_en       : out std_logic_vector(CV_SIZE-1 downto 0);
      sp                  : in unsigned(LMEM_ADDR_W-N_WF_CU_W-PHASE_W-1 downto 0);
      rd_addr             : in unsigned(REG_FILE_W-1 downto 0);
      nrst                : in std_logic
    );
  end component;

  component loc_indcs_generator
    port(
      start        : in std_logic;
      finish       : out std_logic;
      clear_finish : in std_logic;
      n_wf_wg_m1   : in unsigned(N_WF_CU_W-1 downto 0);
      wg_size_d0   : in integer range 0 to WG_MAX_SIZE;
      wg_size_d1   : in integer range 0 to WG_MAX_SIZE;
      wg_size_d2   : in integer range 0 to WG_MAX_SIZE;
      wrAddr       : out unsigned(RTM_ADDR_W-2 downto 0);
      we           : out std_logic;
      wrData       : out unsigned(RTM_DATA_W-1 downto 0);
      clk, nrst    : in std_logic
    );
  end component;

  component mult_add_sub
    generic (DATA_W  : natural := 32);
    port (
      sub               : in std_logic;
      a, c              : in unsigned (DATA_W-1 downto 0);
      b                 : in unsigned (DATA_W downto 0);
      sra_sign_v        : in std_logic;
      sra_sign          : in unsigned (DATA_W downto 0);
      sltu_true_p0      : out std_logic;
      res_low_p0        : out std_logic_vector(DATA_W-1 downto 0);
      res_high          : out std_logic_vector(DATA_W-1 downto 0);
      clk, nrst, ce     : in std_logic
    );
  end component;

  component rd_cache_fifo

    generic(
      SIZEA       : integer;
      ADDRWIDTHA  : integer;
      SIZEB       : integer;
      ADDRWIDTHB  : integer
    );
    port(
      clk                     : in  std_logic;
      push                    : in  std_logic;
      cache_rdData            : in  std_logic_vector(DATA_W*CACHE_N_BANKS - 1 downto 0);
      cache_rdAddr            : in unsigned(GMEM_WORD_ADDR_W-CACHE_N_BANKS_W-1 downto 0);
      rdData                  : out std_logic_vector(DATA_W*RD_CACHE_N_WORDS - 1 downto 0);
      rdAddr                  : out unsigned(GMEM_WORD_ADDR_W-RD_CACHE_N_WORDS_W-1 downto 0);
      nempty                  : out std_logic;
      nrst                    : in std_logic
    );
  end component;

  component regFile
    port(
      rs_addr, rt_addr    : in unsigned(REG_FILE_BLOCK_W-1 downto 0);
      rd_addr             : in unsigned(REG_FILE_BLOCK_W-1 downto 0);
      re                  : in std_logic;
      rs                  : out std_logic_vector(DATA_W-1 downto 0);
      rt                  : out std_logic_vector(DATA_W-1 downto 0);
      rd                  : out std_logic_vector(DATA_W-1 downto 0);
      we                  : in std_logic;
      wrAddr              : in unsigned(REG_FILE_BLOCK_W-1 downto 0);
      wrData              : in std_logic_vector(DATA_W-1 downto 0);
      clk, nrst           : in std_logic
    );
  end component;

  component rtm
    port(
      clk                 : in  std_logic;
      rtm_rdAddr          : in  unsigned(RTM_ADDR_W-1 downto 0);
      rtm_rdData          : out  unsigned(RTM_DATA_W-1 downto 0);
      rtm_wrData_cv       : in  unsigned(DATA_W-1 downto 0);
      rtm_wrAddr_cv       : in  unsigned(N_WF_CU_W+2-1 downto 0);
      rtm_we_cv           : in  std_logic;
      rtm_wrAddr_wg       : in  unsigned(RTM_ADDR_W-1 downto 0);
      rtm_wrData_wg       : in  unsigned(RTM_DATA_W-1 downto 0);
      rtm_we_wg           : in  std_logic;
      WGsDispatched       : in  std_logic;
      start_CUs           : in  std_logic;
      nrst                : in  std_logic
    );
  end component;

  component smem
    port(
      rqst                        : in std_logic; -- stage 0
      we                          : in std_logic; -- stage 0
      wrData                      : in SLV32_ARRAY(CV_SIZE - 1 downto 0);
      rdData                      : out SLV32_ARRAY(CV_SIZE - 1 downto 0);
      addr                        : in smem_addr_t(CV_SIZE-1 downto 0);
      rd_addr                     : in unsigned(REG_FILE_W - 1 downto 0);
      alu_en                      : in std_logic_vector(CV_SIZE - 1 downto 0);
      rdData_rd_addr              : out unsigned(REG_FILE_W - 1 downto 0);
      rdData_alu_en               : out std_logic_vector(CV_SIZE - 1 downto 0);
      rdData_v                    : out std_logic;
      num_wg_per_cu               : in unsigned(N_WF_CU_W downto 0);
      wf_distribution_on_wg       : in wf_distribution_on_wg_type(N_WF_CU-1 downto 0);
      smem_finish                 : out std_logic_vector(N_WF_CU-1 downto 0);
      reading_smem                : out std_logic;
      clk                         : in std_logic;
      nrst                        : in std_logic
    );
  end component;


  component wg_dispatcher
    port(
      clk, nrst           : in std_logic;
      start               : in std_logic;
      initialize_d0       : in std_logic;
      start_exec          : out std_logic;
      krnl_indx           : in integer range 0 to NEW_KRNL_MAX_INDX-1;
      krnl_sch_rdAddr     : out std_logic_vector(KRNL_SCH_ADDR_W-1 downto 0);
      krnl_sch_rdData     : in std_logic_vector(DATA_W-1 downto 0);
      finish              : out std_logic;
      finish_krnl_indx    : out integer range 0 to NEW_KRNL_MAX_INDX-1;
      start_addr          : out unsigned(CRAM_ADDR_W-1 downto 0);
      req                 : out std_logic_vector(N_CU-1 downto 0);
      ack                 : in std_logic_vector(N_CU-1 downto 0);
      sch_rqst_n_WFs_m1   : out unsigned(N_WF_CU_W-1 downto 0);
      wf_active           : in wf_active_array(N_CU-1 downto 0);
      wg_info             : out unsigned(DATA_W-1 downto 0);
      rdData_alu_en       : out alu_en_vec_type(N_CU-1 downto 0);
      rdAddr_alu_en       : in alu_en_rdAddr_type(N_CU-1 downto 0);
      rtm_wrAddr          : out unsigned(RTM_ADDR_W-1 downto 0);
      rtm_wrData          : out unsigned(RTM_DATA_W-1 downto 0);
      rtm_we              : out std_logic
    );
  end component;

  component alu
    port(
      rs_addr             : in unsigned(REG_FILE_BLOCK_W-1 downto 0);
      rt_addr             : in unsigned(REG_FILE_BLOCK_W-1 downto 0);
      rd_addr             : in unsigned(REG_FILE_BLOCK_W-1 downto 0);
      regBlock_re         : in std_logic_vector(N_REG_BLOCKS-1 downto 0);
      family              : in std_logic_vector(FAMILY_W-1 downto 0);
      op_arith_shift      : in op_arith_shift_type;
      code                : in std_logic_vector(CODE_W-1 downto 0);
      immediate           : in std_logic_vector(IMM_W-1 downto 0);
      rd_out              : out std_logic_vector(DATA_W-1 downto 0);
      reg_we_mov          : out std_logic;
      div_a               : out std_logic_vector(DATA_W-1 downto 0);
      div_b               : out std_logic_vector(DATA_W-1 downto 0);
      float_a             : out std_logic_vector(DATA_W-1 downto 0);
      float_b             : out std_logic_vector(DATA_W-1 downto 0);
      op_logical_v        : in std_logic;
      res_low             : out std_logic_vector(DATA_W-1 downto 0);
      res_high            : out std_logic_vector(DATA_W-1 downto 0);
      reg_wrData          : in slv32_array(N_REG_BLOCKS-1 downto 0);
      reg_wrAddr          : in reg_file_block_array(N_REG_BLOCKS-1 downto 0);
      reg_we              : in std_logic_vector(N_REG_BLOCKS-1 downto 0);
      clk                 : in std_logic;
      nrst                : in std_logic
    );
  end component;

  component axi_controllers
    port(
      axi_rdAddr          : in gmem_addr_array_no_bank(N_WR_FIFOS-1 downto 0);
      wr_fifo_go          : in std_logic_vector(N_WR_FIFOS-1 downto 0);
      wr_fifo_free        : out std_logic_vector(N_WR_FIFOS-1 downto 0);
      axi_wrAddr          : in gmem_addr_array_no_bank(N_AXI-1 downto 0);
      axi_writer_go       : in std_logic_vector(N_AXI-1 downto 0);
      axi_writer_free     : out std_logic_vector(N_AXI-1 downto 0);
      axi_writer_id       : in std_logic_vector(N_TAG_MANAGERS_W-1 downto 0);
      axi_writer_ack      : out std_logic_vector(N_TAG_MANAGERS-1 downto 0);
      wr_fifo_cache_rqst  : out std_logic_vector(N_WR_FIFOS-1 downto 0);
      rd_fifo_cache_rqst  : out std_logic_vector(N_AXI-1 downto 0);
      wr_fifo_cache_ack   : in std_logic_vector(N_WR_FIFOS-1 downto 0);
      rd_fifo_cache_ack   : in std_logic_vector(N_AXI-1 downto 0);
      wr_fifo_rqst_addr   : out cache_addr_array(N_WR_FIFOS-1 downto 0);
      rd_fifo_rqst_addr   : out cache_addr_array(N_AXI-1 downto 0);
      wr_fifo_dout        : out cache_word_array(N_WR_FIFOS-1 downto 0);
      cache_dob           : in std_logic_vector(DATA_W*2**N-1 downto 0);
      rd_fifo_din_v       : in std_logic_vector(N_AXI-1 downto 0);
      fifo_be_din         : in std_logic_vector(DATA_W/8*2**N-1 downto 0);
      axi_araddr          : out GMEM_ADDR_ARRAY(N_AXI-1 downto 0);
      axi_arvalid         : out std_logic_vector(N_AXI-1 downto 0);
      axi_arready         : in std_logic_vector(N_AXI-1 downto 0);
      axi_arid            : out id_array(N_AXI-1 downto 0);
      axi_rdata           : in gmem_word_array(N_AXI-1 downto 0);
      axi_rlast           : in std_logic_vector(N_AXI-1 downto 0);
      axi_rvalid          : in std_logic_vector(N_AXI-1 downto 0);
      axi_rready          : out std_logic_vector(N_AXI-1 downto 0);
      axi_rid             : in id_array(N_AXI-1 downto 0);
      axi_awaddr          : out GMEM_ADDR_ARRAY(N_AXI-1 downto 0);
      axi_awvalid         : out std_logic_vector(N_AXI-1 downto 0);
      axi_awready         : in std_logic_vector(N_AXI-1 downto 0);
      axi_awid            : out id_array(N_AXI-1 downto 0);
      axi_wdata           : out gmem_word_array(N_AXI-1 downto 0);
      axi_wstrb           : out gmem_be_array(N_AXI-1 downto 0);
      axi_wlast           : out std_logic_vector(N_AXI-1 downto 0);
      axi_wvalid          : out std_logic_vector(N_AXI-1 downto 0);
      axi_wready          : in std_logic_vector(N_AXI-1 downto 0);
      axi_bvalid          : in std_logic_vector(N_AXI-1 downto 0);
      axi_bready          : out std_logic_vector(N_AXI-1 downto 0);
      axi_bid             : in id_array(N_AXI-1 downto 0);
      clk, nrst           : std_logic
    );
  end component;

  component cache
    port(
      wea                 : in std_logic_vector(CACHE_N_BANKS*DATA_W/8-1 downto 0);
      ena                 : in std_logic;
      addra               : in unsigned(M+L-1 downto 0);
      dia                 : in std_logic_vector(CACHE_N_BANKS*DATA_W-1 downto 0);
      doa                 : out std_logic_vector(CACHE_N_BANKS*DATA_W-1 downto 0);
      enb, enb_be         : in std_logic;
      wr_fifo_rqst_addr   : in cache_addr_array(N_WR_FIFOS-1 downto 0);
      rd_fifo_rqst_addr   : in cache_addr_array(N_AXI-1 downto 0);
      wr_fifo_dout        : in cache_word_array(N_WR_FIFOS-1 downto 0);
      rd_fifo_din_v       : out std_logic_vector(N_AXI-1 downto 0);
      dob                 : out std_logic_vector(CACHE_N_BANKS*DATA_W-1 downto 0);
      ticket_rqst_wr      : in std_logic_vector(N_WR_FIFOS-1 downto 0);
      ticket_ack_wr_fifo  : out std_logic_vector(N_WR_FIFOS-1 downto 0);
      ticket_rqst_rd      : in std_logic_vector(N_AXI-1 downto 0);
      ticket_ack_rd_fifo  : out std_logic_vector(N_AXI-1 downto 0);
      be_rdData           : out std_logic_vector (DATA_W/8*2**N-1 downto 0);
      clk, nrst           : in std_logic
    );
  end component;

  component cu_instruction_dispatcher is
    port(
      clk, nrst             : in std_logic;
      cram_rqst             : out std_logic;
      cram_rdAddr           : out unsigned(CRAM_ADDR_W-1 downto 0);
      cram_rdAddr_conf      : in unsigned(CRAM_ADDR_W-1 downto 0);
      cram_rdData           : in std_logic_vector(DATA_W-1 downto 0);
      PC_indx               : in integer range 0 to N_WF_CU-1;
      wf_active             : in std_logic_vector(N_WF_CU-1 downto 0);
      pc_updated            : in std_logic_vector(N_WF_CU-1 downto 0);
      PCs                   : in CRAM_ADDR_ARRAY(N_WF_CU-1 downto 0);
      pc_rdy                : out std_logic_vector(N_WF_CU-1 downto 0);
      instr                 : out std_logic_vector(DATA_W-1 downto 0);
      instr_gmem_op         : out std_logic_vector(N_WF_CU-1 downto 0);
	    instr_gmem_read       : out std_logic_vector(N_WF_CU-1 downto 0);
      instr_scratchpad_ld   : out std_logic_vector(N_WF_CU-1 downto 0);
      instr_smem_op         : out std_logic_vector(N_WF_CU-1 downto 0);
      instr_smem_read       : out std_logic_vector(N_WF_CU-1 downto 0);
      instr_branch          : out std_logic_vector(N_WF_CU-1 downto 0);
      instr_jump            : out std_logic_vector(N_WF_CU-1 downto 0);
      instr_fpu             : out std_logic_vector(N_WF_CU-1 downto 0);
      instr_sync            : out std_logic_vector(N_WF_CU-1 downto 0);
      branch_distance       : out branch_distance_vec(0 to N_WF_CU-1);
      wf_retired            : out std_logic_vector(N_WF_CU-1 downto 0)
    );
  end component;

  component cu_mem_cntrl
    port(
      clk                     : in std_logic;
      cv_wrData               : in SLV32_ARRAY(CV_SIZE-1 downto 0);
      cv_addr                 : in GMEM_ADDR_ARRAY;
      cv_gmem_we              : in std_logic;
      cv_gmem_re              : in std_logic;
      cv_gmem_atomic          : in std_logic;
      cv_lmem_rqst            : in std_logic;
      cv_lmem_we              : in std_logic;
      cv_smem_rqst            : in std_logic;
      cv_smem_we              : in std_logic;
      cv_op_type              : in std_logic_vector(2 downto 0);
      cv_alu_en               : in std_logic_vector(CV_SIZE-1 downto 0);
      cv_alu_en_pri_enc       : in integer range 0 to CV_SIZE-1;
      cv_rd_addr              : in unsigned(REG_FILE_W-1 downto 0);
      regFile_wrAddr          : out unsigned(REG_FILE_W-1 downto 0);
      regFile_we              : out std_logic_vector(CV_SIZE-1 downto 0);
      regFile_wrData          : out SLV32_ARRAY(CV_SIZE-1 downto 0);
      regFile_we_lmem_p0      : out std_logic;
      regFile_we_smem         : out std_logic_vector(CV_SIZE-1 downto 0);
      cache_rdAck             : in std_logic;
      cache_rdAddr            : in unsigned(GMEM_WORD_ADDR_W-CACHE_N_BANKS_W-1 downto 0);
      cache_rdData            : in std_logic_vector(DATA_W*CACHE_N_BANKS-1 downto 0);
      atomic_rdData           : in std_logic_vector(DATA_W-1 downto 0);
      atomic_rdData_v         : in std_logic;
      atomic_sgntr            : in std_logic_vector(N_CU_STATIONS_W-1 downto 0);
      gmem_wrData             : out std_logic_vector(DATA_W-1 downto 0);
      gmem_valid              : out std_logic;
      gmem_we                 : out std_logic_vector(DATA_W/8-1 downto 0);
      gmem_rnw                : out std_logic;
      gmem_atomic             : out std_logic;
      gmem_atomic_sgntr       : out std_logic_vector(N_CU_STATIONS_W-1 downto 0);
      gmem_ready              : in std_logic;
      gmem_rqst_addr          : out unsigned(GMEM_WORD_ADDR_W-1 downto 0);
      wf_finish               : out std_logic_vector(N_WF_CU-1 downto 0);
	    smem_finish             : out std_logic_vector(N_WF_CU-1 downto 0);
      cntrl_idle              : out std_logic;
      wf_distribution_on_wg   : in wf_distribution_on_wg_type(N_WF_CU-1 downto 0);
      num_wg_per_cu           : in unsigned(N_WF_CU_W downto 0);

      debug_gmem_read_counter_per_cu  : out unsigned(2*DATA_W-1 downto 0);
      debug_gmem_write_counter_per_cu : out unsigned(2*DATA_W-1 downto 0);
      debug_reset_all_counters        : in std_logic;

      nrst                    : in std_logic
    );
  end component;

  component cu_scheduler
    port(
      clk, nrst              : in std_logic;
      wf_active              : out std_logic_vector(N_WF_CU-1 downto 0);
      sch_rqst               : in std_logic;
      sch_ack                : out std_logic;
      sch_rqst_n_wfs_m1      : in unsigned(N_WF_CU_W-1 downto 0);
      wg_info                : in unsigned(DATA_W-1 downto 0);
      cram_rdAddr            : out unsigned(CRAM_ADDR_W-1 downto 0);
      cram_rdAddr_conf       : in unsigned(CRAM_ADDR_W-1 downto 0);
      cram_rdData            : in std_logic_vector(DATA_W-1 downto 0);
      cram_rqst              : out std_logic;
      start_addr             : in unsigned(CRAM_ADDR_W-1 downto 0);
      wf_is_branching        : in std_logic_vector(N_WF_CU-1 downto 0);
      alu_branch             : in std_logic_vector(CV_SIZE-1 downto 0);
      alu_en                 : in std_logic_vector(CV_SIZE-1 downto 0);
      rtm_wrAddr_cv          : out unsigned(N_WF_CU_W+2-1 downto 0);
      rtm_wrData_cv          : out unsigned(DATA_W-1 downto 0);
      rtm_we_cv              : out std_logic;
      gmem_finish            : in std_logic_vector(N_WF_CU-1 downto 0);
	    smem_finish            : in std_logic_vector(N_WF_CU-1 downto 0);
      instr                  : out std_logic_vector(DATA_W-1 downto 0);
      wf_indx_in_wg          : out natural range 0 to N_WF_CU-1;
      wf_indx_in_CU          : out natural range 0 to N_WF_CU-1;
      alu_en_divStack        : out std_logic_vector(CV_SIZE-1 downto 0);
      phase                  : out unsigned(PHASE_W-1 downto 0);
      finish_exec            : in std_logic;
      finish_exec_d0         : in std_logic;
      num_wg_per_cu          : out unsigned(N_WF_CU_W downto 0);
      wf_distribution_on_wg  : out wf_distribution_on_wg_type(N_WF_CU-1 downto 0);
      wf_sync_retired        : in std_logic_vector(N_WF_CU-1 downto 0);
      wi_barrier_reached     : in std_logic_vector(N_WF_CU-1 downto 0);
      cu_is_working          : out std_logic
    );
  end component;

  component cu
    port(
      clk                 : in std_logic;
      cram_rdAddr         : out unsigned(CRAM_ADDR_W-1 downto 0);
      cram_rdAddr_conf    : in unsigned(CRAM_ADDR_W-1 downto 0);
      cram_rdData         : in std_logic_vector(DATA_W-1 downto 0);
      cram_rqst           : out std_logic;
      start_addr          : in unsigned(CRAM_ADDR_W-1 downto 0);
      sch_rqst_n_wfs_m1   : in unsigned(N_WF_CU_W-1 downto 0);
      wg_info             : in unsigned(DATA_W-1 downto 0);
      sch_rqst            : in std_logic;
      wf_active           : out std_logic_vector(N_WF_CU-1 downto 0);
      sch_ack             : out std_logic;
      start_CUs           : in std_logic;
      WGsDispatched       : in std_logic;
      rtm_wrAddr_wg       : in unsigned(RTM_ADDR_W-1 downto 0);
      rtm_wrData_wg       : in unsigned(RTM_DATA_W-1 downto 0);
      rtm_we_wg           : in std_logic;
      rdData_alu_en       : in std_logic_vector(CV_SIZE-1 downto 0);
      rdAddr_alu_en       : out unsigned(N_WF_CU_W+PHASE_W-1 downto 0);
      cache_rdData        : in std_logic_vector(CACHE_N_BANKS*DATA_W-1 downto 0);
      cache_rdAck         : in std_logic;
      cache_rdAddr        : in unsigned(GMEM_WORD_ADDR_W-CACHE_N_BANKS_W-1 downto 0);
      atomic_rdData       : in std_logic_vector(DATA_W-1 downto 0);
      atomic_rdData_v     : in std_logic;
      atomic_sgntr        : in std_logic_vector(N_CU_STATIONS_W-1 downto 0);
      gmem_wrData         : out std_logic_vector(DATA_W-1 downto 0);
      gmem_valid          : out std_logic;
      gmem_we             : out std_logic_vector(DATA_W/8-1 downto 0);
      gmem_rnw            : out std_logic;
      gmem_atomic         : out std_logic;
      gmem_atomic_sgntr   : out std_logic_vector(N_CU_STATIONS_W-1 downto 0);
      gmem_rqst_addr      : out unsigned(GMEM_WORD_ADDR_W-1 downto 0);
      gmem_ready          : in std_logic;
      gmem_cntrl_idle     : out std_logic;


      finish_exec         : in std_logic;
      finish_exec_d0      : in std_logic;

      debug_gmem_read_counter_per_cu  : out unsigned(2*DATA_W-1 downto 0);
      debug_gmem_write_counter_per_cu : out unsigned(2*DATA_W-1 downto 0);
      debug_op_counter_per_cu         : out unsigned(2*DATA_W-1 downto 0);
      debug_reset_all_counters        : in std_logic;

      nrst                : in std_logic
    );
  end component;

  component cu_vector
    port(
      instr                           : in std_logic_vector(DATA_W-1 downto 0);
      wf_indx, wf_indx_in_wg          : in natural range 0 to N_WF_CU-1;
      phase                           : in unsigned(PHASE_W-1 downto 0);
      alu_en_divStack                 : in std_logic_vector(CV_SIZE-1 downto 0);
      rdAddr_alu_en                   : out unsigned(N_WF_CU_W+PHASE_W-1 downto 0);
      rdData_alu_en                   : in std_logic_vector(CV_SIZE-1 downto 0);
      rtm_rdAddr                      : out unsigned(RTM_ADDR_W-1 downto 0);
      rtm_rdData                      : in unsigned(RTM_DATA_W-1 downto 0);
      gmem_re, gmem_we                : out std_logic;
      mem_op_type                     : out std_logic_vector(2 downto 0);
      mem_addr                        : out GMEM_ADDR_ARRAY(CV_SIZE-1 downto 0);
      mem_rd_addr                     : out unsigned(REG_FILE_W-1 downto 0);
      mem_wrData                      : out SLV32_ARRAY(CV_SIZE-1 downto 0);
      alu_en                          : out std_logic_vector(CV_SIZE-1 downto 0);
      alu_en_pri_enc                  : out integer range 0 to CV_SIZE-1;
      lmem_rqst, lmem_we              : out std_logic;
      smem_rqst, smem_we              : out std_logic;
      gmem_atomic                     : out std_logic;
      wf_is_branching                 : out std_logic_vector(N_WF_CU-1 downto 0);
      alu_branch                      : out std_logic_vector(CV_SIZE-1 downto 0);
      mem_regFile_wrAddr              : in unsigned(REG_FILE_W-1 downto 0);
      mem_regFile_we                  : in std_logic_vector(CV_SIZE-1 downto 0);
      mem_regFile_wrData              : in SLV32_ARRAY(CV_SIZE-1 downto 0);
      lmem_regFile_we_p0              : in std_logic;
      smem_regFile_we                 : in std_logic_vector(CV_SIZE-1 downto 0);
      wf_sync_retired                 : out std_logic_vector(N_WF_CU-1 downto 0);
      wi_barrier_reached              : out std_logic_vector(N_WF_CU-1 downto 0);
      debug_op_counter_per_cu         : out unsigned(2*DATA_W-1 downto 0);
      debug_reset_all_counters        : in std_logic;
      cu_is_working                   : in std_logic;
      clk                             : in std_logic;
      nrst                            : in std_logic
    );
  end component;

  -- FPGA

  component dsp
    generic (
      SIZE_A : natural;
      SIZE_B : natural;
      SUB    : boolean
    );
    port (
      clk, nrst, ce : in std_logic;
      ain           : in unsigned(SIZE_A-1 downto 0);
      bin           : in unsigned(SIZE_B-1 downto 0);
      cin           : in unsigned(SIZE_A+SIZE_B-1 downto 0);
      res           : out unsigned(SIZE_A+SIZE_B-1 downto 0)
    );
  end component;

  component fslt
    port (
      aclk : in std_logic;
      s_axis_a_tvalid : in std_logic;
      s_axis_a_tdata : in std_logic_vector(31 downto 0);
      s_axis_b_tvalid : in std_logic;
      s_axis_b_tdata : in std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic;
      m_axis_result_tdata : out std_logic_vector(7 downto 0)
    );
  end component;

  component fsqrt
    port (
      aclk : in std_logic;
      s_axis_a_tvalid : in std_logic;
      s_axis_a_tdata : in std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic;
      m_axis_result_tdata : out std_logic_vector(31 downto 0)
    );
  end component;

  component frsqrt
    port (
      aclk : in std_logic;
      s_axis_a_tvalid : in std_logic;
      s_axis_a_tdata : in std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic;
      m_axis_result_tdata : out std_logic_vector(31 downto 0)
    );
  end component;

  component fmul
    port (
      aclk : in std_logic;
      s_axis_a_tvalid : in std_logic;
      s_axis_a_tdata : in std_logic_vector(31 downto 0);
      s_axis_b_tvalid : in std_logic;
      s_axis_b_tdata : in std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic;
      m_axis_result_tdata : out std_logic_vector(31 downto 0)
    );
  end component;

  component fdiv
    port (
      aclk : in std_logic;
      s_axis_a_tvalid : in std_logic;
      s_axis_a_tdata : in std_logic_vector(31 downto 0);
      s_axis_b_tvalid : in std_logic;
      s_axis_b_tdata : in std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic;
      m_axis_result_tdata : out std_logic_vector(31 downto 0)
    );
  end component;

  component fadd_fsub
    port (
      aclk : in std_logic;
      s_axis_a_tvalid : in std_logic;
      s_axis_a_tdata : in std_logic_vector(31 downto 0);
      s_axis_b_tvalid : in std_logic;
      s_axis_b_tdata : in std_logic_vector(31 downto 0);
      s_axis_operation_tvalid : in std_logic;
      s_axis_operation_tdata : in std_logic_vector(7 downto 0);
      m_axis_result_tvalid : out std_logic;
      m_axis_result_tdata : out std_logic_vector(31 downto 0)
    );
  end component;

  component uitofp
    port (
      aclk : in std_logic;
      s_axis_a_tvalid : in std_logic;
      s_axis_a_tdata : in std_logic_vector(31 downto 0);
      m_axis_result_tvalid : out std_logic;
      m_axis_result_tdata : out std_logic_vector(31 downto 0)
    );
  end component;

  component sdiv is
    port (
      aclk : in std_logic;
      s_axis_divisor_tvalid : in std_logic;
      s_axis_divisor_tdata : in std_logic_vector ( 31 downto 0 );
      s_axis_dividend_tvalid : in std_logic;
      s_axis_dividend_tdata : in std_logic_vector ( 31 downto 0 );
      m_axis_dout_tvalid : out std_logic;
      m_axis_dout_tdata : out std_logic_vector ( 63 downto 0 )
    );
  end component;

  component udiv is
    port (
      aclk : in std_logic;
      s_axis_divisor_tvalid : in std_logic;
      s_axis_divisor_tdata : in std_logic_vector ( 31 downto 0 );
      s_axis_dividend_tvalid : in std_logic;
      s_axis_dividend_tdata : in std_logic_vector ( 31 downto 0 );
      m_axis_dout_tvalid : out std_logic;
      m_axis_dout_tdata : out std_logic_vector ( 63 downto 0 )
    );
  end component;

  -- Simulation

  component global_mem
    generic(
      MEM_PHY_ADDR_W   : natural := 17;
      ADDR_OFFSET      : unsigned := X"1000_0000";
      MAX_NDRANGE_SIZE : natural := 64*1024
    );
    port(
      new_kernel          : in std_logic;
      finished_kernel     : in std_logic;
      size_0              : in natural;
      size_1              : in natural;
      target_offset_addr  : in natural := 2**(N+L+M-1+2);
      problemSize         : in natural;
      -- AXI Slave Interfaces
      -- common signals
      mx_arlen_awlen      : in std_logic_vector(7 downto 0);
      -- interface 0 {{{
      -- ar channel
      m00_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m00_arvalid          : in std_logic;
      m00_arready          : buffer std_logic;
      m00_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m00_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m00_rlast            : out std_logic;
      m00_rvalid           : buffer std_logic;
      m00_rready           : in std_logic;
      m00_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m00_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m00_awvalid          : in std_logic;
      m00_awready          : buffer std_logic;
      m00_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m00_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m00_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m00_wlast            : in std_logic;
      m00_wvalid           : in std_logic;
      m00_wready           : buffer std_logic;
      -- b channel
      m00_bvalid           : out std_logic;
      m00_bready           : in std_logic;
      m00_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}
      -- interface 1 {{{
      -- ar channel
      m01_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m01_arvalid          : in std_logic;
      m01_arready          : buffer std_logic;
      m01_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m01_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m01_rlast            : out std_logic;
      m01_rvalid           : buffer std_logic;
      m01_rready           : in std_logic;
      m01_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m01_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m01_awvalid          : in std_logic;
      m01_awready          : buffer std_logic;
      m01_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m01_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m01_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m01_wlast            : in std_logic;
      m01_wvalid           : in std_logic;
      m01_wready           : buffer std_logic;
      -- b channel
      m01_bvalid           : out std_logic;
      m01_bready           : in std_logic;
      m01_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}
      -- interface 2 {{{
      -- ar channel
      m02_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m02_arvalid          : in std_logic;
      m02_arready          : buffer std_logic;
      m02_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m02_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m02_rlast            : out std_logic;
      m02_rvalid           : buffer std_logic;
      m02_rready           : in std_logic;
      m02_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m02_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m02_awvalid          : in std_logic;
      m02_awready          : buffer std_logic;
      m02_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m02_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m02_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m02_wlast            : in std_logic;
      m02_wvalid           : in std_logic;
      m02_wready           : buffer std_logic;
      -- b channel
      m02_bvalid           : out std_logic;
      m02_bready           : in std_logic;
      m02_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}
      -- interface 3 {{{
      -- ar channel
      m03_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m03_arvalid          : in std_logic;
      m03_arready          : buffer std_logic;
      m03_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m03_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m03_rlast            : out std_logic;
      m03_rvalid           : buffer std_logic;
      m03_rready           : in std_logic;
      m03_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m03_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m03_awvalid          : in std_logic;
      m03_awready          : buffer std_logic;
      m03_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m03_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m03_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m03_wlast            : in std_logic;
      m03_wvalid           : in std_logic;
      m03_wready           : buffer std_logic;
      -- b channel
      m03_bvalid           : out std_logic;
      m03_bready           : in std_logic;
      m03_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}
      -- interface 4 {{{
      -- ar channel
      m04_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m04_arvalid          : in std_logic;
      m04_arready          : buffer std_logic;
      m04_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m04_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m04_rlast            : out std_logic;
      m04_rvalid           : buffer std_logic;
      m04_rready           : in std_logic;
      m04_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m04_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m04_awvalid          : in std_logic;
      m04_awready          : buffer std_logic;
      m04_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m04_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m04_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m04_wlast            : in std_logic;
      m04_wvalid           : in std_logic;
      m04_wready           : buffer std_logic;
      -- b channel
      m04_bvalid           : out std_logic;
      m04_bready           : in std_logic;
      m04_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}
      -- interface 5 {{{
      -- ar channel
      m05_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m05_arvalid          : in std_logic;
      m05_arready          : buffer std_logic;
      m05_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m05_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m05_rlast            : out std_logic;
      m05_rvalid           : buffer std_logic;
      m05_rready           : in std_logic;
      m05_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m05_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m05_awvalid          : in std_logic;
      m05_awready          : buffer std_logic;
      m05_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m05_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m05_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m05_wlast            : in std_logic;
      m05_wvalid           : in std_logic;
      m05_wready           : buffer std_logic;
      -- b channel
      m05_bvalid           : out std_logic;
      m05_bready           : in std_logic;
      m05_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}
      -- interface 6 {{{
      -- ar channel
      m06_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m06_arvalid          : in std_logic;
      m06_arready          : buffer std_logic;
      m06_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m06_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m06_rlast            : out std_logic;
      m06_rvalid           : buffer std_logic;
      m06_rready           : in std_logic;
      m06_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m06_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m06_awvalid          : in std_logic;
      m06_awready          : buffer std_logic;
      m06_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m06_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m06_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m06_wlast            : in std_logic;
      m06_wvalid           : in std_logic;
      m06_wready           : buffer std_logic;
      -- b channel
      m06_bvalid           : out std_logic;
      m06_bready           : in std_logic;
      m06_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}
      -- interface 7 {{{
      -- ar channel
      m07_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m07_arvalid          : in std_logic;
      m07_arready          : buffer std_logic;
      m07_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m07_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m07_rlast            : out std_logic;
      m07_rvalid           : buffer std_logic;
      m07_rready           : in std_logic;
      m07_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m07_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m07_awvalid          : in std_logic;
      m07_awready          : buffer std_logic;
      m07_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m07_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m07_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m07_wlast            : in std_logic;
      m07_wvalid           : in std_logic;
      m07_wready           : buffer std_logic;
      -- b channel
      m07_bvalid           : out std_logic;
      m07_bready           : in std_logic;
      m07_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}      
      -- interface 8 {{{
      -- ar channel
      m08_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m08_arvalid          : in std_logic;
      m08_arready          : buffer std_logic;
      m08_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m08_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m08_rlast            : out std_logic;
      m08_rvalid           : buffer std_logic;
      m08_rready           : in std_logic;
      m08_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m08_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m08_awvalid          : in std_logic;
      m08_awready          : buffer std_logic;
      m08_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m08_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m08_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m08_wlast            : in std_logic;
      m08_wvalid           : in std_logic;
      m08_wready           : buffer std_logic;
      -- b channel
      m08_bvalid           : out std_logic;
      m08_bready           : in std_logic;
      m08_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}} 
      -- interface 9 {{{
      -- ar channel
      m09_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m09_arvalid          : in std_logic;
      m09_arready          : buffer std_logic;
      m09_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m09_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m09_rlast            : out std_logic;
      m09_rvalid           : buffer std_logic;
      m09_rready           : in std_logic;
      m09_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m09_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m09_awvalid          : in std_logic;
      m09_awready          : buffer std_logic;
      m09_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m09_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m09_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m09_wlast            : in std_logic;
      m09_wvalid           : in std_logic;
      m09_wready           : buffer std_logic;
      -- b channel
      m09_bvalid           : out std_logic;
      m09_bready           : in std_logic;
      m09_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}} 
      -- interface 10 {{{
      -- ar channel
      m10_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m10_arvalid          : in std_logic;
      m10_arready          : buffer std_logic;
      m10_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m10_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m10_rlast            : out std_logic;
      m10_rvalid           : buffer std_logic;
      m10_rready           : in std_logic;
      m10_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m10_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m10_awvalid          : in std_logic;
      m10_awready          : buffer std_logic;
      m10_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m10_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m10_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m10_wlast            : in std_logic;
      m10_wvalid           : in std_logic;
      m10_wready           : buffer std_logic;
      -- b channel
      m10_bvalid           : out std_logic;
      m10_bready           : in std_logic;
      m10_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}    
      -- interface 11 {{{
      -- ar channel
      m11_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m11_arvalid          : in std_logic;
      m11_arready          : buffer std_logic;
      m11_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m11_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m11_rlast            : out std_logic;
      m11_rvalid           : buffer std_logic;
      m11_rready           : in std_logic;
      m11_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m11_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m11_awvalid          : in std_logic;
      m11_awready          : buffer std_logic;
      m11_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m11_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m11_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m11_wlast            : in std_logic;
      m11_wvalid           : in std_logic;
      m11_wready           : buffer std_logic;
      -- b channel
      m11_bvalid           : out std_logic;
      m11_bready           : in std_logic;
      m11_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}  
      -- interface 12 {{{
      -- ar channel
      m12_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m12_arvalid          : in std_logic;
      m12_arready          : buffer std_logic;
      m12_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m12_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m12_rlast            : out std_logic;
      m12_rvalid           : buffer std_logic;
      m12_rready           : in std_logic;
      m12_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m12_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m12_awvalid          : in std_logic;
      m12_awready          : buffer std_logic;
      m12_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m12_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m12_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m12_wlast            : in std_logic;
      m12_wvalid           : in std_logic;
      m12_wready           : buffer std_logic;
      -- b channel
      m12_bvalid           : out std_logic;
      m12_bready           : in std_logic;
      m12_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}  
      -- interface 13 {{{
      -- ar channel
      m13_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m13_arvalid          : in std_logic;
      m13_arready          : buffer std_logic;
      m13_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m13_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m13_rlast            : out std_logic;
      m13_rvalid           : buffer std_logic;
      m13_rready           : in std_logic;
      m13_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m13_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m13_awvalid          : in std_logic;
      m13_awready          : buffer std_logic;
      m13_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m13_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m13_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m13_wlast            : in std_logic;
      m13_wvalid           : in std_logic;
      m13_wready           : buffer std_logic;
      -- b channel
      m13_bvalid           : out std_logic;
      m13_bready           : in std_logic;
      m13_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}  
      -- interface 14 {{{
      -- ar channel
      m14_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m14_arvalid          : in std_logic;
      m14_arready          : buffer std_logic;
      m14_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m14_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m14_rlast            : out std_logic;
      m14_rvalid           : buffer std_logic;
      m14_rready           : in std_logic;
      m14_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m14_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m14_awvalid          : in std_logic;
      m14_awready          : buffer std_logic;
      m14_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m14_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m14_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m14_wlast            : in std_logic;
      m14_wvalid           : in std_logic;
      m14_wready           : buffer std_logic;
      -- b channel
      m14_bvalid           : out std_logic;
      m14_bready           : in std_logic;
      m14_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}  
      -- interface 15 {{{
      -- ar channel
      m15_araddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m15_arvalid          : in std_logic;
      m15_arready          : buffer std_logic;
      m15_arid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- r channel
      m15_rdata            : out std_logic_vector(GMEM_DATA_W-1 downto 0);
      m15_rlast            : out std_logic;
      m15_rvalid           : buffer std_logic;
      m15_rready           : in std_logic;
      m15_rid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- aw channel
      m15_awaddr           : in std_logic_vector(GMEM_ADDR_W-1 downto 0);
      m15_awvalid          : in std_logic;
      m15_awready          : buffer std_logic;
      m15_awid             : in std_logic_vector(ID_WIDTH-1 downto 0);
      -- w channel
      m15_wdata            : in std_logic_vector(GMEM_DATA_W-1 downto 0);
      m15_wstrb            : in std_logic_vector(GMEM_DATA_W/8-1 downto 0);
      m15_wlast            : in std_logic;
      m15_wvalid           : in std_logic;
      m15_wready           : buffer std_logic;
      -- b channel
      m15_bvalid           : out std_logic;
      m15_bready           : in std_logic;
      m15_bid              : out std_logic_vector(ID_WIDTH-1 downto 0);
      -- }}}  
      clk, nrst           : in  std_logic
    );
  end component;

end package;
