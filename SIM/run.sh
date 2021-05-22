#!/bin/bash -f

option=$1

xvlog -sv -f ${RTL_DIR}/vcode.f testbench.sv -L uvm -define NO_OF_TRANSACTIONS=2000
xelab testbench -relax -s top -timescale 1ns/1ps  -debug all
xsim top -testplusarg UVM_TESTNAME=test_basic  \
         -testplusarg UVM_VERBOSITY=UVM_LOW -runall \
         -wdb waves.wdb

if [[ ${option} == dump ]]; then
    xsim top -gui
fi
