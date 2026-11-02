
module alu (
    // input control
    input logic [5:0] AluCtrl,
    // input data
    input  logic [31:0] SrcA,
    input  logic [31:0] SrcB,
    // output result
    output logic [31:0] AluResult,
    output logic         Zero,
    output logic         Sign,
    output logic         LessThan,
    output logic         LessThanU
);
    // individual control signals
    logic Alu_And_En, Alu_Or_En, Alu_Xor_En, Alu_Add_En, InvB, CarryIn;
    assign {CarryIn, InvB, Alu_Add_En, Alu_Xor_En, Alu_Or_En, Alu_And_En} = AluCtrl[5:0];


    logic [31:0] SrcB_mux;
    logic [32:0] AddResult;

    // input 2 mux - SrcB vs ~SrcB
    assign SrcB_mux = InvB ? ~SrcB : SrcB;

    // adder
    assign AddResult = {1'b0, SrcA} + {1'b0, SrcB_mux} + {32'b0, CarryIn};

    assign Zero     = (AluResult == 32'b0);
    assign Sign     = AluResult[31];

    logic Overflow;
    assign Overflow = ~(SrcA[31] ^ SrcB_mux[31]) & (SrcA[31] ^ AddResult[31]);
    assign LessThan  = Sign ^ Overflow; // Sign == AluResult[31] == AddResult[31]
    assign LessThanU = ~AddResult[32];



    // result mux (one-hot)
    always_comb begin
        case ({Alu_Add_En, Alu_Xor_En, Alu_Or_En, Alu_And_En})
            4'b0001: AluResult = SrcA & SrcB_mux;
            4'b0010: AluResult = SrcA | SrcB_mux;
            4'b0100: AluResult = SrcA ^ SrcB_mux;
            4'b1000: AluResult = AddResult[31:0];
            default: AluResult = 32'b0;
        endcase
    end
    
endmodule
