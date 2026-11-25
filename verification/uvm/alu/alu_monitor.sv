class alu_monitor extends uvm_monitor;

    `uvm_component_utils(alu_monitor)

    virtual alu_if vif;

    uvm_analysis_port #(alu_item) ap;

    function new(string name = "alu_monitor",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual alu_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("ALU_MON", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        alu_item item;

        forever begin
            @(posedge vif.sample_clk);

            if (vif.valid) begin
                item = alu_item::type_id::create("item");

                item.a = vif.a;
                item.b = vif.b;
                item.alu_op = vif.alu_op;
                item.result = vif.result;
                item.zero = vif.zero;

                ap.write(item);
            end
        end
    endtask

endclass
