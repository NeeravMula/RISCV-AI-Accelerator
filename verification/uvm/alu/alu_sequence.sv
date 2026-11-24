
class alu_sequence extends uvm_sequence #(alu_item);

    `uvm_object_utils(alu_sequence)

    function new(string name = "alu_sequence");
        super.new(name);
    endfunction

    task body();
        alu_item item;

        for (int i = 0; i < 100; i++) begin
            item = alu_item::type_id::create("item");

            start_item(item);

            if (!item.randomize())
                `uvm_fatal("ALU_RAND", "ALU transaction randomization failed")

            finish_item(item);
        end
    endtask

endclass
