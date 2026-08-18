`define IDLE    2'b00
`define BUSY    2'b01
`define NONSEQ  2'b10
`define SEQ     2'b11

module AHB_Master (
    // Global Signals
    input HCLK,
    input HRESETn,
    // Processor signals (we will act as the Processor in the testbench)
    input [31:0] PADDR,
    input [31:0] PWDATA,
    input PWRITE,
    input [2:0] PSIZE,
    input [1:0] PTRANS,
    input [2:0] PBURST,
    // Transfer response (from mux)
    input HREADY, // to indicate the completeness of the transfer
    input HRESP,
    // Data
    input [31:0] HRDATA, // from slave
    // outputs
    output reg [31:0] HADDR, // note that the Most significant two bits are used to select which slave we will access
    output reg [31:0] HWDATA,
    output reg HWRITE,
    output reg [2:0] HSIZE,
    output reg [1:0] HTRANS,
    output reg [2:0] HBURST,
    output reg PDONE // just a flag to indicate the transfer is done
);

    // next state logic, cuurent state
    //reg [1:0] cs, ns;

    reg [31:0] HWDATA_reg; // to store the value of HWDATA_reg in case of wait state transfers

    reg [1:0] cs, ns; // FIX: state_t removed because this is Verilog

    // state memory
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            cs <= `IDLE; // FIX: use Verilog macro instead of enum
        else 
            cs <= ns;
    end

    // next state logic
    always @(*) begin
        ns = cs; // FIX: default assignment

        case (cs)
            `IDLE: begin // FIX: use Verilog macro
                if (PTRANS == 2'b10) // Non-sequential transfer
                    ns = `NONSEQ; // FIX: use Verilog macro
                else
                    ns = `IDLE; // FIX: use Verilog macro
            end

            `BUSY: begin // FIX: use Verilog macro
                if (PTRANS == 2'b11)
                    ns = `SEQ; // FIX: use Verilog macro
                else if (PTRANS == 2'b10) 
                    ns = `NONSEQ; // FIX: use Verilog macro
                else if (PTRANS == 2'b00)
                    ns = `IDLE; // FIX: use Verilog macro
                else
                    ns = `BUSY; // FIX: use Verilog macro
            end

            `NONSEQ: begin // FIX: use Verilog macro
                if (PTRANS == 2'b11)
                    ns = `SEQ; // FIX: use Verilog macro
                else if (PTRANS == 2'b00)
                    ns = `IDLE; // FIX: use Verilog macro
                else if (PTRANS == 2'b10 && PBURST == 3'b000) // to enable multiple Non-sequential transfer with single burst every cycle
                    ns = `NONSEQ; // FIX: use Verilog macro
                else 
                    ns = `SEQ; // FIX: use Verilog macro
            end

            `SEQ: begin // FIX: use Verilog macro
                if (PTRANS == 2'b00)
                    ns = `IDLE; // FIX: use Verilog macro
                else if (PTRANS == 2'b10)
                    ns = `NONSEQ; // FIX: use Verilog macro
                else
                    ns = `SEQ; // FIX: use Verilog macro
            end

            default: begin
                ns = `IDLE; // FIX: added default state
            end
        endcase
    end

    // output logic
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HADDR <= 32'b0;
            HWDATA_reg <= 32'b0;
            HWRITE <= 1'b0;
            HSIZE <= 3'b000; // 8-bit transfer
            HTRANS <= 2'b00; // IDLE state
            HBURST <= 3'b000; // Single transfer
        end 
        else begin
            if (cs == `IDLE) begin // FIX: use Verilog macro
                HADDR <= 32'b0; 
                HWDATA_reg <= 32'b0; 
                HWRITE <= 1'b0; 
                HSIZE <= 3'b000; 
                HTRANS <= 2'b00;  
            end 

            else if (cs == `BUSY) begin // FIX: use Verilog macro
                HADDR <= PADDR; 
                HWDATA_reg <= PWDATA; 
                HWRITE <= PWRITE; 
                HSIZE <= PSIZE; 
                HTRANS <= PTRANS; 
                HBURST <= PBURST; 
            end 

            else if (cs == `NONSEQ) begin // FIX: use Verilog macro
                HADDR <= PADDR; 
                HWDATA_reg <= PWDATA; 
                HWRITE <= PWRITE; 
                HSIZE <= PSIZE; 
                HTRANS <= PTRANS; 
                HBURST <= PBURST; 
            end

            else if (cs == `SEQ) begin // FIX: use Verilog macro
                if (PBURST == 3'b001 && !PSIZE) begin // INCREMENTAL burst, size is 8 bits so we will incerement address by 1
                    HADDR <= HADDR + 1 ; 
                    HWDATA_reg <= {24'h000000, PWDATA[7:0]}; 
                    HWRITE <= PWRITE; 
                    HSIZE <= PSIZE; 
                    HTRANS <= PTRANS; 
                    HBURST <= PBURST; 
                end

                else if (PBURST == 3'b001 && PSIZE == 3'b001) begin // INCREMENTAL burst, size is 16 bits so we will incerement address by 2
                    HADDR <= HADDR + 2 ; 
                    HWDATA_reg <= {16'h0000, PWDATA[15:0]}; 
                    HWRITE <= PWRITE; 
                    HSIZE <= PSIZE; 
                    HTRANS <= PTRANS; 
                    HBURST <= PBURST; 
                end

                else if (PBURST == 3'b001 && PSIZE == 3'b010) begin // INCREMENTAL burst, size is 32 bits so we will incerement address by 4
                    HADDR <= HADDR + 4 ; 
                    HWDATA_reg <= PWDATA; 
                    HWRITE <= PWRITE; 
                    HSIZE <= PSIZE; 
                    HTRANS <= PTRANS; 
                    HBURST <= PBURST; 
                end

                else if (!PBURST) begin // SINGLE transfer
                    HADDR <= PADDR; 
                    HWDATA_reg <= PWDATA; 
                    HWRITE <= PWRITE; 
                    HSIZE <= PSIZE; 
                    HTRANS <= PTRANS; 
                    HBURST <= PBURST; 
                end
            end
        end
    end

    // special always block to respect the data phase as data should come after address phase by on clock
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            HWDATA <= 32'b0; // FIX: reset HWDATA
        else if (HREADY)
            HWDATA <= HWDATA_reg;
    end

    // special always block for flag done
    always @(*) begin
        if ((cs == `NONSEQ || cs == `SEQ) && ns == `IDLE) begin // FIX: use Verilog macros
            PDONE = 1'b1; // transfer is done
        end 
        else begin
            PDONE = 1'b0; // transfer is not done
        end
    end

endmodule
