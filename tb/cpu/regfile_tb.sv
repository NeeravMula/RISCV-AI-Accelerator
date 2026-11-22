
`timescale 1ns/1ps

module regfile_tb;

    reg clk;
    reg rst;

    reg [4:0] r1_addr;
    wire [31:0] r1_data;
    reg [4:0] r2_addr;
    wire [31:0] r2_data;

    reg [4:0] rd_addr;
    reg [31:0] rd_data;
    reg rd_we;

    integer tests_passed = 0;

    regfile dut (
        .clk(clk),
        .rst(rst),
        .r1_addr(r1_addr),
        .r1_data(r1_data),
        .r2_addr(r2_addr),
        .r2_data(r2_data),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rd_we(rd_we)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic write_register(
        input reg [4:0] addr,
        input reg [31:0] data
    );
        @(negedge clk);
        rd_addr = addr;
        rd_data = data;
        rd_we = 1'b1;

        @(posedge clk);
        #1;

        @(negedge clk);
        rd_we = 1'b0;
    endtask

    task automatic check_register(
        input reg [4:0] addr,
        input reg [31:0] expected
    );
        r1_addr = addr;
        #1;

        if (r1_data !== expected)
            $fatal(1, "FAIL: x%0d expected %h, got %h",
                   addr, expected, r1_data);
    endtask

    task automatic check_dual_read(
        input reg [4:0] addr1,
        input reg [31:0] expected1,
        input reg [4:0] addr2,
        input reg [31:0] expected2
    );
        r1_addr = addr1;
        r2_addr = addr2;
        #1;

        if (r1_data !== expected1)
            $fatal(1, "FAIL: Read port 1 mismatch");

        if (r2_data !== expected2)
            $fatal(1, "FAIL: Read port 2 mismatch");
    endtask

    task automatic reset_registers;
        @(negedge clk);
        rst = 1'b1;
        rd_we = 1'b0;

        @(posedge clk);
        #1;

        @(negedge clk);
        rst = 1'b0;
    endtask

    initial begin
        rst = 1'b0;
        rd_we = 1'b0;
        r1_addr = 5'd0;
        r2_addr = 5'd0;
        rd_addr = 5'd0;
        rd_data = 32'd0;

        $dumpfile("build/regfile.vcd");
        $dumpvars(0, regfile_tb);

        reset_registers();

        for (int i = 0; i < 32; i++)
            check_register(i, 32'd0);

        tests_passed++;
        $display("PASS: Reset");

        write_register(5'd5, 32'd42);
        check_register(5'd5, 32'd42);

        tests_passed++;
        $display("PASS: Basic write/read");

        write_register(5'd0, 32'd100);
        check_register(5'd0, 32'd0);
        check_dual_read(5'd0, 32'd0, 5'd5, 32'd42);

        tests_passed++;
        $display("PASS: x0 protection");

        write_register(5'd3, 32'd123);
        write_register(5'd7, 32'd456);

        check_register(5'd3, 32'd123);
        check_register(5'd7, 32'd456);
        check_register(5'd5, 32'd42);

        tests_passed++;
        $display("PASS: Multiple registers");

        check_dual_read(5'd3, 32'd123, 5'd7, 32'd456);
        check_dual_read(5'd5, 32'd42, 5'd5, 32'd42);

        tests_passed++;
        $display("PASS: Dual read ports");

        @(negedge clk);
        rd_addr = 5'd5;
        rd_data = 32'd999;
        rd_we = 1'b0;

        @(posedge clk);
        #1;
        check_register(5'd5, 32'd42);

        tests_passed++;
        $display("PASS: Write enable");

        @(negedge clk);
        rd_addr = 5'd5;
        rd_data = 32'd777;
        rd_we = 1'b1;

        #1;
        check_register(5'd5, 32'd42);

        @(posedge clk);
        #1;
        check_register(5'd5, 32'd777);

        @(negedge clk);
        rd_we = 1'b0;

        tests_passed++;
        $display("PASS: Clock edge behavior");

        write_register(5'd5, 32'd555);
        check_register(5'd5, 32'd555);

        tests_passed++;
        $display("PASS: Overwrite register");

        reset_registers();

        for (int i = 0; i < 32; i++)
            check_register(i, 32'd0);

        tests_passed++;
        $display("PASS: Reset after writes");

        $display("ALL %0d TESTS PASSED", tests_passed);
        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "FAIL: Simulation timeout");
    end

endmodule
