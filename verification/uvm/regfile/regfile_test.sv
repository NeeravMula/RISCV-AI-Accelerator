class regfile_test extends uvm_test;

    `uvm_component_utils(regfile_test)

    regfile_env env;
    virtual regfile_if vif;

    function new(string name = "regfile_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual regfile_if)::get(
            this, "", "vif", vif
        ))
            `uvm_fatal("NOVIF", "Register file interface not found")

        env = regfile_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);

        regfile_sequence seq;

        phase.raise_objection(this);

        wait (vif.rst == 1'b0);

        seq = regfile_sequence::type_id::create("seq");

        seq.start(env.agent.sequencer);

        @(negedge vif.clk);

        phase.drop_objection(this);

    endtask

endclass
