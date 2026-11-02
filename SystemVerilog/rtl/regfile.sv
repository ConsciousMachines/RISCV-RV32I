
module regfile (
    input  logic        clk,
    input  logic [4:0]  A1,
    input  logic [4:0]  A2,
    input  logic [4:0]  A3,
    input  logic [31:0] WD3,
    input  logic        WE3,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    logic [31:0] regs [0:31];


    // ABI-named aliases for waveform viewing
    logic [31:0] zero, ra, sp, gp, tp;
    logic [31:0] t0, t1, t2;
    logic [31:0] s0, s1;
    logic [31:0] a0, a1, a2, a3, a4, a5, a6, a7;
    logic [31:0] s2, s3, s4, s5, s6, s7, s8, s9, s10, s11;
    logic [31:0] t3, t4, t5, t6;

    assign zero = regs[0];  assign ra = regs[1];   assign sp = regs[2];   assign gp = regs[3];
    assign tp   = regs[4];  assign t0 = regs[5];   assign t1 = regs[6];   assign t2 = regs[7];
    assign s0   = regs[8];  assign s1 = regs[9];
    assign a0   = regs[10]; assign a1 = regs[11];  assign a2 = regs[12];  assign a3 = regs[13];
    assign a4   = regs[14]; assign a5 = regs[15];  assign a6 = regs[16];  assign a7 = regs[17];
    assign s2   = regs[18]; assign s3 = regs[19];  assign s4 = regs[20];  assign s5 = regs[21];
    assign s6   = regs[22]; assign s7 = regs[23];  assign s8 = regs[24];  assign s9 = regs[25];
    assign s10  = regs[26]; assign s11 = regs[27];
    assign t3   = regs[28]; assign t4 = regs[29];  assign t5 = regs[30];  assign t6 = regs[31];


    // remember x0 is zero
    assign RD1 = (A1 == 5'b0) ? 32'b0 : regs[A1];
    assign RD2 = (A2 == 5'b0) ? 32'b0 : regs[A2];

    always_ff @(posedge clk) begin
        if (WE3)
            regs[A3] <= WD3;
    end

endmodule
