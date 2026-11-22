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


always@(*) begin
    r1_data = (r1_addr == 5'd0) ? 32'd0 : registers[r1_addr];
    r2_data = (r2_addr == 5'd0) ? 32'd0 : registers[r2_addr];
end

always@(posedge clk) begin
    if(rst) begin
        for (int i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end 
    else if(rd_we && rd_addr != 5'd0) begin
        registers[rd_addr] <= rd_data;
    end
end

endmodule
