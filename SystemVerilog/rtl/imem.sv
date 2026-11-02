
module imem #(
    parameter string HEXFILE = "test.hex"
)(
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    localparam BASE   = 32'h8000_0000;

    logic [31:0] RAM [0:4095];  // size to fit your test binaries

    // initial begin
    //     $readmemh(HEXFILE, RAM);
    // end

    string hexfile;
    initial begin
        if (!$value$plusargs("hex=%s", hexfile)) hexfile = HEXFILE;
        $readmemh(hexfile, RAM);
    end

    assign instr = RAM[(addr - BASE) >> 2];

endmodule
