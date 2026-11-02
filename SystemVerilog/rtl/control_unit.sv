

module control_unit (
    // input
    input  logic [31:0] Instr,
    input  logic        Zero,
    input  logic        LessThan,
    input  logic        LessThanU,
    // output
    // PC_unit control
    output logic PCNextSrc,
    output logic PCTargetBaseSrc,
    // ImmExt control
    output logic [4:0] ImmExtSrc,
    // regfile control
    output logic WE3,
    // dmem control
    output logic MemWrite,
    // alu input control
    output logic       AluSrcBSrc, // SrcB = Rd2 or ImmExt ?
    output logic [5:0] AluCtrl,
    // shifter control
    output logic       ShamtSrc, // 0 = Instr, 1 = RD2
    output logic [2:0] ShifterCtrl,
    // Result control
    output logic [7:0] ResultSrc // one-hot encoded for now
);


    // --- Step 1 - get signals describing current instruction & group
    // ------------------------------------------------------------------------


    // encoding subgroups
    logic [6:0] Opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    assign Opcode = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7 = Instr[31:25];


    // instruction groups
    logic IsRType;
    logic IsIType;
    logic IsLoad;
    logic IsStore;
    logic IsBType;
    logic IsJAL;
    logic IsJALR;
    logic IsLUI;
    logic IsAUIPC;
    always_comb begin
        IsLoad   = 1'b0;
        IsStore  = 1'b0;
        IsIType  = 1'b0;
        IsRType  = 1'b0;
        IsBType  = 1'b0;
        IsJAL    = 1'b0;
        IsJALR   = 1'b0;
        IsLUI    = 1'b0;
        IsAUIPC  = 1'b0;
        
        case (Opcode)
            7'b00_000_11: IsLoad   = 1'b1;
            7'b01_000_11: IsStore  = 1'b1;
            7'b00_100_11: IsIType  = 1'b1;
            7'b01_100_11: IsRType  = 1'b1;
            7'b11_000_11: IsBType  = 1'b1;
            7'b11_011_11: IsJAL    = 1'b1;
            7'b11_001_11: IsJALR   = 1'b1;
            7'b01_101_11: IsLUI    = 1'b1;
            7'b00_101_11: IsAUIPC  = 1'b1;
            default:    ; // unsupported opcode
        endcase
    end

    // I-type
    logic IsADDI;
    logic IsSLTI;
    logic IsSLTIU;
    logic IsXORI;
    logic IsORI;
    logic IsANDI;
    logic IsSLLI;
    logic IsSRLI;
    logic IsSRAI;
    always_comb begin
        IsADDI  = 1'b0;
        IsSLTI  = 1'b0;
        IsSLTIU = 1'b0;
        IsXORI  = 1'b0;
        IsORI   = 1'b0;
        IsANDI  = 1'b0;
        IsSLLI  = 1'b0;
        IsSRLI  = 1'b0;
        IsSRAI  = 1'b0;

        if (IsIType) begin
            case (funct3)
                3'b000: IsADDI  = 1'b1;
                3'b010: IsSLTI  = 1'b1;
                3'b011: IsSLTIU = 1'b1;
                3'b100: IsXORI  = 1'b1;
                3'b110: IsORI   = 1'b1;
                3'b111: IsANDI  = 1'b1;
                3'b001: IsSLLI  = 1'b1;
                3'b101: begin
                    IsSRLI = ~funct7[5];
                    IsSRAI =  funct7[5];
                end
                default: ; // unreachable
            endcase
        end
    end


    // R-type
    logic IsADD;
    logic IsSUB;
    logic IsSLL;
    logic IsSLT;
    logic IsSLTU;
    logic IsXOR;
    logic IsSRL;
    logic IsSRA;
    logic IsOR;
    logic IsAND;
    always_comb begin
        IsADD  = 1'b0;
        IsSUB  = 1'b0;
        IsSLL  = 1'b0;
        IsSLT  = 1'b0;
        IsSLTU = 1'b0;
        IsXOR  = 1'b0;
        IsSRL  = 1'b0;
        IsSRA  = 1'b0;
        IsOR   = 1'b0;
        IsAND  = 1'b0;

        if (IsRType) begin
            case (funct3)
                3'b000: begin
                    IsADD = ~funct7[5];
                    IsSUB =  funct7[5];
                end
                3'b001: IsSLL  = 1'b1;
                3'b010: IsSLT  = 1'b1;
                3'b011: IsSLTU = 1'b1;
                3'b100: IsXOR  = 1'b1;
                3'b101: begin
                    IsSRL = ~funct7[5];
                    IsSRA =  funct7[5];
                end
                3'b110: IsOR   = 1'b1;
                3'b111: IsAND  = 1'b1;
                default: ; // unreachable
            endcase
        end
    end

    // B-type
    logic IsBEQ;
    logic IsBNE;
    logic IsBLT;
    logic IsBGE;
    logic IsBLTU;
    logic IsBGEU;
    always_comb begin
        IsBEQ  = 1'b0;
        IsBNE  = 1'b0;
        IsBLT  = 1'b0;
        IsBGE  = 1'b0;
        IsBLTU = 1'b0;
        IsBGEU = 1'b0;

        if (IsBType) begin
            case (funct3)
                3'b000: IsBEQ  = 1'b1;
                3'b001: IsBNE  = 1'b1;
                3'b100: IsBLT  = 1'b1;
                3'b101: IsBGE  = 1'b1;
                3'b110: IsBLTU = 1'b1;
                3'b111: IsBGEU = 1'b1;
                default: ; // unreachable
            endcase
        end
    end

    // --- Step 2 - drive signals depending on what instruction we're on
    // ------------------------------------------------------------------------


    // shifter control signals
    logic ShiftLeft_En;
    logic ShiftRightLogical_En;
    logic ShiftRightArith_En;
    assign ShiftLeft_En = IsSLLI | IsSLL;
    assign ShiftRightLogical_En = IsSRLI | IsSRL;
    assign ShiftRightArith_En = IsSRAI | IsSRA;
    assign Result_Shifter_En = IsSLLI | IsSLL | IsSRLI | IsSRL | IsSRAI | IsSRA; // any shift instr
    assign ShamtSrc = IsSLL | IsSRL | IsSRA; // use reg/imm for Shamt: 0=Instr, 1=RD2
    // package results nicely
    assign ShifterCtrl = {ShiftRightArith_En, ShiftRightLogical_En, ShiftLeft_En};
    
    
    // alu control signals
    logic Alu_And_En;
    logic Alu_Or_En;
    logic Alu_Xor_En;
    logic Alu_Add_En;
    logic InvB;
    logic CarryIn;
    assign AluSrcBSrc =                                      // choose immediate or register for SrcB
        IsLoad | IsStore |                                   // load/store
        IsADDI | IsSLTI | IsSLTIU | IsXORI | IsORI | IsANDI; // imm instr
    assign Alu_And_En = IsAND | IsANDI;
    assign Alu_Or_En = IsOR | IsORI;
    assign Alu_Xor_En = IsXOR | IsXORI;
    assign InvB = IsSUB |                     // invert B for subtraction, 
        IsSLT | IsSLTI | IsSLTU | IsSLTIU |   // SLT, 
        IsBType;                              // and branches. 
    assign CarryIn = IsSUB | // same as InvB
        IsSLT | IsSLTI | IsSLTU | IsSLTIU | 
        IsBType;
    assign Alu_Add_En = IsBType |             // enable Adder for Branches,
        IsSLT | IsSLTI | IsSLTU | IsSLTIU |   // SLT, 
        IsADD | IsADDI | IsSUB |              // arithmetic, 
        IsLoad | IsStore;                     // load/store
    // package control signals nicely
    assign AluCtrl[5:0] = {CarryIn, InvB, Alu_Add_En, Alu_Xor_En, Alu_Or_En, Alu_And_En};

    
    // Result control signals
    logic Result_PCPlus4_En;
    logic Result_PCTarget_En;
    logic Result_ImmExt_En;
    logic Result_ReadData_En;
    logic Result_Alu_En;
    logic Result_SLT_En;
    logic Result_SLTU_En;
    logic Result_Shifter_En;
    assign Result_Alu_En =                    // write ALU to Result for:
        IsADDI | IsANDI | IsORI | IsXORI |    // imm arithmetic, logic
        IsADD | IsSUB | IsAND | IsOR | IsXOR; // reg arithmetic, logic
    assign Result_SLT_En = IsSLT | IsSLTI;
    assign Result_SLTU_En = IsSLTU | IsSLTIU;
    assign Result_ReadData_En = IsLoad;        // Loads put data -> reg
    assign Result_PCPlus4_En = IsJAL | IsJALR; // link = put PCP+4 -> reg
    assign Result_PCTarget_En = IsAUIPC;       // put PC+Imm -> reg
    assign Result_ImmExt_En = IsLUI;           // put imm -> reg
    // package it nicely
    assign ResultSrc = { Result_Shifter_En, Result_SLTU_En, Result_SLT_En, Result_Alu_En, Result_ReadData_En, Result_ImmExt_En, Result_PCTarget_En, Result_PCPlus4_En};
    
    
    // PC_unit control signals
    assign PCTargetBaseSrc = IsJALR;           // choose reg as target base
    assign PCNextSrc = // choose PCTarget instead of PC+4
        IsJAL | IsJALR | // jump
        (Zero & IsBEQ) | // branch equal
        (~Zero & IsBNE) | // branch not equal
        (LessThan & IsBLT) | // branch less than
        (~LessThan & IsBGE) | // branch BGE
        (LessThanU & IsBLTU) | // BLTU
        (~LessThanU & IsBGEU); // BGEU
    
    
    // ImmExt control signals
    assign ImmExtSrc[0] = IsLoad | IsIType | IsJALR;
    assign ImmExtSrc[1] = IsStore;
    assign ImmExtSrc[2] = IsBType;
    assign ImmExtSrc[3] = IsJAL;
    assign ImmExtSrc[4] = IsLUI | IsAUIPC;
    
    
    // regfile control signals
    assign WE3 = 
        IsAUIPC | IsLUI | // reg <- imm or PC+imm
        IsJAL | IsJALR | // reg <- return addr = link
        IsRType | // reg type
        IsIType | // imm type
        IsLoad; // reg <- mem output
    
    
    // dmem control signals
    assign MemWrite = IsStore;

endmodule
