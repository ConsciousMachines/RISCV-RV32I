
module PC_unit (
    input  logic        clk,
    input  logic        rst,
    // input control
    input  logic        PCNextSrc,       // choose PCPlus4 or PCTarget
    input  logic        PCTargetBaseSrc, // choose PC or register RD1
    // input data
    input  logic [31:0] RD1,
    input  logic [31:0] ImmExt,
    // output
    output logic [31:0] PC,
    output logic [31:0] PCPlus4,
    output logic [31:0] PCTarget
);
    // internal signals
    logic [31:0] PCNext, PCTargetBase;

    // PC
    always_ff @(posedge clk) begin
        if (rst)
            PC <= 32'h8000_0100;
        else
            PC <= PCNext;
    end

    // mux - PCNext
    assign PCNext = PCNextSrc ? PCTarget : PCPlus4;

    // adder - PCPlus4
    assign PCPlus4 = PC + 32'h4;

    // adder - PCTarget
    assign PCTarget = PCTargetBase + ImmExt;

    // mux - PCTargetBase
    assign PCTargetBase = PCTargetBaseSrc ? RD1 : PC;

endmodule
