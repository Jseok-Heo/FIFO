`include "uvm_macros.svh"
import uvm_pkg::*;

class bus_seq_item extends uvm_sequence_item;

  rand bit[7:0] wdata;
  rand bit winc,rinc;
  rand int delay;
  bit wfull,rempty; 
  bit[7:0] rdata;

`uvm_object_utils(bus_seq_item)

function new(string name = "bus_seq_item");
  super.new(name);
endfunction

constraint at_least_1 { delay inside {[1:20]};}



function string convert2string();
  return $sformatf("%b\n winc: \t%0h\n data_in:\t%0b\n rd_inc:\t%0b\n rdata:\t%0h",
                   super.convert2string(),  winc, wdata, rinc, rdata);
endfunction: convert2string

endclass: bus_seq_item

class bus_agent_config extends uvm_object;

`uvm_object_utils(bus_agent_config)

virtual bus_if BUS;

function new(string name = "bus_agent_config");
  super.new(name);
endfunction

//
// Task: wait_for_clock
//
// This method waits for n clock cycles. This technique can be used for clocks,
// resets and any other signals.
//
task wait_for_wclock( int n = 1 );
  repeat( n ) begin
    @( posedge BUS.wclk );
  end
endtask
  
  task wait_for_rclock( int n = 1 );
  repeat( n ) begin
    @( posedge BUS.rclk );
  end
endtask

endclass: bus_agent_config  

class bus_driver extends uvm_driver #(bus_seq_item);

`uvm_component_utils(bus_driver)

bus_seq_item req;
int i;
bit localwrinc;
virtual bus_if BUS;

