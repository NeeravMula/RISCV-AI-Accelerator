module pc #(
        parameter [31:0] RESET_ADDR = 32'h00000000
    )(
    input wire clk,
    input wire rst,
    input wire stall,
    input wire redirect,
    input wire[31:0] pc_next,
    input wire[31:0] redirect_addr,

    output reg [31:0] pc_out
    
);

always @(posedge clk) begin
    if(rst) begin
        pc_out <= RESET_ADDR;
    end
    else if(redirect) begin
        pc_out <= redirect_addr;
    end
    else if(!stall) begin
        pc_out <= pc_next;
    end
    else begin
        pc_out <= pc_out;
    end
end

endmodule
