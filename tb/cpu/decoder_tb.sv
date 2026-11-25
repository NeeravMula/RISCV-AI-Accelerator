`timescale 1ns/1ps

module decoder_tb;

    logic [31:0] instr;

    typedef struct packed {
        logic [3:0] alu_op;
        logic [2:0] imm_sel;
        logic [1:0] alu_src_a;
        logic alu_src_b;
        logic reg_write;
        logic [1:0] wb_sel;
        logic mem_read;
        logic mem_write;
        logic [1:0] mem_size;
        logic mem_unsigned;
        logic branch;
        logic [2:0] branch_type;
        logic jump;
        logic jalr;
        logic uses_rs1;
        logic uses_rs2;
        logic illegal_instr;
    } control_t;

    control_t actual;

    int tests_passed = 0;
    int legal_count = 0;
    int illegal_count = 0;

    decoder dut (
        .instr(instr),
        .alu_op(actual.alu_op),
        .imm_sel(actual.imm_sel),
        .alu_src_a(actual.alu_src_a),
        .alu_src_b(actual.alu_src_b),
        .reg_write(actual.reg_write),
        .wb_sel(actual.wb_sel),
        .mem_read(actual.mem_read),
        .mem_write(actual.mem_write),
        .mem_size(actual.mem_size),
        .mem_unsigned(actual.mem_unsigned),
        .branch(actual.branch),
        .branch_type(actual.branch_type),
        .jump(actual.jump),
        .jalr(actual.jalr),
        .uses_rs1(actual.uses_rs1),
        .uses_rs2(actual.uses_rs2),
        .illegal_instr(actual.illegal_instr)
    );
    
    function automatic control_t reference_model(
        input logic [31:0] instruction
    );

        control_t c;
        logic [6:0] op;
        logic [2:0] f3;
        logic [6:0] f7;
        logic [14:0] unused_instr;
        unused_instr = {instruction[24:15], instruction[11:7]};
        op = instruction[6:0];
        f3 = instruction[14:12];
        f7 = instruction[31:25];

        c = '0;
        c.imm_sel = 3'd5;
        c.illegal_instr = 1'b1;

        case (op)

            7'h33: begin
                if (f7 == 7'h00) begin
                    case (f3)
                        3'd0: c.alu_op = 4'd0;
                        3'd1: c.alu_op = 4'd5;
                        3'd2: c.alu_op = 4'd8;
                        3'd3: c.alu_op = 4'd9;
                        3'd4: c.alu_op = 4'd4;
                        3'd5: c.alu_op = 4'd6;
                        3'd6: c.alu_op = 4'd3;
                        3'd7: c.alu_op = 4'd2;
                    endcase
                    c.illegal_instr = 1'b0;
                end
                else if (f7 == 7'h20) begin
                    if (f3 == 3'd0) begin
                        c.alu_op = 4'd1;
                        c.illegal_instr = 1'b0;
                    end
                    else if (f3 == 3'd5) begin
                        c.alu_op = 4'd7;
                        c.illegal_instr = 1'b0;
                    end
                end

                if (!c.illegal_instr) begin
                    c.reg_write = 1'b1;
                    c.uses_rs1 = 1'b1;
                    c.uses_rs2 = 1'b1;
                end
            end

            7'h13: begin
                case (f3)
                    3'd0: c.alu_op = 4'd0;
                    3'd1: c.alu_op = 4'd5;
                    3'd2: c.alu_op = 4'd8;
                    3'd3: c.alu_op = 4'd9;
                    3'd4: c.alu_op = 4'd4;
                    3'd5: c.alu_op =
                        (f7 == 7'h20) ? 4'd7 : 4'd6;
                    3'd6: c.alu_op = 4'd3;
                    3'd7: c.alu_op = 4'd2;
                endcase

                if ((f3 == 3'd1 && f7 != 7'h00) ||
                    (f3 == 3'd5 && f7 != 7'h00 &&
                                     f7 != 7'h20)) begin
                    c.alu_op = 4'd0;
                end
                else begin
                    c.illegal_instr = 1'b0;
                    c.imm_sel = 3'd0;
                    c.alu_src_b = 1'b1;
                    c.reg_write = 1'b1;
                    c.uses_rs1 = 1'b1;
                end
            end

            7'h03: begin
                if (f3 == 3'd0 || f3 == 3'd1 ||
                    f3 == 3'd2 || f3 == 3'd4 ||
                    f3 == 3'd5) begin

                    c.illegal_instr = 1'b0;
                    c.imm_sel = 3'd0;
                    c.alu_src_b = 1'b1;
                    c.reg_write = 1'b1;
                    c.mem_read = 1'b1;
                    c.wb_sel = 2'd1;
                    c.mem_size = f3[1:0];
                    c.mem_unsigned = f3[2];
                    c.uses_rs1 = 1'b1;
                end
            end

            7'h23: begin
                if (f3 <= 3'd2) begin
                    c.illegal_instr = 1'b0;
                    c.imm_sel = 3'd1;
                    c.alu_src_b = 1'b1;
                    c.mem_write = 1'b1;
                    c.mem_size = f3[1:0];
                    c.uses_rs1 = 1'b1;
                    c.uses_rs2 = 1'b1;
                end
            end

            7'h63: begin
                if (f3 != 3'd2 && f3 != 3'd3) begin
                    c.illegal_instr = 1'b0;
                    c.imm_sel = 3'd2;
                    c.branch = 1'b1;
                    c.branch_type = f3;
                    c.uses_rs1 = 1'b1;
                    c.uses_rs2 = 1'b1;

                    if (f3[2] == 1'b0)
                        c.alu_op = 4'd1;
                    else if (f3[1] == 1'b0)
                        c.alu_op = 4'd8;
                    else
                        c.alu_op = 4'd9;
                end
            end

            7'h6F: begin
                c.illegal_instr = 1'b0;
                c.imm_sel = 3'd4;
                c.alu_src_a = 2'd1;
                c.alu_src_b = 1'b1;
                c.jump = 1'b1;
                c.reg_write = 1'b1;
                c.wb_sel = 2'd2;
            end

            7'h67: begin
                if (f3 == 3'd0) begin
                    c.illegal_instr = 1'b0;
                    c.imm_sel = 3'd0;
                    c.alu_src_b = 1'b1;
                    c.jump = 1'b1;
                    c.jalr = 1'b1;
                    c.reg_write = 1'b1;
                    c.wb_sel = 2'd2;
                    c.uses_rs1 = 1'b1;
                end
            end

            7'h37: begin
                c.illegal_instr = 1'b0;
                c.imm_sel = 3'd3;
                c.alu_src_a = 2'd2;
                c.alu_src_b = 1'b1;
                c.reg_write = 1'b1;
            end

            7'h17: begin
                c.illegal_instr = 1'b0;
                c.imm_sel = 3'd3;
                c.alu_src_a = 2'd1;
                c.alu_src_b = 1'b1;
                c.reg_write = 1'b1;
            end

            default: begin
            end

        endcase

        return c;

    endfunction

    task automatic check_instruction(
        input logic [31:0] instruction
    );

        control_t expected;

        instr = instruction;
        expected = reference_model(instruction);

        #1;

        if (actual !== expected) begin

            $display("FAIL: instr=%h", instruction);
            $display("opcode=%b funct3=%b funct7=%b",
                instruction[6:0],
                instruction[14:12],
                instruction[31:25]);

            $display("Signal         Expected Actual");
            $display("alu_op         %b     %b",
                expected.alu_op, actual.alu_op);
            $display("imm_sel        %b      %b",
                expected.imm_sel, actual.imm_sel);
            $display("alu_src_a      %b       %b",
                expected.alu_src_a, actual.alu_src_a);
            $display("alu_src_b      %b        %b",
                expected.alu_src_b, actual.alu_src_b);
            $display("reg_write      %b        %b",
                expected.reg_write, actual.reg_write);
            $display("wb_sel         %b       %b",
                expected.wb_sel, actual.wb_sel);
            $display("mem_read       %b        %b",
                expected.mem_read, actual.mem_read);
            $display("mem_write      %b        %b",
                expected.mem_write, actual.mem_write);
            $display("mem_size       %b       %b",
                expected.mem_size, actual.mem_size);
            $display("mem_unsigned   %b        %b",
                expected.mem_unsigned, actual.mem_unsigned);
            $display("branch         %b        %b",
                expected.branch, actual.branch);
            $display("branch_type    %b      %b",
                expected.branch_type, actual.branch_type);
            $display("jump           %b        %b",
                expected.jump, actual.jump);
            $display("jalr           %b        %b",
                expected.jalr, actual.jalr);
            $display("uses_rs1       %b        %b",
                expected.uses_rs1, actual.uses_rs1);
            $display("uses_rs2       %b        %b",
                expected.uses_rs2, actual.uses_rs2);
            $display("illegal_instr  %b        %b",
                expected.illegal_instr, actual.illegal_instr);

            $fatal(1, "Decoder output mismatch");

        end

        if (actual.mem_read && actual.mem_write)
            $fatal(1, "Simultaneous memory read and write");

        if (actual.illegal_instr &&
            (actual.reg_write || actual.mem_read ||
             actual.mem_write || actual.branch ||
             actual.jump || actual.jalr))
            $fatal(1, "Illegal instruction has side effects");

        if (actual.jalr && !actual.jump)
            $fatal(1, "JALR asserted without jump");

        if (actual.branch && actual.jump)
            $fatal(1, "Branch and jump asserted simultaneously");

        if (actual.alu_op > 4'd9)
            $fatal(1, "Reserved ALU operation");

        if (actual.imm_sel > 3'd5 ||
            actual.alu_src_a == 2'd3 ||
            actual.wb_sel == 2'd3 ||
            actual.mem_size == 2'd3)
            $fatal(1, "Reserved control selection");

        tests_passed++;

        if (actual.illegal_instr)
            illegal_count++;
        else
            legal_count++;

    endtask

    initial begin

        instr = '0;

        if ($test$plusargs("WAVES")) begin
            $dumpfile("build/decoder.vcd");
            $dumpvars(0, decoder_tb);
        end

        check_instruction(32'h002081B3);
        check_instruction(32'h402081B3);
        check_instruction(32'h002091B3);
        check_instruction(32'h0020A1B3);
        check_instruction(32'h0020B1B3);
        check_instruction(32'h0020C1B3);
        check_instruction(32'h0020D1B3);
        check_instruction(32'h4020D1B3);
        check_instruction(32'h0020E1B3);
        check_instruction(32'h0020F1B3);

        $display("PASS: R-type arithmetic");

        check_instruction(32'h00A18293);
        check_instruction(32'h00509193);
        check_instruction(32'h0050A193);
        check_instruction(32'h0050B193);
        check_instruction(32'h0050C193);
        check_instruction(32'h0050D193);
        check_instruction(32'h4050D193);
        check_instruction(32'h0050E193);
        check_instruction(32'h0050F193);

        $display("PASS: Immediate arithmetic");

        check_instruction(32'h00010283);
        check_instruction(32'h00011283);
        check_instruction(32'h00012283);
        check_instruction(32'h00014283);
        check_instruction(32'h00015283);

        $display("PASS: Loads");

        check_instruction(32'h00510423);
        check_instruction(32'h00511423);
        check_instruction(32'h00512423);

        $display("PASS: Stores");

        check_instruction(32'h00208863);
        check_instruction(32'h00209863);
        check_instruction(32'h0020C863);
        check_instruction(32'h0020D863);
        check_instruction(32'h0020E863);
        check_instruction(32'h0020F863);

        $display("PASS: Branches");

        check_instruction(32'h100000EF);
        check_instruction(32'h000100E7);
        check_instruction(32'h123452B7);
        check_instruction(32'h12345297);

        $display("PASS: JAL, JALR, LUI, AUIPC");

        check_instruction(32'hFFFFFFFF);
        check_instruction(32'h00000000);
        check_instruction(32'h022081B3);
        check_instruction(32'h022091B3);
        check_instruction(32'h02009193);
        check_instruction(32'h0200D193);
        check_instruction(32'h00013283);
        check_instruction(32'h00513423);
        check_instruction(32'h0020A863);
        check_instruction(32'h000110E7);
        check_instruction(32'h0000000F);
        check_instruction(32'h00000073);
        check_instruction(32'h00100073);

        $display("PASS: Unsupported encodings");

        check_instruction(32'h00512423);
        check_instruction(32'h002081B3);
        check_instruction(32'h00012283);
        check_instruction(32'hFFFFFFFF);
        check_instruction(32'h000100E7);
        check_instruction(32'h100000EF);
        check_instruction(32'h00208863);
        check_instruction(32'h00A18293);

        $display("PASS: Instruction transitions");

        check_instruction(32'hFF618293);
        check_instruction(32'hFE512C23);
        check_instruction(32'hFE2088E3);

        $display("PASS: Negative immediates");

        $display("Starting exhaustive decoding tests");

        for (int op = 0; op < 128; op++) begin
            for (int f3 = 0; f3 < 8; f3++) begin
                for (int f7 = 0; f7 < 128; f7++) begin
                    check_instruction({
                        7'(f7),
                        5'd2,
                        5'd1,
                        3'(f3),
                        5'd3,
                        7'(op)
                    });
                end
            end
        end

        $display("PASS: 131072 exhaustive combinations");

        repeat (10000) begin
            check_instruction($urandom);
        end

        $display("PASS: Random instruction words");

        $display("--------------------------------");
        $display("Total tests passed: %0d", tests_passed);
        $display("Legal instructions: %0d", legal_count);
        $display("Illegal instructions: %0d", illegal_count);
        $display("ALL DECODER TESTS PASSED");
        $display("--------------------------------");

        $finish;

    end

    initial begin
        #1000000;
        $fatal(1, "Simulation timeout");
    end

endmodule
