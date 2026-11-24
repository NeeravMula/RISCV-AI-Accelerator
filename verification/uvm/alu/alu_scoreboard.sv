
class alu_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_imp #(alu_item, alu_scoreboard) analysis_export;

    int unsigned tests_passed = 0;
    int unsigned tests_failed = 0;

    function new(string name = "alu_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
    endfunction

    function void write(alu_item item);
        bit [31:0] expected_result;
        bit expected_zero;

        case (item.alu_op)
            4'd0: expected_result = item.a + item.b;
            4'd1: expected_result = item.a - item.b;
            4'd2: expected_result = item.a & item.b;
            4'd3: expected_result = item.a | item.b;
            4'd4: expected_result = item.a ^ item.b;
            4'd5: expected_result = item.a << item.b[4:0];
            4'd6: expected_result = item.a >> item.b[4:0];
            4'd7: expected_result = $signed(item.a) >>> item.b[4:0];
            4'd8: expected_result = ($signed(item.a) < $signed(item.b))
                                   ? 32'd1 : 32'd0;
            4'd9: expected_result = (item.a < item.b)
                                   ? 32'd1 : 32'd0;
            default: begin
                `uvm_error("ALU_SB", "Invalid ALU operation")
                tests_failed++;
                return;
            end
        endcase

        expected_zero = (expected_result == 32'd0);

        if (item.result !== expected_result ||
            item.zero !== expected_zero) begin

            tests_failed++;

            `uvm_error("ALU_SB",
                $sformatf(
                    "Mismatch: op=%0d a=%h b=%h expected=%h got=%h expected_zero=%b got_zero=%b",
                    item.alu_op,
                    item.a,
                    item.b,
                    expected_result,
                    item.result,
                    expected_zero,
                    item.zero
                ))
        end
        else begin
            tests_passed++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("ALU_SB",
            $sformatf("Passed=%0d Failed=%0d",
                      tests_passed, tests_failed),
            UVM_LOW)
    endfunction

endclass