function new(string name = "bus_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);

  // Default conditions:
  BUS.wdata <= 0;
//  BUS.wr_cs <= 0;
  BUS.winc <= 0;
 // BUS.rd_cs <= 0;
//  BUS.rd_en<= 0;
  // Wait for reset to end
  @(posedge BUS.wrst_n);
  forever
    begin
      for (int i=0; i<15;i++) begin
      seq_item_port.get_next_item(req);
   //   repeat(req.delay) begin
     // repeat (2) @(posedge BUS.wclk) begin
      @ (posedge BUS.wclk) ;
    //  @ (posedge BUS.wclk);
  //   BUS.winc <= req.winc; 
   //   end
      
      
      //if (localwrinc) begin
   //   BUS.wdata <= req.wdata;
    
        
      //end
      
      
   //   BUS.rinc <= req.rinc;
        
        if (!BUS.wfull) begin
        BUS.winc = (i%2 == 0)? 1'b1 : 1'b0;
        if (BUS.winc) begin
          BUS.wdata <=req.wdata;
          BUS.winc <= BUS.winc;
        end
        end
      seq_item_port.item_done();
   // end
    end
    end
endtask: run_phase

endclass: bus_driver

class read_driver extends uvm_driver #(bus_seq_item);

  `uvm_component_utils(read_driver)

bus_seq_item req;
int i;
bit localwrinc;
virtual bus_if BUS;

  function new(string name = "read_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);

  // Default conditions:
  BUS.rdata <= 0;
//  BUS.wr_cs <= 0;
  BUS.rinc <= 0;
 // BUS.rd_cs <= 0;
//  BUS.rd_en<= 0;
  // Wait for reset to end
  @(posedge BUS.rrst_n);
  forever
    begin
      for (int i=0; i<31; i++) begin
      seq_item_port.get_next_item(req);
    //  repeat(req.delay) begin
        @(posedge BUS.rclk);
     // end
      if (!BUS.rempty) begin
        BUS.rinc = (i%2 ==0) ? 1'b1 : 1'b0; 
        if (BUS.rinc) begin
        req.rdata <= BUS.rdata;
      end
      end
  
      seq_item_port.item_done();
   // end
        end
    end
endtask: run_phase

endclass: read_driver

class bus_sequencer extends uvm_sequencer #(bus_seq_item);

`uvm_component_utils(bus_sequencer)

function new(string name = "bus_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

endclass: bus_sequencer

class read_sequencer extends uvm_sequencer #(bus_seq_item);

  `uvm_component_utils(read_sequencer)

  function new(string name = "read_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

endclass: read_sequencer

class bus_agent extends uvm_component;

`uvm_component_utils(bus_agent)

bus_agent_config m_cfg;
bus_driver m_driver;
bus_sequencer m_sequencer;
 // wr_seq seq;

function new(string name = "bus_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  if(!uvm_config_db #(bus_agent_config)::get(this, "", "config", m_cfg)) begin
    `uvm_error("build_phase", "Unable to find configuration object")
  end
  // No options here always active ...
  m_driver = bus_driver::type_id::create("m_driver", this);
//   seq = wr_seq::type_id::create("seq");
  m_sequencer = bus_sequencer::type_id::create("m_sequencer", this);
  
endfunction: build_phase

function void connect_phase(uvm_phase phase);
  m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  m_driver.BUS = m_cfg.BUS;
 // seq.BUS = m_cfg.BUS;
endfunction: connect_phase

endclass: bus_agent

class read_agent extends uvm_component;

  `uvm_component_utils(read_agent)

bus_agent_config m_cfg;
read_driver m_driver;
read_sequencer m_sequencer;

  function new(string name = "read_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  if(!uvm_config_db #(bus_agent_config)::get(this, "", "config", m_cfg)) begin
    `uvm_error("build_phase", "Unable to find configuration object")
  end
  // No options here always active ...
  m_driver = read_driver::type_id::create("m_driver", this);
  m_sequencer = read_sequencer::type_id::create("m_sequencer", this);
endfunction: build_phase

function void connect_phase(uvm_phase phase);
  m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  m_driver.BUS = m_cfg.BUS;
endfunction: connect_phase

endclass: read_agent



class wr_seq extends uvm_sequence #(bus_seq_item);

  `uvm_object_utils(wr_seq)

bus_seq_item req;
bus_agent_config m_cfg;
  bit writeinc;
  
 // virtual bus_if BUS;

rand int limit = 40; // Controls the number of iterations

  function new(string name = "wr_seq");
  super.new(name);
endfunction

task body;
  int i = 5;
  req = bus_seq_item::type_id::create("req");
 // if(!uvm_config_db #(bus_agent_config)::get(this, "*", "config", m_cfg)) begin
//    `uvm_error("body", "unable to access agent configuration object")
//  end
  
  repeat (limit)
    begin
    
      start_item(req);
      // The address is constrained to be within the address of the GPIO function
      // within the DUT, The result will be a request item for a read or a write
      assert(req.randomize with {winc ==1;rinc==0;})
      finish_item(req);
   //   m_cfg.wait_for_wclock(i);
      i++;
      // The req handle points to the object that the driver has updated with response data
      `uvm_info("seq_body", req.convert2string(), UVM_LOW);
    end
endtask: body

endclass: wr_seq



class read_seq extends uvm_sequence #(bus_seq_item);

  `uvm_object_utils(read_seq)

bus_seq_item req;
bus_agent_config m_cfg;
//  bit writeinc;
  
  

rand int limit = 40; // Controls the number of iterations

  function new(string name = "read_seq");
  super.new(name);
endfunction

task body;
  int i = 5;
  req = bus_seq_item::type_id::create("req");
  if(!uvm_config_db #(bus_agent_config)::get(null, get_full_name(), "config", m_cfg)) begin
    `uvm_error("body", "unable to access agent configuration object")
  end

  repeat(limit)
    begin
      start_item(req);
      // The address is constrained to be within the address of the GPIO function
      // within the DUT, The result will be a request item for a read or a write
      assert(req.randomize with {rinc==1;winc==0;})
      finish_item(req);
    //  m_cfg.wait_for_rclock(i);
      i++;
     // The req handle points to the object that the driver has updated with response data
      `uvm_info("seq_body", req.convert2string(), UVM_LOW);
    end
endtask: body

endclass: read_seq

//typedef class read_sequencer;


class virtual_sequence extends uvm_sequence#(uvm_sequence_item);
  `uvm_object_utils(virtual_sequence)
  
   read_sequencer rd_sqr;
   bus_sequencer  bs_sqr;
   
  
  
   function new( string name = "" );
    super.new( name );
  endfunction
  
  task body();
    `uvm_info("seq_body", $sformatf("I am in virtual sequence"), UVM_LOW);
    
  endtask
  
endclass

class chained_seq extends virtual_sequence;
  `uvm_object_utils(chained_seq)
  
  
   read_sequencer rd_sqr;
   bus_sequencer  bs_sqr;
  
  function new( string name = "" );
    super.new( name );
  endfunction
  
  task body();
    wr_seq seq;
    read_seq rd_seq;
    super.body();
  
    fork 
    seq = wr_seq::type_id::create("seq");
    seq.start( bs_sqr , this );
    
    rd_seq = read_seq::type_id::create("rd_seq");
    rd_seq.start( rd_sqr , this );
    join
  endtask
endclass

interface bus_if;

logic wclk;
logic wrst_n;
logic winc;
logic rclk;
logic rinc;
logic rrst_n;
  logic[7:0] wdata;
  logic[7:0] rdata;
//logic wr_cs;
//logic wr_en;
//logic rd_cs;
//logic rd_en;
logic rempty;
logic wfull;

endinterface: bus_if


class bus_test_base extends uvm_test;

`uvm_component_utils(bus_test_base)

bus_agent m_agent;
read_agent m_agent2;
//bus_agent m_agent2;
bus_agent_config m_cfg;
chained_seq ch_seq;
function new(string name = "bus_test_base", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_cfg = bus_agent_config::type_id::create("m_cfg");
  if(!uvm_config_db #(virtual bus_if)::get(this, "", "BUS_vif", m_cfg.BUS)) begin
    `uvm_error("Build_phase", "Unable to find BUS_vif")
  end
  uvm_config_db #(bus_agent_config)::set(this, "*", "config", m_cfg);
  m_agent = bus_agent::type_id::create("m_agent", this);
  m_agent2 = read_agent::type_id::create("m_agent2", this);
  ch_seq = chained_seq::type_id::create("ch_seq");
endfunction: build_phase
  
  
  function void connect_phase (uvm_phase phase);
    ch_seq.bs_sqr = m_agent.m_sequencer;
    ch_seq.rd_sqr = m_agent2.m_sequencer;
  endfunction:connect_phase
  
  task run_phase (uvm_phase phase);
    
    
  // rr wr_seq seq = wr_seq::type_id::create("seq");
  // rr  read_seq seq1 = read_seq::type_id::create("seq1");
  // bus_seq_read seq1 = bus_seq_read::type_id::create("seq1");
  phase.raise_objection(this, "Starting test");
  // Using randomization and constraints to set the initial values
  //
  // This could also be done directly
  //
    ch_seq.start(null);
 // rr seq.start(m_agent.m_sequencer);
 // rr seq1.start(m_agent2.m_sequencer);
        
  phase.drop_objection(this, "Finishing test");
endtask: run_phase

//endclass: seq_rand_test 

//endclass: seq_rand_test
  
endclass: bus_test_base

module testbench;

import uvm_pkg::*;
//import bus_agent_pkg::*;
//import bus_seq_lib_pkg::*;
//import test_lib_pkg::*;
//logic clk;
//logic rst;


bus_if BUS();
//async_fifo1 DUT(.bus(BUS));
ASYNC_FIFO
#( .DW(8), .AW(4) )
DUT
(
     .I_WR_CLK       ( BUS.wclk     )
    ,.I_WR_RST_N     ( BUS.wrst_n   )
    ,.I_WR_DATA      ( BUS.wdata    )
    ,.I_WR_REQ       ( BUS.winc     )
    ,.O_WR_FULL      ( BUS.wfull    )
    ,.I_RD_CLK       ( BUS.rclk     )
    ,.I_RD_RST_N     ( BUS.rrst_n   )
    ,.I_RD_REQ       ( BUS.rinc     )
    ,.O_RD_DATA      ( BUS.rdata    )
    ,.O_RD_EMPTY     ( BUS.rempty   )
);

// Free running clock
initial
  begin
    BUS.wclk = 0;
    BUS.rclk =0;
//    BUS.wfull =0;
    forever begin
      #10 BUS.wclk = ~BUS.wclk;
      #35 BUS.rclk = ~BUS.rclk;
    end
  end

// Reset
initial
  begin
    BUS.wrst_n = 0;
    BUS.rrst_n =0;
    repeat(4) begin
      @(posedge BUS.wclk);
    end
    BUS.wrst_n = 1;
    repeat (8) begin
      @ (posedge BUS.rclk);
    end
  BUS.rrst_n =1;
  end
  
 

// UVM start up:
initial
  begin
    uvm_config_db #(virtual bus_if)::set(null, "uvm_test_top", "BUS_vif" , BUS);
    run_test("bus_test_base");
  end

  initial begin
      $dumpfile ("dump.vcd");
    $dumpvars (0,testbench);
    end
  
endmodule: testbench


