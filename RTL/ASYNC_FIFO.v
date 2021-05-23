module ASYNC_FIFO
#(
    parameter DW = 8
   ,parameter AW = 4
//   ,parameter SYNC = 0
)
(
    input           I_WR_CLK
   ,input           I_WR_RST_N
   ,input  [DW-1:0] I_WR_DATA
   ,input           I_WR_REQ
   ,output          O_WR_FULL
   ,input           I_RD_CLK
   ,input           I_RD_RST_N
   ,input           I_RD_REQ
   ,output [DW-1:0] O_RD_DATA
   ,output          O_RD_EMPTY

);

    wire            w_is_wr_enabled_wr_clk = I_WR_REQ && !O_WR_FULL;
    wire            w_is_rd_enabled_rd_clk = I_RD_REQ && !O_RD_EMPTY;

    wire [AW-1:0]   w_wr_addr_wr_clk;
    wire [AW  :0]   w_wr_ptr_wr_clk;
    wire [AW  :0]   w_wr_ptr_rd_clk;

    wire [AW-1:0]   w_rd_addr_rd_clk;
    wire [AW  :0]   w_rd_ptr_rd_clk;
    wire [AW  :0]   w_rd_ptr_wr_clk;


FIFO_WR
#(
    .DW(DW)
   ,.AW(AW)
) Inst_FIFO_WR
(
    .I_WR_CLK    ( I_WR_CLK                 ) // input               I_WR_CLK
   ,.I_WR_RST_N  ( I_WR_RST_N               ) // input               I_WR_RST_N
   ,.I_WR_EN     ( w_is_wr_enabled_wr_clk   ) // input               I_WR_EN
   ,.I_WR_RD_PTR ( w_rd_ptr_wr_clk          ) // input  [AW  :0]     I_WR_RD_PTR     // Gray-coded rd pointer sync to wr clock
   ,.O_WR_ADDR   ( w_wr_addr_wr_clk         ) // output [AW-1:0]     O_WR_ADDR       // Binary wr memory address
   ,.O_WR_PTR    ( w_wr_ptr_wr_clk          ) // output [AW  :0]     O_WR_PTR        // Gray-coded wr pointer sync to wr clock
   ,.O_WR_FULL   ( O_WR_FULL                ) // output              O_WR_FULL
);

SYNCHRONIZER
#(
    .DW(AW+1)        // Data Width
) Inst_SYNCHRONIZER_WR_PTR_TO_RD_PTR
(
     .I_CLK   ( I_RD_CLK        ) //input               I_CLK
    ,.I_RST_N ( I_RD_RST_N      ) //input               I_RST_N
    ,.I_D     ( w_wr_ptr_wr_clk ) //input   [DW-1:0]    I_D
    ,.O_Q     ( w_wr_ptr_rd_clk ) //output  [DW-1:0]    O_Q
);

FIFO_MEM
#(
    .DW(DW)// Data Width
   ,.AW(AW)// Address Width
) Inst_FIFO_MEM
(
    .I_WR_CLK  ( I_WR_CLK               ) // input               I_WR_CLK
   ,.I_WR_EN   ( w_is_wr_enabled_wr_clk ) // input               I_WR_EN
   ,.I_WR_ADDR ( w_wr_addr_wr_clk       ) // input   [AW-1:0]    I_WR_ADDR
   ,.I_WR_DATA ( I_WR_DATA              ) // input   [DW-1:0]    I_WR_DATA
   ,.I_RD_ADDR ( w_rd_addr_rd_clk       ) // input   [AW-1:0]    I_RD_ADDR
   ,.O_RD_DATA ( O_RD_DATA              ) // output  [DW-1:0]    O_RD_DATA
);

FIFO_RD
#(
    .DW(DW)
   ,.AW(AW)
) Inst_FIFO_RD
(
     .I_RD_CLK   ( I_RD_CLK                 ) // input               I_RD_CLK
    ,.I_RD_RST_N ( I_RD_RST_N               ) // input               I_RD_RST_N
    ,.I_RD_EN    ( w_is_rd_enabled_rd_clk   ) // input               I_RD_EN
    ,.I_RD_WR_PTR( w_wr_ptr_rd_clk          ) // input  [AW  :0]     I_RD_WR_PTR     // Gray-coded wr pointer sync to rd clock
    ,.O_RD_ADDR  ( w_rd_addr_rd_clk         ) // output [AW-1:0]     O_RD_ADDR       // Binary wr memory address
    ,.O_RD_PTR   ( w_rd_ptr_rd_clk          ) // output [AW  :0]     O_RD_PTR        // Gray-coded rd pointer sync to rd clock
    ,.O_RD_EMPTY ( O_RD_EMPTY               ) // output              O_RD_EMPTY
);

SYNCHRONIZER
#(
    .DW(AW+1)        // Data Width
) Inst_SYNCHRONIZER_RD_PTR_TO_WR_PTR
(
     .I_CLK     ( I_WR_CLK          ) // input               I_CLK
    ,.I_RST_N   ( I_WR_RST_N        ) // input               I_RST_N
    ,.I_D       ( w_rd_ptr_rd_clk   ) // input   [DW-1:0]    I_D
    ,.O_Q       ( w_rd_ptr_wr_clk   ) // output  [DW-1:0]    O_Q
);

endmodule
