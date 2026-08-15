`timescale 1ns/1ps

module tb_AXI;

reg ACLK;
reg ARESETN;
reg START_READ;
reg START_WRITE;
reg [31:0] address;
reg [31:0] W_data;

wire [31:0] RDATA;
wire [1:0] RRESP;
wire [1:0] BRESP;

AXI_top dut(
.ACLK(ACLK),
.ARESETN(ARESETN),
.START_READ(START_READ),
.START_WRITE(START_WRITE),
.address(address),
.W_data(W_data),
.RDATA(RDATA),
.RRESP(RRESP),
.BRESP(BRESP)
);

initial begin
ACLK = 0;
forever #5 ACLK = ~ACLK;
end

task write_data;
input [31:0] addr;
input [31:0] data;

begin

@(posedge ACLK);

address = addr;
W_data = data;
START_WRITE = 1;

@(posedge ACLK);

START_WRITE = 0;

wait(dut.master.state == 3'b000);

@(posedge ACLK);

$display("WRITE: Address = %h Data = %h", addr, data);

end
endtask

task read_data;
input [31:0] addr;

begin

@(posedge ACLK);

address = addr;
START_READ = 1;

@(posedge ACLK);

START_READ = 0;

wait(dut.master.state == 3'b000);

@(posedge ACLK);

$display("READ: Address = %h Data = %h", addr, RDATA);

end
endtask

initial begin

ARESETN = 0;
START_READ = 0;
START_WRITE = 0;
address = 0;
W_data = 0;

#20;

ARESETN = 1;

#20;

write_data(32'h00000000,32'h5A5AA5A5);
read_data(32'h00000000);

if (RDATA == 32'h5A5AA5A5)
$display("CASE 1 PASSED");
else
$display("CASE 1 FAILED");

#20;

write_data(32'h00000004,32'h12345678);
read_data(32'h00000004);

if (RDATA == 32'h12345678)
$display("CASE 2 PASSED");
else
$display("CASE 2 FAILED");

#20;

write_data(32'h00000008,32'hABCDEF01);
read_data(32'h00000008);

if (RDATA == 32'hABCDEF01)
$display("CASE 3 PASSED");
else
$display("CASE 3 FAILED");

#20;

write_data(32'h0000000C,32'hFEDCBA98);
read_data(32'h0000000C);

if (RDATA == 32'hFEDCBA98)
$display("CASE 4 PASSED");
else
$display("CASE 4 FAILED");

#20;

read_data(32'h00000000);

if (RDATA == 32'h5A5AA5A5)
$display("CASE 5 PASSED");
else
$display("CASE 5 FAILED");

#20;

read_data(32'h00000004);

if (RDATA == 32'h12345678)
$display("CASE 6 PASSED");
else
$display("CASE 6 FAILED");

#20;

read_data(32'h00000008);

if (RDATA == 32'hABCDEF01)
$display("CASE 7 PASSED");
else
$display("CASE 7 FAILED");

#20;

read_data(32'h0000000C);

if (RDATA == 32'hFEDCBA98)
$display("CASE 8 PASSED");
else
$display("CASE 8 FAILED");

#20;

read_data(32'h00000010);

if (RDATA == 32'h00000000)
$display("CASE 9 PASSED");
else
$display("CASE 9 FAILED");

#20;

$display("ALL TEST CASES COMPLETED");

$finish;

end

endmodule

