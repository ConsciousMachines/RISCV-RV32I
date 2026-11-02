
module riscv (
    input  logic        clk,
    input  logic        rst
);


    // control unit 
    // PC_unit control
    logic PCNextSrc;
    logic PCTargetBaseSrc;
    // ImmExt control
    logic [4:0] ImmExtSrc;
    // regfile control
    logic WE3;
    // dmem control
    logic MemWrite;
    // alu control
    logic       AluSrcBSrc; // SrcB = Rd2 or ImmExt ?
    logic [5:0] AluCtrl;
    // shifter control
    logic       ShamtSrc;
    logic [2:0] ShifterCtrl;
    // Result control
    logic [7:0] ResultSrc;
    control_unit control_unit_inst (
        // input
        .Instr (Instr),
        .Zero (Zero),
        .LessThan (LessThan),
        .LessThanU (LessThanU),
        // output
        // PC_unit control
        .PCNextSrc (PCNextSrc),
        .PCTargetBaseSrc (PCTargetBaseSrc),
        // ImmExt control
        .ImmExtSrc (ImmExtSrc),
        // regfile control
        .WE3 (WE3),
        // dmem control
        .MemWrite (MemWrite),
        // alu control
        .AluCtrl (AluCtrl),
        .AluSrcBSrc (AluSrcBSrc),
        // shifter control
        .ShifterCtrl (ShifterCtrl),
        .ShamtSrc(ShamtSrc),
        // result control
        .ResultSrc (ResultSrc)
    );


    // PC_unit data 
    logic [31:0] PC, PCPlus4, PCTarget;
    PC_unit pc_unit_inst (
        .clk              (clk),
        .rst              (rst),
        // input control
        .PCNextSrc        (PCNextSrc),
        .PCTargetBaseSrc  (PCTargetBaseSrc),
        // input data
        .RD1              (RD1),
        .ImmExt           (ImmExt),
        // output
        .PC               (PC),
        .PCPlus4          (PCPlus4),
        .PCTarget         (PCTarget)
    );




    // --- do first:
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/simple.hex";


    // --- PASSED:
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/add.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/addi.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/and.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/andi.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/auipc.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/beq.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/bge.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/bgeu.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/blt.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/bltu.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/bne.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/jal.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/jalr.hex";
    // lb
    // lbu
    // ld_st
    // lh
    // lhu
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/lui.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/lw.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/or.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/ori.hex";
    // sb
    // sh
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/sll.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/slli.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/slt.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/slti.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/sltiu.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/sltu.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/sra.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/srai.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/srl.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/srli.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/st_ld.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/sub.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/sw.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/xor.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/xori.hex";

    // --- FAILED - fixed with new dmem!!!
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/lb.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/lbu.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/lh.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/lhu.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/sb.hex";
    // localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/sh.hex";
    localparam string HEXFILE = "/home/chad/a-finished/0004_install_tests/riscv-tests/build/ld_st.hex";


    // open surfer on windows:
    // /mnt/c/Users/cudac/Downloads/surfer_win/surfer.exe "$(wslpath -w wave.vcd)" &


    // Instruction data
    logic [31:0] Instr;
    imem #(.HEXFILE(HEXFILE)) imem_inst (
        // input
        .addr (PC),
        // output
        .instr(Instr)
    );

    // ImmExt data
    logic [31:0] ImmExt;
    imm_ext imm_ext_inst (
        // input control
        .ImmExtSrc(ImmExtSrc),
        // input data
        .instr(Instr),
        // output
        .ImmExt(ImmExt)
    );

    // regfile data
    logic [31:0] RD1;
    logic [31:0] RD2;
    regfile regfile_inst (
        .clk(clk),
        // input control
        .WE3(WE3),
        // input data
        .A1(Instr[19:15]),
        .A2(Instr[24:20]),
        .A3(Instr[11:7]),
        .WD3(Result),
        // output
        .RD1(RD1),
        .RD2(RD2)
    );


    // dmem data
    logic [31:0] ReadData;
    logic [31:0] tohost;
    dmem #(.HEXFILE(HEXFILE)) dmem_inst (
        .clk(clk),
        // input control
        .WE(MemWrite),
        .funct3(Instr[14:12]), // instr[14:12]: access size + signedness
        // input data
        .A(AluResult),
        .WD(RD2),
        // output
        .RD(ReadData),
        .tohost(tohost)
    );

    // alu input data
    logic [31:0] AluSrcB;
    assign AluSrcB = AluSrcBSrc ? ImmExt : RD2;
    // alu output control signals
    logic Zero;
    logic Sign;
    logic LessThan;
    logic LessThanU;
    // alu output data
    logic [31:0] AluResult;
    alu alu_inst (
        // control
        .AluCtrl(AluCtrl),
        // data
        .SrcA(RD1),
        .SrcB(AluSrcB),
        // result
        .Zero(Zero),
        .Sign(Sign),
        .LessThan(LessThan),
        .LessThanU(LessThanU),
        .AluResult(AluResult)
    );



    // shifter data
    logic [4:0] Shamt;
    assign Shamt = ShamtSrc ? RD2[4:0] : Instr[24:20];
    logic [31:0] ShiftResult;
    shifter shifter_inst (
        // control
        .ShifterCtrl(ShifterCtrl),
        // data
        .SrcA(RD1),
        .Shamt(Shamt),
        // result
        .ShiftResult(ShiftResult)
    );



    // Result data
    logic [31:0] Result;
    // Result mux
    always_comb begin
        case (ResultSrc)
            8'b00000001: Result = PCPlus4;
            8'b00000010: Result = PCTarget;
            8'b00000100: Result = ImmExt;
            8'b00001000: Result = ReadData;
            8'b00010000: Result = AluResult;
            8'b00100000: Result = {31'b0, LessThan};
            8'b01000000: Result = {31'b0, LessThanU};
            8'b10000000: Result = ShiftResult;
            default:     Result = 32'b0;
        endcase
    end

endmodule
