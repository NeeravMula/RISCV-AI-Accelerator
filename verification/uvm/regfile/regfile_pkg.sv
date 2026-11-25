package regfile_pkg;

    timeunit 1ns;
    timeprecision 1ps;

    import uvm_pkg::*;

    `include "uvm_macros.svh"

    `include "regfile_item.sv"
    `include "regfile_sequencer.sv"
    `include "regfile_sequence.sv"
    `include "regfile_driver.sv"
    `include "regfile_monitor.sv"
    `include "regfile_scoreboard.sv"
    `include "regfile_agent.sv"
    `include "regfile_env.sv"
    `include "regfile_test.sv"

endpackage
