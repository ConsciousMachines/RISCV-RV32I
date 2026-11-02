

module dmem #(
    parameter string HEXFILE = "test.hex"
)(
    input  logic        clk,
    input  logic [2:0]  funct3,   // instr[14:12]: access size + signedness
    input  logic [31:0] A,
    input  logic [31:0] WD,
    input  logic        WE,
    output logic [31:0] RD,
    output logic [31:0] tohost
);

    localparam BASE   = 32'h8000_0000;
    localparam TOHOST = 32'h8000_0040;

    logic [31:0] RAM [0:4095];

    string hexfile;
    initial begin
        // +hex=<path> on the simulator command line overrides the parameter
        if (!$value$plusargs("hex=%s", hexfile)) hexfile = HEXFILE;
        $readmemh(hexfile, RAM);
        tohost = 32'h0;
    end


    // --- load
    logic [31:0] word;
    logic [31:0] addr_0;
    logic [11:0] addr;
    assign addr_0 = A - BASE;
    assign addr = addr_0[13:2];
    assign word = RAM[addr];
    always_comb begin // this and all the other truth tables came out of my excel spreadsheet
        casez ({funct3, A[1:0]})
            // lb
            5'b000_00:  RD = {{24{word[7]}},  word[7:0]};    
            5'b000_01:  RD = {{24{word[15]}}, word[15:8]};  
            5'b000_10:  RD = {{24{word[23]}}, word[23:16]}; 
            5'b000_11:  RD = {{24{word[31]}}, word[31:24]}; 
            // lh
            5'b001_0?:  RD = {{16{word[15]}}, word[15:0]};    
            5'b001_1?:  RD = {{16{word[31]}}, word[31:16]};   
            // lbu
            5'b100_00:  RD = {24'b0, word[7:0]};    
            5'b100_01:  RD = {24'b0, word[15:8]};  
            5'b100_10:  RD = {24'b0, word[23:16]}; 
            5'b100_11:  RD = {24'b0, word[31:24]}; 
            // lhu
            5'b101_0?:  RD = {16'b0, word[15:0]};    
            5'b101_1?:  RD = {16'b0, word[31:16]};   
            // lw
            default: RD = word;                                
        endcase
    end


    // --- store
    logic [31:0] write_data;
    always_comb begin 
        casez ({funct3[1:0], A[1:0]})
            // sb
            4'b00_00:  write_data = {24'b0,  WD[7:0]};    
            4'b00_01:  write_data = {16'b0,  WD[7:0], 8'b0};    
            4'b00_10:  write_data = {8'b0,   WD[7:0], 16'b0};    
            4'b00_11:  write_data = {WD[7:0], 24'b0};    
            // sh
            4'b01_0?:  write_data = {16'b0,  WD[15:0]};   
            4'b01_1?:  write_data = {WD[15:0], 16'b0};  
            // sw
            default: write_data = WD; // 4'b10_??: 
        endcase
    end

    logic [3:0] store_en; // which out of 4 bytes should we store in?
    always_comb begin 
        casez ({funct3[1:0], A[1:0]})
            // sb
            4'b00_00:  store_en = 4'b0001;
            4'b00_01:  store_en = 4'b0010;
            4'b00_10:  store_en = 4'b0100;
            4'b00_11:  store_en = 4'b1000;
            // sh
            4'b01_0?:  store_en = 4'b0011;
            4'b01_1?:  store_en = 4'b1100;
            // sw
            default: store_en = 4'b1111; // 4'b10_??:
        endcase
    end

    always_ff @(posedge clk) begin
        if (WE) begin
            if (A == TOHOST)
                tohost <= WD;
            else begin
                // write each of 4 bytes, if we should:
                if (store_en[0])
                    RAM[addr][7:0] <= write_data[7:0];
                if (store_en[1])
                    RAM[addr][15:8] <= write_data[15:8];
                if (store_en[2])
                    RAM[addr][23:16] <= write_data[23:16];
                if (store_en[3])
                    RAM[addr][31:24] <= write_data[31:24];
            end
        end
    end

    logic test_pass;
    assign test_pass = (tohost == 32'h1);

endmodule
