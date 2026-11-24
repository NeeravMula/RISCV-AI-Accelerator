class regfile_sequence extends uvm_sequence #(regfile_item);

    `uvm_object_utils(regfile_sequence)

    function new(string name = "regfile_sequence");
        super.new(name);
    endfunction

    task send_transaction(
        bit [4:0] r1,
        bit [4:0] r2,
        bit [4:0] rd,
        bit [31:0] data,
        bit we
    );

        regfile_item item;

        item = regfile_item::type_id::create("item");

        start_item(item);

        item.r1_addr = r1;
        item.r2_addr = r2;
        item.rd_addr = rd;
        item.rd_data = data;
        item.rd_we = we;

        finish_item(item);

    endtask

    task body();

        regfile_item item;

        send_transaction(5'd0, 5'd0, 5'd0, 32'd0, 1'b0);

        send_transaction(5'd5, 5'd0, 5'd5, 32'd42, 1'b1);

        send_transaction(5'd0, 5'd0, 5'd0, 32'd100, 1'b1);

        send_transaction(5'd3, 5'd5, 5'd3, 32'd123, 1'b1);

        send_transaction(5'd3, 5'd7, 5'd7, 32'd456, 1'b1);

        send_transaction(5'd5, 5'd3, 5'd5, 32'd999, 1'b0);

        send_transaction(5'd5, 5'd5, 5'd5, 32'hFFFFFFFF, 1'b1);

        send_transaction(5'd31, 5'd0, 5'd31, 32'h80000000, 1'b1);

        for (int i = 1; i < 32; i++) begin
            send_transaction(
                5'(i), 5'd0, 5'(i), 32'(i * 100), 1'b1
            );
        end

        for (int i = 0; i < 32; i++) begin
            send_transaction(
                5'(i), 5'(31-i), 5'd0, 32'd0, 1'b0
            );
        end

        `uvm_info("SEQUENCE", "Starting randomized transactions", UVM_LOW)

        repeat (1000) begin

            item = regfile_item::type_id::create("random_item");

            start_item(item);

            if (!item.randomize())
                `uvm_fatal("RAND", "Transaction randomization failed")

            finish_item(item);

        end

        for (int i = 0; i < 32; i++) begin
            send_transaction(
                5'(i), 5'(31-i), 5'd0, 32'd0, 1'b0
            );
        end

        `uvm_info("SEQUENCE", "All transactions completed", UVM_LOW)

    endtask

endclass
