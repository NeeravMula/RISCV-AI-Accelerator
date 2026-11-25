module decoder(
    input wire [31:0] instr,
    output reg [3:0] alu_op,
    output reg [2:0] imm_sel,
    output reg [1:0] alu_src_a,
    output reg alu_src_b,
    output reg reg_write,
    output reg [1:0] wb_sel,
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] mem_size,
    output reg mem_unsigned,
    output reg branch,
    output reg [2:0] branch_type,
    output reg jump,
    output reg jalr,
    output reg uses_rs1,
    output reg uses_rs2,
    output reg illegal_instr
);

    wire [14:0] unused_instr;
    assign unused_instr = {instr[24:15], instr[11:7]};

    localparam [6:0] OP_REG         = 7'b0110011;
    localparam [6:0] OP_IMM         = 7'b0010011;
    localparam [6:0] OP_LOAD        = 7'b0000011;
    localparam [6:0] OP_STORE       = 7'b0100011;
    localparam [6:0] OP_BRANCH      = 7'b1100011;
    localparam [6:0] OP_JAL         = 7'b1101111;
    localparam [6:0] OP_JALR        = 7'b1100111;
    localparam [6:0] OP_LUI         = 7'b0110111;
    localparam [6:0] OP_AUIPC       = 7'b0010111;

    localparam [3:0] ALU_ADD        = 4'b0000;
    localparam [3:0] ALU_SUB        = 4'b0001;
    localparam [3:0] ALU_AND        = 4'b0010;
    localparam [3:0] ALU_OR         = 4'b0011;
    localparam [3:0] ALU_XOR        = 4'b0100;
    localparam [3:0] ALU_SLL        = 4'b0101;
    localparam [3:0] ALU_SRL        = 4'b0110;
    localparam [3:0] ALU_SRA        = 4'b0111;
    localparam [3:0] ALU_SLT        = 4'b1000;
    localparam [3:0] ALU_SLTU       = 4'b1001;

    localparam [2:0] IMM_GEN_I_TYPE = 3'b000;
    localparam [2:0] IMM_GEN_S_TYPE = 3'b001;
    localparam [2:0] IMM_GEN_B_TYPE = 3'b010;
    localparam [2:0] IMM_GEN_U_TYPE = 3'b011;
    localparam [2:0] IMM_GEN_J_TYPE = 3'b100;
    localparam [2:0] IMM_GEN_NONE   = 3'b101;

    localparam [1:0] ALU_SRC_A_RS1  = 2'b00;
    localparam [1:0] ALU_SRC_A_PC   = 2'b01;
    localparam [1:0] ALU_SRC_A_ZERO = 2'b10;    

    localparam ALU_SRC_B_RS2        = 1'b0;
    localparam ALU_SRC_B_IMM        = 1'b1;

    localparam [1:0] MEM_BYTE       = 2'b00;
    localparam [1:0] MEM_HALF       = 2'b01;
    localparam [1:0] MEM_WORD       = 2'b10;

    localparam [1:0] WB_ALU         = 2'b00;
    localparam [1:0] WB_MEM         = 2'b01;
    localparam [1:0] WB_PC4         = 2'b10;

    localparam [2:0] BR_BEQ         = 3'b000;
    localparam [2:0] BR_BNE         = 3'b001;
    localparam [2:0] BR_BLT         = 3'b100;
    localparam [2:0] BR_BGE         = 3'b101;
    localparam [2:0] BR_BLTU        = 3'b110;
    localparam [2:0] BR_BGEU        = 3'b111;

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    always @(*) begin
        alu_op = ALU_ADD;
        imm_sel = IMM_GEN_NONE;
        alu_src_a = ALU_SRC_A_RS1;
        alu_src_b = ALU_SRC_B_RS2;
        reg_write = 1'b0;
        wb_sel = WB_ALU;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_size = MEM_BYTE;
        mem_unsigned = 1'b0;
        branch = 1'b0;
        branch_type = BR_BEQ;
        jump = 1'b0;
        jalr = 1'b0;
        uses_rs1 = 1'b0;
        uses_rs2 = 1'b0;
        illegal_instr = 1'b1;

        case (opcode)
            OP_REG : begin
                case (funct3)
                    3'b000 :  begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_ADD;
                            illegal_instr = 1'b0;
                        end
                        else if(funct7 == 7'b0100000) begin
                            alu_op = ALU_SUB;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b001 : begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_SLL;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b010 : begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_SLT;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b011 : begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_SLTU;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b100 : begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_XOR;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b101 : begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_SRL;
                            illegal_instr = 1'b0;
                        end
                        else if(funct7 == 7'b0100000) begin
                            alu_op = ALU_SRA;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b110 : begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_OR;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b111 : begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_AND;
                            illegal_instr = 1'b0;
                        end
                    end
                    default : begin
                    end
                endcase
                if (!illegal_instr) begin
                    reg_write = 1'b1;
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                end
            end
            OP_IMM : begin
                case (funct3)
                    3'b000: begin
                        alu_op = ALU_ADD;
                        illegal_instr = 1'b0;
                    end
                    3'b001: begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_SLL;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b010: begin   
                        alu_op = ALU_SLT;
                        illegal_instr = 1'b0;
                    end
                    3'b011: begin
                        alu_op = ALU_SLTU;
                        illegal_instr = 1'b0;
                    end
                    3'b100: begin
                        alu_op = ALU_XOR;
                        illegal_instr = 1'b0;
                    end
                    3'b101: begin
                        if(funct7 == 7'b0000000) begin
                            alu_op = ALU_SRL;
                            illegal_instr = 1'b0;
                        end
                        else if (funct7 == 7'b0100000) begin
                            alu_op = ALU_SRA;
                            illegal_instr = 1'b0;
                        end
                    end
                    3'b110: begin
                        alu_op = ALU_OR;
                        illegal_instr = 1'b0;
                    end
                    3'b111: begin
                        alu_op = ALU_AND;
                        illegal_instr = 1'b0;
                    end
                    default: begin
                    end
                endcase
                if(!illegal_instr) begin
                    imm_sel = IMM_GEN_I_TYPE;
                    alu_src_b = ALU_SRC_B_IMM;
                    reg_write = 1'b1;
                    uses_rs1 = 1'b1;
                end
            end
            OP_LOAD : begin
                case (funct3)
                    3'b000: begin
                        mem_size = MEM_BYTE;
                        illegal_instr = 1'b0;
                    end
                    3'b001: begin
                        mem_size = MEM_HALF;
                        illegal_instr = 1'b0;
                    end
                    3'b010: begin
                        mem_size = MEM_WORD;
                        illegal_instr = 1'b0;
                    end
                    3'b100: begin
                        mem_size = MEM_BYTE;
                        mem_unsigned = 1'b1;
                        illegal_instr = 1'b0;
                    end
                    3'b101: begin
                        mem_size = MEM_HALF;
                        mem_unsigned = 1'b1;
                        illegal_instr = 1'b0;
                    end
                    default: begin
                    end
                endcase
                if(!illegal_instr) begin
                    imm_sel = IMM_GEN_I_TYPE;
                    alu_src_b = ALU_SRC_B_IMM;
                    reg_write = 1'b1;
                    mem_read = 1'b1;
                    uses_rs1 = 1'b1;
                    wb_sel = WB_MEM;
                end
            end
            OP_STORE : begin
                case (funct3)
                    3'b000: begin
                        mem_size = MEM_BYTE;
                        illegal_instr = 1'b0;
                    end
                    3'b001: begin
                        mem_size = MEM_HALF;
                        illegal_instr = 1'b0;
                    end
                    3'b010: begin
                        mem_size = MEM_WORD;
                        illegal_instr = 1'b0;
                    end
                    default: begin
                    end
                endcase
                if(!illegal_instr) begin
                    imm_sel = IMM_GEN_S_TYPE;
                    alu_src_b = ALU_SRC_B_IMM;
                    mem_write = 1'b1;
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                end
            end
            OP_BRANCH : begin
                case (funct3)
                    3'b000: begin
                        alu_op = ALU_SUB;
                        branch_type = BR_BEQ;
                        illegal_instr = 1'b0;
                    end
                    3'b001: begin
                        alu_op = ALU_SUB;
                        branch_type = BR_BNE;
                        illegal_instr = 1'b0;
                    end
                    3'b100: begin
                        alu_op = ALU_SLT;
                        branch_type = BR_BLT;
                        illegal_instr = 1'b0;
                    end
                    3'b101: begin
                        alu_op = ALU_SLT;
                        branch_type = BR_BGE;
                        illegal_instr = 1'b0;
                    end
                    3'b110: begin
                        alu_op = ALU_SLTU;
                        branch_type = BR_BLTU;
                        illegal_instr = 1'b0;
                    end
                    3'b111: begin
                        alu_op = ALU_SLTU;
                        branch_type = BR_BGEU;
                        illegal_instr = 1'b0;
                    end
                    default: begin
                    end
                endcase
                if(!illegal_instr) begin
                    imm_sel = IMM_GEN_B_TYPE;
                    uses_rs1 = 1'b1;
                    uses_rs2 = 1'b1;
                    branch = 1'b1;
                end
            end
            OP_JAL : begin
                illegal_instr = 1'b0;
                alu_src_a = ALU_SRC_A_PC;
                alu_src_b = ALU_SRC_B_IMM;
                imm_sel = IMM_GEN_J_TYPE;
                jump = 1'b1;
                reg_write = 1'b1;
                wb_sel = WB_PC4;
            end
            OP_JALR : begin
                if(funct3 == 3'b000) begin
                    illegal_instr = 1'b0;
                    alu_src_b = ALU_SRC_B_IMM;
                    imm_sel = IMM_GEN_I_TYPE;
                    jump = 1'b1;
                    jalr = 1'b1;
                    uses_rs1 = 1'b1;
                    reg_write = 1'b1;
                    wb_sel = WB_PC4;
                end
            end
            OP_LUI : begin
                illegal_instr = 1'b0;
                alu_src_a = ALU_SRC_A_ZERO;
                alu_src_b = ALU_SRC_B_IMM;
                imm_sel = IMM_GEN_U_TYPE;
                reg_write = 1'b1;
            end
            OP_AUIPC : begin
                illegal_instr = 1'b0;
                alu_src_a = ALU_SRC_A_PC;
                alu_src_b = ALU_SRC_B_IMM;
                imm_sel = IMM_GEN_U_TYPE;
                reg_write = 1'b1;
            end
            default : begin
            end
        endcase
    end

endmodule

