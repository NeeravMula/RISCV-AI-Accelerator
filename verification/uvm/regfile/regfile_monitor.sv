class regfile_monitor extends uvm_monitor;


    `uvm_component_utils(regfile_monitor)

    virtual regfile_if vif;

    uvm_analysis_port #(regfile_item) ap;

    function new(string name = "regfile_monitor",
        uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual regfile_if)::get(
        this, "", "vif", vif
        ))
        `uvm_fatal("NOVIF", "Register file interface not found")
    endfunction

    task run_phase(uvm_phase phase);

        regfile_item item;

        forever begin
            @(posedge vif.clk);

            item = regfile_item::type_id::create("item");

            item.rst     = vif.rst;
            item.r1_addr = vif.r1_addr;
            item.r2_addr = vif.r2_addr;
            item.rd_addr = vif.rd_addr;
            item.rd_data = vif.rd_data;
            item.rd_we   = vif.rd_we;

            #1ns;

            item.r1_data = vif.r1_data;
            item.r2_data = vif.r2_data;

            ap.write(item);
            end

    endtask

endclass
