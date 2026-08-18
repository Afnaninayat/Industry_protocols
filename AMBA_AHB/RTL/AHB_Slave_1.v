// we chose AHB slave 1 to be a memory slave 
module AHB_Slave_1 #(
    parameter MEM_WIDTH = 8,
    parameter MEM_DEPTH = 1024
) (
    // Global Signals
    input HCLK,
    input HRESETn,
    // input from master
    input [31:0] HADDR,
    input [31:0] HWDATA,
    // input from decoder
    input [1:0] HSELx_slaves,
    // control signals
    input HWRITE,
    input [2:0] HSIZE,
    input [1:0] HTRANS,
    input [2:0] HBURST,
    input HREADY,
    // output to MUX
    output reg HREADYOUT,
    output reg HRESP,
    output reg [31:0] HRDATA
);

    // we made this salve as a memory to test read and write operations
    reg [MEM_WIDTH-1:0] memory [0:MEM_DEPTH-1];

    // internal signlas
    reg [31:0] HADDR_Half;
    reg [31:0] HADDR_Full_1;
    reg [31:0] HADDR_Full_2;
    reg [31:0] HADDR_Full_3;

    // storing all control signals to use them in write states as control signals are sent first then data (address phase & data phase)
    reg [31:0] HADDR_reg;
    reg HWRITE_reg;
    reg [2:0] HSIZE_reg;
    reg [1:0] HTRANS_reg;
    reg [2:0] HBURST_reg;


    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HREADYOUT <= 1'b1;
            HRESP <= 1'b0;
            HRDATA <= 32'h00000000;
        end

        else if (HSELx_slaves == 2'b00 && HREADY) begin

            // Write operation for both single and incermental burst transfers (HBURST = 0 or HBURST = 1)
            if (HWRITE_reg && (HTRANS_reg == 2'b10 || HTRANS_reg == 2'b11)) begin

                // 8 bits transfer 
                if ((HBURST_reg == 3'b000 || HBURST_reg == 3'b001) &&
                    HSIZE_reg == 3'b000) begin

                    if (HADDR_reg[29:0] < MEM_DEPTH)
                        memory[HADDR_reg[29:0]] <= HWDATA[7:0];

                end

                // 16 bits transfer 
                else if ((HBURST_reg == 3'b000 || HBURST_reg == 3'b001) &&
                         HSIZE_reg == 3'b001) begin

                    if ((HADDR_reg[29:0] < MEM_DEPTH) &&
                        (HADDR_Half < MEM_DEPTH)) begin

                        memory[HADDR_reg[29:0]] <= HWDATA[7:0];
                        memory[HADDR_Half] <= HWDATA[15:8];

                    end

                end

                // 32 bits transfer 
                else if ((HBURST_reg == 3'b000 || HBURST_reg == 3'b001) &&
                         HSIZE_reg == 3'b010) begin

                    if ((HADDR_reg[29:0] < MEM_DEPTH) &&
                        (HADDR_Full_1 < MEM_DEPTH) &&
                        (HADDR_Full_2 < MEM_DEPTH) &&
                        (HADDR_Full_3 < MEM_DEPTH)) begin

                        memory[HADDR_reg[29:0]] <= HWDATA[7:0];
                        memory[HADDR_Full_1] <= HWDATA[15:8];
                        memory[HADDR_Full_2] <= HWDATA[23:16];
                        memory[HADDR_Full_3] <= HWDATA[31:24];

                    end

                end

            end

            // Read operation for both single and incermental burst transfers (HBURST = 0 or HBURST = 1) 
            else if (!HWRITE && (HTRANS == 2'b10 || HTRANS == 2'b11)) begin

                // 8 bits transfer 
                if ((HBURST == 3'b000 || HBURST == 3'b001) &&
                    HSIZE == 3'b000) begin

                    if (HADDR[29:0] < MEM_DEPTH)
                        HRDATA <= {24'h000000, memory[HADDR[29:0]]};

                end

                // 16 bits transfer 
                else if ((HBURST == 3'b000 || HBURST == 3'b001) &&
                         HSIZE == 3'b001) begin

                    if ((HADDR[29:0] < MEM_DEPTH) &&
                        (HADDR_Half < MEM_DEPTH)) begin

                        HRDATA <= {
                            16'h0000,
                            memory[HADDR_Half],
                            memory[HADDR[29:0]]
                        };

                    end

                end

                // 32 bits transfer 
                else if ((HBURST == 3'b000 || HBURST == 3'b001) &&
                         HSIZE == 3'b010) begin

                    if ((HADDR[29:0] < MEM_DEPTH) &&
                        (HADDR_Full_1 < MEM_DEPTH) &&
                        (HADDR_Full_2 < MEM_DEPTH) &&
                        (HADDR_Full_3 < MEM_DEPTH)) begin

                        HRDATA <= {
                            memory[HADDR_Full_3],
                            memory[HADDR_Full_2],
                            memory[HADDR_Full_1],
                            memory[HADDR[29:0]]
                        };

                    end

                end

            end

        end
    end


    // always block for address to respect address phase and data phase and to enable pipelining in the address
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HADDR_reg <= 32'b0;
            HWRITE_reg <= 1'b0;
            HSIZE_reg <= 3'b000;
            HBURST_reg <= 3'b000;
            HTRANS_reg <= 2'b00;
        end
        else if (HREADY) begin 
            HADDR_reg <= HADDR;
            HWRITE_reg <= HWRITE;
            HSIZE_reg <= HSIZE;
            HBURST_reg <= HBURST;
            HTRANS_reg <= HTRANS;
        end
    end


    // always block for address managing to respect wait states
    always @(*) begin

        HADDR_Half = 32'b0;
        HADDR_Full_1 = 32'b0;
        HADDR_Full_2 = 32'b0;
        HADDR_Full_3 = 32'b0;

        if (HREADY) begin

            // write transfer
            if (HWRITE) begin
                HADDR_Half = HADDR_reg[29:0] + 1;
                HADDR_Full_1 = HADDR_reg[29:0] + 1;
                HADDR_Full_2 = HADDR_reg[29:0] + 2;
                HADDR_Full_3 = HADDR_reg[29:0] + 3;
            end

            // read transfer
            else begin
                HADDR_Half = HADDR[29:0] + 1;
                HADDR_Full_1 = HADDR[29:0] + 1;
                HADDR_Full_2 = HADDR[29:0] + 2;
                HADDR_Full_3 = HADDR[29:0] + 3;
            end

        end

    end

endmodule
