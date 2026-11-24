class alu_item extends uvm_sequence_item;

    `uvm_object_utils(alu_item)

    rand bit [31:0] a;
    rand bit [31:0] b;
    rand bit [3:0] alu_op;

    logic [31:0] result;
    logic zero;

    constraint valid_alu_op {
        alu_op inside {[4'd0:4'd9]};
    }

    function new(string name = "alu_item");
        super.new(name);
    endfunction

endclass
