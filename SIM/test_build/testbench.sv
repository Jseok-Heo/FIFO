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
    logic [DW-1:0]  l_fifo_wr_queue[$];
    logic [DW-1:0]  l_fifo_rd_queue[$];

    int i;
    
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

//        repeat(100) begin
//            @(posedge r_wr_clk);
//            #1;
//            r_wr_data = $random();
//            r_wr_req = $random();
//            if(r_wr_req == 1 && !w_wr_full) l_fifo_wr_queue.push_front(r_wr_data);
//        end
        repeat(5) begin
            @(posedge r_wr_clk);
            #1;
            if(!w_wr_full) begin
                r_wr_req = 1;
                r_wr_data = $random();
                l_fifo_wr_queue.push_front(r_wr_data);
            end
            else begin
                r_wr_req = 0;
            end
        end

        @(posedge r_wr_clk);
        #1; r_wr_req = 0;
    end

    initial begin

        r_rd_clk    = 'h0;
        r_rd_rst_n  = 'h0;
        r_rd_req    = 'h0;

        #80; r_rd_rst_n = 1;

        repeat(5) begin
            @(posedge r_rd_clk);
            #1;
            if(!w_rd_empty) begin
                r_rd_req = 1;
                l_fifo_rd_queue.push_front(w_rd_data);
            end
            else begin
                r_rd_req = 0;
            end
        end

        @(posedge r_rd_clk);
        #1; r_rd_req = 0;
    end

    task compare;
        logic [DW-1:0] wr_data;
        logic [DW-1:0] rd_data;

        for(i=0; i<l_fifo_wr_queue.size(); i=i+1) begin
            wr_data = l_fifo_wr_queue.pop_back();
            rd_data = l_fifo_rd_queue.pop_back();
            $display("==============================");
            $display("wr_data = %0h", wr_data);
            $display("rd_data = %0h", rd_data);

            if(wr_data != rd_data) begin
                $display("*E, wr_data = %0x, rd_data = 0%x are different", wr_data, rd_data);
                $finish();
            end
            $display("==============================");
        end

        $display("Test Completed!");
    endtask: compare

    initial begin
        #10000; 
        compare();
        $finish();
    end

endmodule: testbench
