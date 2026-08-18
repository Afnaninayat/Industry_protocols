module AHB_Slave_2 #(
    parameter MEM_WIDTH = 8,
    parameter MEM_DEPTH = 64
)(
    input HCLK,
    input HRESETn,

    // Input from master
    input [31:0] HADDR,
    input [31:0] HWDATA,

    // Input from decoder
    input [1:0] HSELx_slaves,

    // Control signals
    input HWRITE,
    input [2:0] HSIZE,
    input [1:0] HTRANS,
    input [2:0] HBURST,
    input HREADY,

    // Outputs to MUX
    output reg HREADYOUT,
    output reg HRESP,
    output reg [31:0] HRDATA
);

    // ============================================================
    // FSM STATE DEFINITIONS
    // FIX: Removed typedef enum because this is Verilog, not SV.
    // ============================================================

    parameter IDLE  = 2'b00;
    parameter WRITE = 2'b01;
    parameter READ  = 2'b10;

    reg [1:0] curr_state;
    reg [1:0] next_state;


    // ============================================================
    // MEMORY
    // ============================================================

    reg [MEM_WIDTH-1:0] memory_2 [0:MEM_DEPTH-1];


    // ============================================================
    // INTERNAL REGISTERS
    // ============================================================

    reg [31:0] HADDR_reg;
    reg        HWRITE_reg;
    reg [2:0]  HSIZE_reg;
    reg [1:0]  HTRANS_reg;
    reg [2:0]  HBURST_reg;


    // ============================================================
    // INTERNAL ADDRESS SIGNALS
    // ============================================================

    reg [29:0] HADDR_Half;
    reg [29:0] HADDR_Full_1;
    reg [29:0] HADDR_Full_2;
    reg [29:0] HADDR_Full_3;


    // ============================================================
    // FSM SEQUENTIAL LOGIC
    // FIX: always_ff -> always
    // ============================================================

    always @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn)
            curr_state <= IDLE;

        else
            curr_state <= next_state;

    end


    // ============================================================
    // FSM COMBINATIONAL LOGIC
    // FIX: always_comb -> always @(*)
    // FIX: Default next_state prevents latch.
    // ============================================================

    always @(*) begin

        next_state = curr_state;

        case (curr_state)

            IDLE: begin

                if (HREADY &&
                    HSELx_slaves == 2'b01 &&
                    (HTRANS == 2'b10 || HTRANS == 2'b11)) begin

                    if (HWRITE)
                        next_state = WRITE;
                    else
                        next_state = READ;

                end
                else begin
                    next_state = IDLE;
                end

            end


            WRITE: begin

                if (!(HTRANS == 2'b10 || HTRANS == 2'b11))
                    next_state = IDLE;

                else if (!HWRITE)
                    next_state = READ;

                else
                    next_state = WRITE;

            end


            READ: begin

                if (!(HTRANS == 2'b10 || HTRANS == 2'b11))
                    next_state = IDLE;

                else if (HWRITE)
                    next_state = WRITE;

                else
                    next_state = READ;

            end


            default: begin
                next_state = IDLE;
            end

        endcase

    end


    // ============================================================
    // OUTPUT / MEMORY LOGIC
    // FIX: always_ff -> always
    // ============================================================

    always @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn) begin

            HRDATA    <= 32'h00000000;
            HREADYOUT <= 1'b1;
            HRESP     <= 1'b0;

        end

        else begin

            // ----------------------------------------------------
            // READ OPERATION
            // ----------------------------------------------------

            if (next_state == READ) begin

                if (HBURST == 3'b000 ||
                    HBURST == 3'b001) begin

                    case (HSIZE)

                        // ----------------------------------------
                        // 8-bit READ
                        // ----------------------------------------

                        3'b000: begin

                            if (HADDR[29:0] < MEM_DEPTH)
                                HRDATA <= {
                                    24'h000000,
                                    memory_2[HADDR[29:0]]
                                };

                            else
                                HRDATA <= 32'h00000000;

                        end


                        // ----------------------------------------
                        // 16-bit READ
                        // ----------------------------------------

                        3'b001: begin

                            if ((HADDR[29:0] < MEM_DEPTH) &&
                                (HADDR_Half < MEM_DEPTH)) begin

                                HRDATA <= {
                                    16'h0000,
                                    memory_2[HADDR_Half],
                                    memory_2[HADDR[29:0]]
                                };

                            end

                            else begin
                                HRDATA <= 32'h00000000;
                            end

                        end


                        // ----------------------------------------
                        // 32-bit READ
                        // ----------------------------------------

                        3'b010: begin

                            if ((HADDR[29:0] < MEM_DEPTH) &&
                                (HADDR_Full_1 < MEM_DEPTH) &&
                                (HADDR_Full_2 < MEM_DEPTH) &&
                                (HADDR_Full_3 < MEM_DEPTH)) begin

                                HRDATA <= {
                                    memory_2[HADDR_Full_3],
                                    memory_2[HADDR_Full_2],
                                    memory_2[HADDR_Full_1],
                                    memory_2[HADDR[29:0]]
                                };

                            end

                            else begin
                                HRDATA <= 32'h00000000;
                            end

                        end


                        default: begin
                            HRDATA <= 32'h00000000;
                        end

                    endcase

                end

            end


            // ----------------------------------------------------
            // WRITE OPERATION
            // ----------------------------------------------------

            else if (curr_state == WRITE) begin

                if (HBURST_reg == 3'b000 ||
                    HBURST_reg == 3'b001) begin

                    case (HSIZE_reg)

                        // ----------------------------------------
                        // 8-bit WRITE
                        // ----------------------------------------

                        3'b000: begin

                            if (HADDR_reg[29:0] < MEM_DEPTH)
                                memory_2[HADDR_reg[29:0]]
                                    <= HWDATA[7:0];

                        end


                        // ----------------------------------------
                        // 16-bit WRITE
                        // ----------------------------------------

                        3'b001: begin

                            if ((HADDR_reg[29:0] < MEM_DEPTH) &&
                                (HADDR_Half < MEM_DEPTH)) begin

                                memory_2[HADDR_reg[29:0]]
                                    <= HWDATA[7:0];

                                memory_2[HADDR_Half]
                                    <= HWDATA[15:8];

                            end

                        end


                        // ----------------------------------------
                        // 32-bit WRITE
                        // ----------------------------------------

                        3'b010: begin

                            if ((HADDR_reg[29:0] < MEM_DEPTH) &&
                                (HADDR_Full_1 < MEM_DEPTH) &&
                                (HADDR_Full_2 < MEM_DEPTH) &&
                                (HADDR_Full_3 < MEM_DEPTH)) begin

                                memory_2[HADDR_reg[29:0]]
                                    <= HWDATA[7:0];

                                memory_2[HADDR_Full_1]
                                    <= HWDATA[15:8];

                                memory_2[HADDR_Full_2]
                                    <= HWDATA[23:16];

                                memory_2[HADDR_Full_3]
                                    <= HWDATA[31:24];

                            end

                        end


                        default: begin
                            // No operation
                        end

                    endcase

                end

            end

        end

    end


    // ============================================================
    // ADDRESS PHASE CAPTURE
    //
    // FIX:
    // always_ff -> always
    //
    // This stores address/control signals so that they remain
    // stable during the data phase / wait states.
    // ============================================================

    always @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn) begin

            HADDR_reg  <= 32'h00000000;
            HWRITE_reg <= 1'b0;
            HSIZE_reg  <= 3'b000;
            HTRANS_reg <= 2'b00;
            HBURST_reg <= 3'b000;

        end

        else if (HREADY && HSELx_slaves == 2'b01) begin

            HADDR_reg  <= HADDR;
            HWRITE_reg <= HWRITE;
            HSIZE_reg  <= HSIZE;
            HTRANS_reg <= HTRANS;
            HBURST_reg <= HBURST;

        end

    end


    // ============================================================
    // ADDRESS MANAGEMENT
    //
    // FIX:
    // Original code used 30-bit address expressions but declared
    // signals as 32-bit. Using [29:0] keeps the memory indexing
    // consistent.
    //
    // FIX:
    // Added default assignments to avoid inferred latches.
    // ============================================================

    always @(*) begin

        // Default values
        HADDR_Half   = HADDR_reg[29:0] + 30'd1;
        HADDR_Full_1 = HADDR_reg[29:0] + 30'd1;
        HADDR_Full_2 = HADDR_reg[29:0] + 30'd2;
        HADDR_Full_3 = HADDR_reg[29:0] + 30'd3;

        // For READ operation use current address
        if (!HWRITE) begin

            HADDR_Half   = HADDR[29:0] + 30'd1;
            HADDR_Full_1 = HADDR[29:0] + 30'd1;
            HADDR_Full_2 = HADDR[29:0] + 30'd2;
            HADDR_Full_3 = HADDR[29:0] + 30'd3;

        end

    end


    // ============================================================
    // DEFAULT RESPONSE
    //
    // FIX:
    // Keep slave ready and response OKAY.
    // ============================================================

    always @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn) begin
            HREADYOUT <= 1'b1;
            HRESP     <= 1'b0;
        end

        else begin
            HREADYOUT <= 1'b1;
            HRESP     <= 1'b0;
        end

    end

endmodule
