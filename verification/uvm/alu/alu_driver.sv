class alu_driver extends uvm_driver #(alu_item);

    `uvm_component_utils(alu_driver)

    virtual alu_if vif;

    function new(string name = "alu_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("ALU_DRV", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        alu_item item;

        vif.valid = 1'b0;
        vif.a = 32'd0;
        vif.b = 32'd0;
        vif.alu_op = 4'd0;

        forever begin
            seq_item_port.get_next_item(item);

            @(negedge vif.sample_clk);

            vif.a = item.a;
            vif.b = item.b;
            vif.alu_op = item.alu_op;
            vif.valid = 1'b1;

            @(posedge vif.sample_clk);
            #1;

            seq_item_port.item_done();

            @(negedge vif.sample_clk);
            vif.valid = 1'b0;
        end
    endtask

endclass
