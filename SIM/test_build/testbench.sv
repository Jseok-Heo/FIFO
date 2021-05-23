module testbench;

    localparam WR_CLK_PERIOD = 10;
    localparam RD_CLK_PERIOD = 15;
    localparam DW = 8;
    localparam AW = 4;
    
    reg             r_wr_clk    ;
    reg             r_wr_rst_n  ;
    reg [DW-1:0]    r_wr_data   ;
    reg             r_wr_req    ;
    wire            w_wr_full   ;
    reg             r_rd_clk    ;
    reg             r_rd_rst_n  ;
    reg             r_rd_req    ;
    wire [DW-1:0]   w_rd_data   ;
    wire            w_rd_empty  ;
    
    ASYNC_FIFO
    #(
        .DW(DW)
       ,.AW(AW)
    //   ,.SYNC(0)
    ) DUT
    (
        .I_WR_CLK   ( r_wr_clk   ) // input           I_WR_CLK
       ,.I_WR_RST_N ( r_wr_rst_n ) // input           I_WR_RST_N
       ,.I_WR_DATA  ( r_wr_data  ) // input  [DW-1:0] I_WR_DATA
       ,.I_WR_REQ   ( r_wr_req   ) // input           I_WR_REQ
       ,.O_WR_FULL  ( w_wr_full  ) // output          O_WR_FULL
       ,.I_RD_CLK   ( r_rd_clk   ) // input           I_RD_CLK
       ,.I_RD_RST_N ( r_rd_rst_n ) // input           I_RD_RST_N
       ,.I_RD_REQ   ( r_rd_req   ) // input           I_RD_REQ
       ,.O_RD_DATA  ( w_rd_data  ) // output [DW-1:0] O_RD_DATA
       ,.O_RD_EMPTY ( w_rd_empty ) // output          O_RD_EMPTY
    );
    
    initial begin
        forever #(WR_CLK_PERIOD/2) r_wr_clk = ~r_wr_clk;
    end
   
    initial begin
        forever #(RD_CLK_PERIOD/2) r_rd_clk = ~r_rd_clk;
    end

    initial begin
        r_wr_clk    = 'h0;
        r_wr_rst_n  = 'h0;
        r_wr_data   = 'h0;
        r_wr_req    = 'h0;

        #100; r_wr_rst_n = 1;

        repeat(100) begin
            @(posedge r_wr_clk);
            r_wr_data = $random();
            r_wr_req = $random();
        end
    end

    initial begin

        r_rd_clk    = 'h0;
        r_rd_rst_n  = 'h0;
        r_rd_req    = 'h0;

        #80; r_rd_rst_n = 1;

        repeat(100) begin
            @(posedge r_rd_clk);
            r_rd_req = $random();
        end
    end

    initial begin
        #10000; $finish();
    end

endmodule: testbench
