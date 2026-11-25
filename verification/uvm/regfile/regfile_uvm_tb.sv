`timescale 1ns/1ps

module regfile_uvm_tb;

    import uvm_pkg::*;
    import regfile_pkg::*;

    logic clk = 1'b0;

    always #5 clk = ~clk;

    regfile_if vif(clk);

    regfile dut (
        .clk(clk),
        .rst(vif.rst),
        .r1_addr(vif.r1_addr),
        .r1_data(vif.r1_data),
        .r2_addr(vif.r2_addr),
        .r2_data(vif.r2_data),
        .rd_addr(vif.rd_addr),
        .rd_data(vif.rd_data),
        .rd_we(vif.rd_we)
    );

    initial begin

        vif.rst = 1'b1;
        vif.r1_addr = 5'd0;
        vif.r2_addr = 5'd0;
        vif.rd_addr = 5'd0;
        vif.rd_data = 32'd0;
        vif.rd_we = 1'b0;

        $dumpfile("build/regfile_uvm.vcd");
        $dumpvars(0, regfile_uvm_tb);

        uvm_config_db#(virtual regfile_if)::set(
            null, "*", "vif", vif
        );

        run_test("regfile_test");

    end

    initial begin
        repeat (2) @(negedge clk);
        vif.rst = 1'b0;
    end

    initial begin
        #100000ns;
        $fatal(1, "Simulation timeout");
    end

endmodule
