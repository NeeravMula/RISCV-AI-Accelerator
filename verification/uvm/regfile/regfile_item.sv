class regfile_item extends uvm_sequence_item;

    rand bit [4:0] r1_addr;
    rand bit [4:0] r2_addr;
    
    rand bit [4:0] rd_addr;
    rand bit [31:0] rd_data;
    rand bit rd_we;

    logic rst;
    logic [31:0] r1_data;
    logic [31:0] r2_data;

    `uvm_object_utils(regfile_item)

    function new(string name = "regfile_item");
        super.new(name);
    endfunction

endclass
