interface regfile_if(input logic clk);

    logic rst;

    logic [4:0] r1_addr;
    logic [31:0] r1_data;

    logic [4:0] r2_addr;
    logic [31:0] r2_data;

    logic [4:0] rd_addr;
    logic [31:0] rd_data;

    logic rd_we;

endinterface
