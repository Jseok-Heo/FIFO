module FIFO_WR
#(
    parameter DW = 8
   ,parameter AW = 4
)
(
    input               I_WR_CLK
    input               I_WR_RST_N
    input               I_WR_EN
    input  [AW  :0]     I_WR_RD_PTR     // Gray-coded rd pointer sync to wr clock
    output [AW-1:0]     O_WR_ADDR       // Binary wr memory address
    output [AW  :0]     O_WR_PTR        // Gray-coded wr pointer sync to wr clock
    output              O_WR_FULL
);
    reg  [AW:0] r_wr_binary;    // wr ptr points to the word to be written
    wire [AW:0] w_wr_binary_next;
    wire        w_wr_full;

    always @(posedge I_WR_CLK, negedge I_WR_RST_N)
         if(!I_WR_RST_N)    r_wr_binary <= {AW+1{1'b0}};
         else               r_wr_binary <= w_wr_binary_next;

    assign O_WR_ADDR = r_wr_binary[AW-1:0];

    assign w_wr_binary_next = r_wr_binary + {AW{1'b0}, I_WR_EN};
    assign w_wr_gray_next   = (r_wr_gray >>1) ^ w_wr_binary_next;

    assign w_wr_full = (w_wr_gray_next == {~I_WR_RD_PTR[AW:AW-1],I_WR_RD_PTR[AW-2:0]});

    always @(posedge I_WR_CLK, negedge I_WR_RST_N)
        if(!I_WR_RST_N) r_wr_full <= 1'b0;
        else            r_wr_full <= w_wr_full;

    assign O_WR_FULL = r_wr_full;

endmodule
