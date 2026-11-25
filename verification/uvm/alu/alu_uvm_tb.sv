`timescale 1ns/1ps

module alu_uvm_tb;

    import uvm_pkg::*;
    import alu_pkg::*;

    logic sample_clk = 1'b0;

    always #5 sample_clk = ~sample_clk;

    alu_if vif(sample_clk);

    alu dut (
        .a(vif.a),
        .b(vif.b),
        .alu_op(vif.alu_op),
        .result(vif.result),
        .zero(vif.zero)
    );

    initial begin
        vif.a = 32'd0;
        vif.b = 32'd0;
        vif.alu_op = 4'd0;
        vif.valid = 1'b0;

        uvm_config_db#(virtual alu_if)::set(
            null, "uvm_test_top.env.agent.driver", "vif", vif
        );

        uvm_config_db#(virtual alu_if)::set(
            null, "uvm_test_top.env.agent.monitor", "vif", vif
        );

        $dumpfile("build/alu_uvm.vcd");
        $dumpvars(0, alu_uvm_tb);

        run_test("alu_test");
    end

    initial begin
        #10000;
        $fatal(1, "ALU UVM simulation timeout");
    end

endmodule
