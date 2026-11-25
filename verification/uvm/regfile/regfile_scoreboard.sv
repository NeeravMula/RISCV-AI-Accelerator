class regfile_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(regfile_scoreboard)

    uvm_analysis_imp #(regfile_item, regfile_scoreboard) analysis_export;

    logic [31:0] expected_registers [0:31];

    int checks = 0;
    int errors = 0;
    int transactions = 0;
    bit reset_seen = 0;

    function new(string name = "regfile_scoreboard",
                 uvm_component parent = null);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction

    function void write(regfile_item item);

        transactions++;

        if (item.rst) begin
            foreach (expected_registers[i])
                expected_registers[i] = 32'd0;

            reset_seen = 1;
        end
        else if (!reset_seen) begin
            `uvm_fatal("RESET", "Transaction observed before reset")
        end
        else if (item.rd_we && item.rd_addr != 5'd0) begin
            expected_registers[item.rd_addr] = item.rd_data;
        end

        expected_registers[0] = 32'd0;

        checks++;

        if (item.r1_data !== expected_registers[item.r1_addr]) begin
            errors++;

            `uvm_error("REGFILE",
                $sformatf("Port 1: x%0d expected %h, got %h",
                    item.r1_addr,
                    expected_registers[item.r1_addr],
                    item.r1_data))
        end

        checks++;

        if (item.r2_data !== expected_registers[item.r2_addr]) begin
            errors++;

            `uvm_error("REGFILE",
                $sformatf("Port 2: x%0d expected %h, got %h",
                    item.r2_addr,
                    expected_registers[item.r2_addr],
                    item.r2_data))
        end

    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCOREBOARD",
            $sformatf("Transactions: %0d Checks: %0d Errors: %0d",
                transactions, checks, errors),
            UVM_LOW)

        if (checks == 0 || !reset_seen)
            `uvm_error("SCOREBOARD", "Insufficient verification activity")
        else if (errors == 0)
            `uvm_info("SCOREBOARD", "ALL REGISTER FILE CHECKS PASSED", UVM_LOW)
        else
            `uvm_error("SCOREBOARD", "REGISTER FILE TEST FAILED")

    endfunction

endclass
