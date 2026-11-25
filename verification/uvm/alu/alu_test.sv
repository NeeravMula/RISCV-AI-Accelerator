class alu_test extends uvm_test;

    `uvm_component_utils(alu_test)

    alu_env env;

    function new(string name = "alu_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = alu_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);

        alu_directed_sequence directed_seq;
        alu_sequence random_seq;

        phase.raise_objection(this);

        directed_seq = alu_directed_sequence::type_id::create("directed_seq");
        random_seq = alu_sequence::type_id::create("random_seq");

        `uvm_info("ALU_TEST", "Starting directed sequence", UVM_LOW)

        directed_seq.start(env.agent.sequencer);

        if ((env.scoreboard.tests_passed +
             env.scoreboard.tests_failed) != 30)
            `uvm_fatal("ALU_TEST", "Directed transaction count mismatch")

        `uvm_info("ALU_TEST", "Starting randomized sequence", UVM_LOW)

        random_seq.start(env.agent.sequencer);

        if ((env.scoreboard.tests_passed +
             env.scoreboard.tests_failed) != 130)
            `uvm_fatal("ALU_TEST", "Total transaction count mismatch")

        if (env.scoreboard.tests_failed != 0)
            `uvm_fatal("ALU_TEST",
                $sformatf("%0d ALU transactions failed",
                          env.scoreboard.tests_failed))

        `uvm_info("ALU_TEST", "All 130 ALU transactions passed", UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass
