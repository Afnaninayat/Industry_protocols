module AXI_master #(
parameter ADDRESS = 32,
parameter DATA_WIDTH = 32
)(
input wire ACLK,
input wire ARESETN,
input wire START_READ,
input wire START_WRITE,
input wire [ADDRESS-1:0] address,
input wire [DATA_WIDTH-1:0] W_data,
input wire ARREADY,
input wire [DATA_WIDTH-1:0] RDATA,
input wire [1:0] RRESP,
input wire RVALID,
input wire AWREADY,
input wire WREADY,
input wire [1:0] BRESP,
input wire BVALID,
output reg [ADDRESS-1:0] ARADDR,
output reg ARVALID,
output reg RREADY,
output reg [ADDRESS-1:0] AWADDR,
output reg AWVALID,
output reg [DATA_WIDTH-1:0] WDATA,
output reg [3:0] WSTRB,
output reg WVALID,
output reg BREADY
);

localparam IDLE = 3'b000;
localparam RADDR_CHANNEL = 3'b001;
localparam RDATA_CHANNEL = 3'b010;
localparam WRITE_CHANNEL = 3'b011;
localparam WRESP_CHANNEL = 3'b100;

reg [2:0] state;

always @(posedge ACLK or negedge ARESETN) begin

if (!ARESETN) begin
state <= IDLE;
ARADDR <= 0;
ARVALID <= 0;
RREADY <= 0;
AWADDR <= 0;
AWVALID <= 0;
WDATA <= 0;
WSTRB <= 4'b0000;
WVALID <= 0;
BREADY <= 0;
end

else begin

case (state)

IDLE: begin

ARVALID <= 0;
RREADY <= 0;
AWVALID <= 0;
WVALID <= 0;
BREADY <= 0;

if (START_READ) begin
ARADDR <= address;
ARVALID <= 1;
state <= RADDR_CHANNEL;
end

else if (START_WRITE) begin
AWADDR <= address;
WDATA <= W_data;
AWVALID <= 1;
WVALID <= 1;
WSTRB <= 4'b1111;
state <= WRITE_CHANNEL;
end

end

RADDR_CHANNEL: begin

if (ARVALID && ARREADY) begin
ARVALID <= 0;
RREADY <= 1;
state <= RDATA_CHANNEL;
end

end

RDATA_CHANNEL: begin

if (RVALID && RREADY) begin
RREADY <= 0;
state <= IDLE;
end

end

WRITE_CHANNEL: begin

if (AWVALID && AWREADY)
AWVALID <= 0;

if (WVALID && WREADY)
WVALID <= 0;

if ((!AWVALID || AWREADY) && (!WVALID || WREADY)) begin
BREADY <= 1;
state <= WRESP_CHANNEL;
end

end

WRESP_CHANNEL: begin

if (BVALID && BREADY) begin
BREADY <= 0;
state <= IDLE;
end

end

default: begin
state <= IDLE;
end

endcase

end

end

endmodule