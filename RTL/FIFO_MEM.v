module FIFO_MEM
#(
    parameter DW = 32   // Data Width
   ,parameter AW = 4    // Address Width
)
(
    input               I_WR_CLK
   ,input               I_WR_EN
   ,input   [AW-1:0]    I_WR_ADDR
   ,input   [DW-1:0]    I_WR_DATA

   ,input   [AW-1:0]    I_RD_ADDR
   ,output  [DW-1:0]    O_RD_DATA
);

    `ifdef VENDOR_RAM
    // instantiate a vendor's dual-port RAM
//        vendor_ram Inst_ram 
//        (
//            .dout   (O_RD_DATA)
//           ,.din    (I_WR_DATA)
//           ,.waddr  (I_WR_ADDR)
//           ,.raddr  (I_RD_ADDR)
//           ,.wclken (I_WR_EN)
//           ,.clk    (I_WR_CLK)
        );
    `else
    // RTL Verilog memory model
    localparam DEPTH = 1<<AW
    reg [DW-1:0] mem [0:DEPTH-1];

    assign O_RD_DATA = mem[I_RD_ADDR];

    always @(posedge I_WR_CLK)
        if(I_WR_EN) mem[I_WR_ADDR] <= I_WR_DATA;

    `endif

endmodule
