
module imm_ext (
    input  logic [31:0] instr,
    input  logic [4:0]  ImmExtSrc, // one-hot
    output logic [31:0] ImmExt
);
    always_comb begin
        case (ImmExtSrc)
            // I-type
            5'b00001:  ImmExt = {{21{instr[31]}}, instr[30:20]};
            // S-type
            5'b00010:  ImmExt = {{21{instr[31]}}, instr[30:25], instr[11:7]};
            // B-type
            5'b00100:  ImmExt = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            // J-type
            5'b01000:  ImmExt = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            // U-type
            5'b10000:  ImmExt = {instr[31:12], 12'b0};
            default: ImmExt = 32'b0;
        endcase
    end

endmodule
