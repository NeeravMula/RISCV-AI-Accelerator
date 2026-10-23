module regfile(
    input wire clk,
    input wire rst,

    input wire[4:0] r1_addr,
    output reg[31:0] r1_data,
    input wire[4:0] r2_addr,
    output reg[31:0] r2_data,

    input wire [4:0] rd_addr,
    input wire [31:0] rd_data, 

    input wire rd_we

);

reg[31:0] registers [0:31];

always@(posedge clk) begin
    if(rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end 
    else if(rd_we) begin
        if(rd_addr!=0) begin
            registers[rd_addr] <= rd_data;
        end
    end
    else begin
        r1_data <= registers[r1_addr];
        r2_data <= registers[r2_addr];
    end
end




endmodule






