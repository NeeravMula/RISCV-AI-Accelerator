
class alu_directed_sequence extends uvm_sequence #(alu_item);

    `uvm_object_utils(alu_directed_sequence)

    function new(string name = "alu_directed_sequence");
        super.new(name);
    endfunction

    task automatic send_op(
        input bit [31:0] lhs,
        input bit [31:0] rhs,
        input bit [3:0] op
    );
        alu_item item;

        item = alu_item::type_id::create("item");

        start_item(item);

        item.a = lhs;
        item.b = rhs;
        item.alu_op = op;

        finish_item(item);
    endtask

    task body();

        send_op(32'd10, 32'd20, 4'd0);
        send_op(32'hFFFFFFFF, 32'd1, 4'd0);
        send_op(32'd0, 32'd0, 4'd0);

        send_op(32'd25, 32'd25, 4'd1);
        send_op(32'd0, 32'd1, 4'd1);
        send_op(32'h80000000, 32'd1, 4'd1);

        send_op(32'hFFFFFFFF, 32'h00000000, 4'd2);
        send_op(32'hF0F0F0F0, 32'h0F0F0F0F, 4'd2);
        send_op(32'hFFFFFFFF, 32'hFFFFFFFF, 4'd2);

        send_op(32'h00000000, 32'h00000000, 4'd3);
        send_op(32'hF0F0F0F0, 32'h0F0F0F0F, 4'd3);
        send_op(32'hAAAAAAAA, 32'h55555555, 4'd3);

        send_op(32'hFFFFFFFF, 32'hFFFFFFFF, 4'd4);
        send_op(32'hAAAAAAAA, 32'h55555555, 4'd4);
        send_op(32'hFFFFFFFF, 32'h00000000, 4'd4);

        send_op(32'd1, 32'd31, 4'd5);
        send_op(32'hFFFFFFFF, 32'd0, 4'd5);
        send_op(32'd1, 32'd32, 4'd5);

        send_op(32'h80000000, 32'd31, 4'd6);
        send_op(32'hFFFFFFFF, 32'd1, 4'd6);
        send_op(32'h80000000, 32'd32, 4'd6);

        send_op(32'h80000000, 32'd31, 4'd7);
        send_op(32'hFFFFFFFF, 32'd4, 4'd7);
        send_op(32'h7FFFFFFF, 32'd1, 4'd7);

        send_op(32'hFFFFFFFF, 32'd1, 4'd8);
        send_op(32'd1, 32'hFFFFFFFF, 4'd8);
        send_op(32'h80000000, 32'h7FFFFFFF, 4'd8);

        send_op(32'hFFFFFFFF, 32'd1, 4'd9);
        send_op(32'd1, 32'hFFFFFFFF, 4'd9);
        send_op(32'h80000000, 32'h7FFFFFFF, 4'd9);

    endtask

endclass
