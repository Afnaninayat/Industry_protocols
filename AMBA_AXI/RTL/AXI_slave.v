
module AXI_slave #(
parameter ADDRESS = 32,
parameter DATA_WIDTH = 32
)(
input wire ACLK,
input wire ARESETN,

input wire [ADDRESS-1:0] ARADDR,
input wire ARVALID,
input wire RREADY,

input wire [ADDRESS-1:0] AWADDR,
input wire AWVALID,

input wire [DATA_WIDTH-1:0] WDATA,
input wire [3:0] WSTRB,
input wire WVALID,

input wire BREADY,

output reg ARREADY,
output reg [DATA_WIDTH-1:0] RDATA,
output reg [1:0] RRESP,
output reg RVALID,

output reg AWREADY,
output reg WREADY,

output reg [1:0] BRESP,
output reg BVALID
);

reg [DATA_WIDTH-1:0] REG0;
reg [DATA_WIDTH-1:0] REG1;
reg [DATA_WIDTH-1:0] REG2;
reg [DATA_WIDTH-1:0] REG3;

always @(posedge ACLK or negedge ARESETN) begin

if (!ARESETN) begin

ARREADY <= 0;
RDATA <= 0;
RRESP <= 0;
RVALID <= 0;

AWREADY <= 0;
WREADY <= 0;

BRESP <= 0;
BVALID <= 0;

REG0 <= 0;
REG1 <= 0;
REG2 <= 0;
REG3 <= 0;

end

else begin

ARREADY <= 1;
AWREADY <= 1;
WREADY <= 1;

if (ARVALID && ARREADY) begin

case (ARADDR)

32'h00000000: RDATA <= REG0;
32'h00000004: RDATA <= REG1;
32'h00000008: RDATA <= REG2;
32'h0000000C: RDATA <= REG3;
default: RDATA <= 32'h00000000;

endcase

RRESP <= 2'b00;
RVALID <= 1;

end

if (RVALID && RREADY) begin
RVALID <= 0;
end

if (AWVALID && AWREADY && WVALID && WREADY) begin

case (AWADDR)

32'h00000000: begin
if (WSTRB[0]) REG0[7:0] <= WDATA[7:0];
if (WSTRB[1]) REG0[15:8] <= WDATA[15:8];
if (WSTRB[2]) REG0[23:16] <= WDATA[23:16];
if (WSTRB[3]) REG0[31:24] <= WDATA[31:24];
end

32'h00000004: begin
if (WSTRB[0]) REG1[7:0] <= WDATA[7:0];
if (WSTRB[1]) REG1[15:8] <= WDATA[15:8];
if (WSTRB[2]) REG1[23:16] <= WDATA[23:16];
if (WSTRB[3]) REG1[31:24] <= WDATA[31:24];
end

32'h00000008: begin
if (WSTRB[0]) REG2[7:0] <= WDATA[7:0];
if (WSTRB[1]) REG2[15:8] <= WDATA[15:8];
if (WSTRB[2]) REG2[23:16] <= WDATA[23:16];
if (WSTRB[3]) REG2[31:24] <= WDATA[31:24];
end

32'h0000000C: begin
if (WSTRB[0]) REG3[7:0] <= WDATA[7:0];
if (WSTRB[1]) REG3[15:8] <= WDATA[15:8];
if (WSTRB[2]) REG3[23:16] <= WDATA[23:16];
if (WSTRB[3]) REG3[31:24] <= WDATA[31:24];
end

endcase

BRESP <= 2'b00;
BVALID <= 1;

end

if (BVALID && BREADY) begin
BVALID <= 0;
end

end

end

endmodule

