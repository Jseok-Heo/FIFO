import uvm_pkg::*; `include "uvm_macros.svh" 
module asyncq; 
	bit rempty, wfull;
	bit rclk, wclk, renb, wenb; 
	int fifoQ [$]; // queue,
	int wdata, rdata;
	int qsize; 
	initial forever #10 wclk=!wclk;  
	initial forever #13 rclk=!rclk;
	// 1. fifo empty output signal is generated when queue size becomes 0.
    // 2. fifo full output signal is generated when queue size becomes 32.
 
	ap_mt:   assert property(@(posedge rclk) fifoQ.size==0 |-> rempty); 
	ap_full: assert property(@(posedge wclk) fifoQ.size==32 |-> wfull); 
	assign qsize =fifoQ.size; 
	always @ (posedge wclk)  
		if(wenb) fifoQ.push_back(wdata); 
 
    always @ (posedge rclk)  
    	if(renb) rdata<= fifoQ.pop_front(); 
 
	initial begin 
     repeat(200) begin 
       @(posedge wclk);   
       if (!randomize(wenb, wdata)  with 
           { wenb dist {1'b1:=1, 1'b0:=3};})
       	          `uvm_error("MYERR", "This is a randomize error")
       end 
    end 
 
     initial begin 
     repeat(200) begin 
       @(posedge rclk);   
       if (!randomize(renb)  with 
           { renb dist {1'b1:=1, 1'b0:=5};})
       	          `uvm_error("MYERR", "This is a randomize error")
       end 
       $finish; 
    end 
endmodule 
