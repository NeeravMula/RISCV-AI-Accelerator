
class regfile_driver extends uvm_driver #(regfile_item);

    `uvm_component_utils(regfile_driver)

    virtual regfile_if vif;

    function new(string name = "regfile_driver",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual regfile_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Register file interface not found")
    endfunction

    task run_phase(uvm_phase phase);

        wait (vif.rst == 1'b0);

        forever begin
            seq_item_port.get_next_item(req);

            @(negedge vif.clk);

            vif.r1_addr = req.r1_addr;
            vif.r2_addr = req.r2_addr;
            vif.rd_addr = req.rd_addr;
            vif.rd_data = req.rd_data;
            vif.rd_we   = req.rd_we;

            @(posedge vif.clk);
            #1ns;

            @(negedge vif.clk);
            vif.rd_we = 1'b0;

            seq_item_port.item_done();
        end

    endtask

endclass
