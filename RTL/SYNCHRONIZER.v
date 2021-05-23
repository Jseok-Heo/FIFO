// Must be careful for Multi-bit synchronization
// Asynchronous REQ-ACK method is preferred

module SYNCHRONIZER
#(
    parameter DW = 1        // Data Width
)
(
     input               I_CLK
    ,input               I_RST_N
    ,input   [DW-1:0]    I_D
    ,output  [DW-1:0]    O_Q

);
    reg [DW-1:0] r_sync_ff[0:1];

    always @(posedge I_CLK, negedge I_RST_N)
        if(!I_RST_N)    {r_sync_ff[1], r_sync_ff[0]} <= {{DW{1'b0}},{DW{1'b0}}};
        else            {r_sync_ff[1], r_sync_ff[0]} <= {r_sync_ff[0], I_D};

    assign O_Q = r_sync_ff[1];

endmodule
