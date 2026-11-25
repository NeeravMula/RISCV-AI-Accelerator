`timescale 1ns/1ps

module pc_tb;

    reg clk;
    reg rst;
    reg stall;
    reg redirect;
    reg [31:0] pc_next;
    reg [31:0] redirect_addr;

    wire [31:0] pc_out;
    wire [31:0] pc_out_alt;

    integer tests_passed = 0;

    pc dut (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .redirect(redirect),
        .pc_next(pc_next),
        .redirect_addr(redirect_addr),
        .pc_out(pc_out)
    );

    pc #(
        .RESET_ADDR(32'h00001000)
    ) dut_alt (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .redirect(redirect),
        .pc_next(pc_next),
        .redirect_addr(redirect_addr),
        .pc_out(pc_out_alt)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check_pc(
        input reg reset_val,
        input reg stall_val,
        input reg redirect_val,
        input reg [31:0] next_addr,
        input reg [31:0] target_addr,
        input reg [31:0] expected
    );

        @(negedge clk);

        rst = reset_val;
        stall = stall_val;
        redirect = redirect_val;
        pc_next = next_addr;
        redirect_addr = target_addr;

        @(posedge clk);
        #1;

        if (pc_out !== expected)
            $fatal(1,
                "FAIL: rst=%b stall=%b redirect=%b next=%h target=%h expected=%h got=%h",
                rst, stall, redirect, pc_next,
                redirect_addr, expected, pc_out);

        tests_passed++;

    endtask

    initial begin

        rst = 1'b1;
        stall = 1'b0;
        redirect = 1'b0;
        pc_next = 32'd0;
        redirect_addr = 32'd0;

        if ($test$plusargs("WAVES")) begin
            $dumpfile("build/pc.vcd");
            $dumpvars(0, pc_tb);
        end

        check_pc(1, 0, 0, 32'h00000004,
                          32'h00000100, 32'h00000000);

        if (pc_out_alt !== 32'h00001000)
            $fatal(1, "FAIL: Configurable reset address");

        tests_passed++;

        $display("PASS: Initial reset and configurable reset address");

        for (int i = 1; i <= 10; i++) begin
            check_pc(0, 0, 0, 32'(i * 4),
                              32'd0, 32'(i * 4));
        end

        $display("PASS: Sequential advancement");

        check_pc(0, 1, 0, 32'h0000002C,
                          32'd0, 32'h00000028);

        $display("PASS: Single-cycle stall");

        repeat (5) begin
            check_pc(0, 1, 0, 32'h0000002C,
                              32'd0, 32'h00000028);
        end

        $display("PASS: Multiple-cycle stall");

        check_pc(0, 0, 0, 32'h0000002C,
                          32'd0, 32'h0000002C);

        $display("PASS: Stall release");

        check_pc(0, 0, 1, 32'h00000030,
                          32'h00000100, 32'h00000100);

        $display("PASS: Forward redirect");

        check_pc(0, 0, 1, 32'h00000104,
                          32'h00000020, 32'h00000020);

        $display("PASS: Backward redirect");

        check_pc(0, 1, 1, 32'h00000024,
                          32'h00000200, 32'h00000200);

        $display("PASS: Redirect overrides stall");

        check_pc(1, 1, 0, 32'h00000204,
                          32'd0, 32'h00000000);

        $display("PASS: Reset overrides stall");

        check_pc(1, 0, 1, 32'h00000004,
                          32'h00000300, 32'h00000000);

        $display("PASS: Reset overrides redirect");

        check_pc(1, 1, 1, 32'h00000004,
                          32'h00000400, 32'h00000000);

        $display("PASS: Reset overrides all controls");

        check_pc(0, 0, 0, 32'h00000080,
                          32'd0, 32'h00000080);

        check_pc(1, 0, 0, 32'h00000084,
                          32'd0, 32'h00000000);

        $display("PASS: Mid-execution reset");

        check_pc(0, 0, 0, 32'h00000100,
                          32'd0, 32'h00000100);

        @(negedge clk);

        pc_next = 32'h12345678;
        redirect_addr = 32'h87654320;
        redirect = 1'b1;

        #1;

        if (pc_out !== 32'h00000100)
            $fatal(1, "FAIL: PC changed without rising edge");

        rst = 1'b1;

        #1;

        if (pc_out !== 32'h00000100)
            $fatal(1, "FAIL: Reset is not synchronous");

        tests_passed += 2;

        @(posedge clk);
        #1;

        if (pc_out !== 32'h00000000)
            $fatal(1, "FAIL: Synchronous reset");

        tests_passed++;

        $display("PASS: Clock-edge behavior and synchronous reset");

        check_pc(0, 0, 0, 32'hFFFFFFFC,
                          32'd0, 32'hFFFFFFFC);

        check_pc(0, 0, 0, 32'h00000000,
                          32'd0, 32'h00000000);

        check_pc(0, 0, 1, 32'd0,
                          32'hFFFFFFFF, 32'hFFFFFFFF);

        $display("PASS: Full-width address handling");

        check_pc(0, 0, 0, 32'h12345678,
                          32'd0, 32'h12345678);

        $display("PASS: Arbitrary next address");

        check_pc(0, 0, 0, 32'h00000003,
                          32'd0, 32'h00000003);

        check_pc(0, 0, 1, 32'd0,
                          32'h00000007, 32'h00000007);

        $display("PASS: No internal address masking");

        $display("ALL %0d CHECKS PASSED", tests_passed);

        $finish;

    end

    initial begin
        #10000;
        $fatal(1, "Simulation timeout");
    end

endmodule
