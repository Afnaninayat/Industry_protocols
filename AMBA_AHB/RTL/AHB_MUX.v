module AHB_MUX (
    // inputs from slave 1
    input HRESP_Slave_1,
    input HREADYOUT_1,
    input [31:0] HRDATA_Slave_1,

    // inputs from slave 2
    input HRESP_Slave_2,
    input HREADYOUT_2,
    input [31:0] HRDATA_Slave_2,

    // inputs from decoder
    input [1:0] HSELx_Mux,

    // outputs
    output reg [31:0] HRDATA,
    output reg HREADY,
    output reg HRESP
);

    always @(*) begin

        // Default values
        HRDATA = 32'h00000000;
        HREADY = 1'b0;
        HRESP  = 1'b0;

        case (HSELx_Mux)

            // Slave 1
            2'b00: begin
                HRDATA = HRDATA_Slave_1;
                HREADY = HREADYOUT_1;
                HRESP  = HRESP_Slave_1;
            end

            // Slave 2
            2'b01: begin
                HRDATA = HRDATA_Slave_2;
                HREADY = HREADYOUT_2;
                HRESP  = HRESP_Slave_2;
            end

            // Invalid / unused slave selection
            default: begin
                HRDATA = 32'h00000000;
                HREADY = 1'b0;
                HRESP  = 1'b0;
            end

        endcase
    end

endmodule
