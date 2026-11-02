
module shifter (
    // input control
    input  logic [2:0]  ShifterCtrl,
    input  logic [4:0]  Shamt,
    // input data
    input  logic [31:0] SrcA,
    // output
    output logic [31:0] ShiftResult
);

    always_comb begin
        case (ShifterCtrl)
            3'b001:  ShiftResult = SrcA << Shamt;
            3'b010:  ShiftResult = SrcA >> Shamt;
            3'b100:  ShiftResult = $signed(SrcA) >>> Shamt;
            default: ShiftResult = 32'b0;
        endcase
    end

endmodule
