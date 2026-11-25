`timescale 1ns/1ps

module imm_gen_tb;

    reg [31:0] instr;
    reg [2:0] imm_sel;
    wire [31:0] imm;

    localparam [2:0] IMM_I = 3'd0;
    localparam [2:0] IMM_S = 3'd1;
    localparam [2:0] IMM_B = 3'd2;
    localparam [2:0] IMM_U = 3'd3;
    localparam [2:0] IMM_J = 3'd4;

    integer tests_passed = 0;

    imm_gen dut (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    task automatic check_imm(
        input reg [31:0] instruction,
        input reg [2:0] selection,
        input reg [31:0] expected
    );
        instr = instruction;
        imm_sel = selection;

        #1;

        if (imm !== expected)
            $fatal(1,
                "FAIL: instr=%h imm_sel=%d expected=%h got=%h",
                instruction, selection, expected, imm);

        tests_passed++;
    endtask

    initial begin
        instr = 32'd0;
        imm_sel = 3'd0;

        $dumpfile("build/imm_gen.vcd");
        $dumpvars(0, imm_gen_tb);

        check_imm(32'h00A18293, IMM_I, 32'h0000000A);
        check_imm(32'hFF618293, IMM_I, 32'hFFFFFFF6);
        check_imm(32'h7FF18293, IMM_I, 32'h000007FF);
        check_imm(32'h80018293, IMM_I, 32'hFFFFF800);
        check_imm(32'h00018293, IMM_I, 32'h00000000);
        check_imm(32'hFFF18293, IMM_I, 32'hFFFFFFFF);

        $display("PASS: I-type");

        check_imm(32'h00512423, IMM_S, 32'h00000008);
        check_imm(32'hFE512C23, IMM_S, 32'hFFFFFFF8);
        check_imm(32'h7E512FA3, IMM_S, 32'h000007FF);
        check_imm(32'h80512023, IMM_S, 32'hFFFFF800);
        check_imm(32'h00512023, IMM_S, 32'h00000000);
        check_imm(32'hFE512FA3, IMM_S, 32'hFFFFFFFF);

        $display("PASS: S-type");

        check_imm(32'h00208863, IMM_B, 32'h00000010);
        check_imm(32'hFE2088E3, IMM_B, 32'hFFFFFFF0);
        check_imm(32'h7E208FE3, IMM_B, 32'h00000FFE);
        check_imm(32'h80208063, IMM_B, 32'hFFFFF000);
        check_imm(32'h00208063, IMM_B, 32'h00000000);
        check_imm(32'hFE208FE3, IMM_B, 32'hFFFFFFFE);
        check_imm(32'h00208163, IMM_B, 32'h00000002);
        check_imm(32'h002080E3, IMM_B, 32'h00000800);

        $display("PASS: B-type");

        check_imm(32'h123452B7, IMM_U, 32'h12345000);
        check_imm(32'hFFFFF2B7, IMM_U, 32'hFFFFF000);
        check_imm(32'h000002B7, IMM_U, 32'h00000000);
        check_imm(32'h800002B7, IMM_U, 32'h80000000);
        check_imm(32'h7FFFF2B7, IMM_U, 32'h7FFFF000);

        $display("PASS: U-type");

        check_imm(32'h100000EF, IMM_J, 32'h00000100);
        check_imm(32'hF01FF0EF, IMM_J, 32'hFFFFFF00);
        check_imm(32'h7FFFF0EF, IMM_J, 32'h000FFFFE);
        check_imm(32'h800000EF, IMM_J, 32'hFFF00000);
        check_imm(32'h000000EF, IMM_J, 32'h00000000);
        check_imm(32'hFFFFF0EF, IMM_J, 32'hFFFFFFFE);
        check_imm(32'h002000EF, IMM_J, 32'h00000002);
        check_imm(32'h001000EF, IMM_J, 32'h00000800);

        $display("PASS: J-type");

        check_imm(32'hFFFFFFFF, 3'd5, 32'h00000000);
        check_imm(32'hFFFFFFFF, 3'd6, 32'h00000000);
        check_imm(32'hFFFFFFFF, 3'd7, 32'h00000000);

        $display("PASS: Unsupported selections");

        check_imm(32'hABCDEF12, IMM_I, 32'hFFFFFABC);
        check_imm(32'hABCDEF12, IMM_S, 32'hFFFFFABE);
        check_imm(32'hABCDEF12, IMM_B, 32'hFFFFF2BE);
        check_imm(32'hABCDEF12, IMM_U, 32'hABCDE000);
        check_imm(32'hABCDEF12, IMM_J, 32'hFFFDE2BC);

        $display("PASS: Selection switching");

        check_imm(32'hABC00000, IMM_I, 32'hFFFFFABC);
        check_imm(32'hABCFFFFF, IMM_I, 32'hFFFFFABC);

        check_imm(32'hFE000F80, IMM_S, 32'hFFFFFFFF);
        check_imm(32'hFFFFFFFF, IMM_S, 32'hFFFFFFFF);

        check_imm(32'hFE000F80, IMM_B, 32'hFFFFFFFE);
        check_imm(32'hFFFFFFFF, IMM_B, 32'hFFFFFFFE);

        check_imm(32'h12345000, IMM_U, 32'h12345000);
        check_imm(32'h12345FFF, IMM_U, 32'h12345000);

        check_imm(32'hFFFFF000, IMM_J, 32'hFFFFFFFE);
        check_imm(32'hFFFFFFFF, IMM_J, 32'hFFFFFFFE);

        $display("PASS: Unrelated instruction bits");

        $display("ALL %0d TESTS PASSED", tests_passed);

        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "Simulation timeout");
    end

endmodule
