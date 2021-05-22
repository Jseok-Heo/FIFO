module FIFO_RD
#(
    parameter DW = 8
   ,parameter AW = 4
)
(
    input               I_RD_CLK
    input               I_RD_RST_N
    input               I_RD_EN
    input  [AW  :0]     I_RD_WR_PTR     // Gray-coded wr pointer sync to rd clock
    output [AW-1:0]     O_RD_ADDR       // Binary wr memory address
    output [AW  :0]     O_RD_PTR        // Gray-coded rd pointer sync to rd clock
    output              O_RD_EMPTY
);
    reg  [AW:0] r_rd_binary;    // rd ptr points to the word being read
    wire [AW:0] w_rd_binary_next;
    wire        w_rd_empty;

    always @(posedge I_RD_CLK, negedge I_RD_RST_N)
         if(!I_RD_RST_N)    r_rd_binary <= {AW+1{1'b0}};
         else               r_rd_binary <= w_rd_binary_next;

    assign O_RD_ADDR = r_rd_binary[AW-1:0];

    assign w_rd_binary_next = r_rd_binary + {AW{1'b0}, I_RD_EN};
    assign w_rd_gray_next   = (w_rd_binary_next>>1) ^ w_rd_binary_next;

    assign w_rd_empty = (w_rd_gray_next == I_RD_WR_PTR);

    always @(posedge I_RD_CLK, negedge I_RD_RST_N)
        if(!I_RD_RST_N) r_rd_empty <= 1'b0;
        else            r_rd_empty <= w_rd_empty;

    assign O_RD_EMPTY = r_rd_empty;

endmodule
