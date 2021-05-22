module ASYNC_FIFO
#(
    parameter DW = 32
   ,parameter SYNC = 0
)
(
    input I_CLK
   ,input I_RST_N
   ,input [DW-1:0] I_DATA_WR_CLK
   ,input [DW-1:0] O_DATA_RD_CLK
   ,input          I_VALID_WR_CLK
   ,input          O_VALID_RD_CLK
);

    reg [AW-1:0] r_wr_ptr_binary;
    reg [AW-1:0] r_rd_ptr_binary;

    wire w_is_wr_enabled = I_WR_REQ && !O_WR_FULL;
    wire w_is_rd_enabled = I_RD_REQ && !O_RD_EMPTY;


endmodule
