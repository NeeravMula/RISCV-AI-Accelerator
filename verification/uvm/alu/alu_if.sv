interface alu_if(input logic sample_clk);

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0] alu_op;

    logic [31:0] result;
    logic zero;

    logic valid;

endinterface

