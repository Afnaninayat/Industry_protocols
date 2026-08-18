`timescale 1ns/1ps

module tb_AHB;

reg HCLK;
reg HRESETn;

reg [31:0] PADDR;
reg [31:0] PWDATA;
reg PWRITE;
reg [2:0] PSIZE;
reg [1:0] PTRANS;
reg [2:0] PBURST;

wire [31:0] HADDR;
wire [31:0] HWDATA;
wire HWRITE;
wire [2:0] HSIZE;
wire [1:0] HTRANS;
wire [2:0] HBURST;
wire PDONE;

wire HREADY;
wire HRESP;
wire [31:0] HRDATA;

wire [1:0] HSELx_slaves;
wire [1:0] HSELx_Mux;

wire HREADYOUT_1;
wire HRESP_Slave_1;
wire [31:0] HRDATA_Slave_1;

wire HREADYOUT_2;
wire HRESP_Slave_2;
wire [31:0] HRDATA_Slave_2;


AHB_Master master (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PSIZE(PSIZE),
    .PTRANS(PTRANS),
    .PBURST(PBURST),
    .HREADY(HREADY),
    .HRESP(HRESP),
    .HRDATA(HRDATA),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HTRANS(HTRANS),
    .HBURST(HBURST),
    .PDONE(PDONE)
);


AHB_Decoder decoder (
    .HADDR(HADDR),
    .HSELx_slaves(HSELx_slaves),
    .HSELx_Mux(HSELx_Mux)
);


AHB_Slave_1 slave1 (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HSELx_slaves(HSELx_slaves),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HTRANS(HTRANS),
    .HBURST(HBURST),
    .HREADY(HREADY),
    .HREADYOUT(HREADYOUT_1),
    .HRESP(HRESP_Slave_1),
    .HRDATA(HRDATA_Slave_1)
);


AHB_Slave_2 slave2 (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HSELx_slaves(HSELx_slaves),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HTRANS(HTRANS),
    .HBURST(HBURST),
    .HREADY(HREADY),
    .HREADYOUT(HREADYOUT_2),
    .HRESP(HRESP_Slave_2),
    .HRDATA(HRDATA_Slave_2)
);


AHB_MUX mux (
    .HRESP_Slave_1(HRESP_Slave_1),
    .HREADYOUT_1(HREADYOUT_1),
    .HRDATA_Slave_1(HRDATA_Slave_1),
    .HRESP_Slave_2(HRESP_Slave_2),
    .HREADYOUT_2(HREADYOUT_2),
    .HRDATA_Slave_2(HRDATA_Slave_2),
    .HSELx_Mux(HSELx_Mux),
    .HRDATA(HRDATA),
    .HREADY(HREADY),
    .HRESP(HRESP)
);


initial begin
    HCLK = 1'b0;
    forever #5 HCLK = ~HCLK;
end


initial begin
    $monitor(
        "TIME=%0t | HADDR=%h | HWDATA=%h | HWRITE=%b | HTRANS=%b | HBURST=%b | HREADY=%b | HRESP=%b | HRDATA=%h | PDONE=%b",
        $time,
        HADDR,
        HWDATA,
        HWRITE,
        HTRANS,
        HBURST,
        HREADY,
        HRESP,
        HRDATA,
        PDONE
    );
end


task reset_dut;
begin
    HRESETn = 1'b0;

    PADDR  = 32'h00000000;
    PWDATA = 32'h00000000;
    PWRITE = 1'b0;
    PSIZE  = 3'b000;
    PTRANS = 2'b00;
    PBURST = 3'b000;

    repeat(2)
        @(posedge HCLK);

    HRESETn = 1'b1;

    @(posedge HCLK);
end
endtask


task single_write;
input [31:0] addr;
input [31:0] data;

begin
    @(posedge HCLK);

    PADDR  = addr;
    PWDATA = data;
    PWRITE = 1'b1;
    PSIZE  = 3'b010;
    PTRANS = 2'b10;
    PBURST = 3'b000;

    @(posedge HCLK);

    PTRANS = 2'b00;
    PWRITE = 1'b0;

    wait(PDONE);

    @(posedge HCLK);
end
endtask


task single_read;
input [31:0] addr;

begin
    @(posedge HCLK);

    PADDR  = addr;
    PWDATA = 32'h00000000;
    PWRITE = 1'b0;
    PSIZE  = 3'b010;
    PTRANS = 2'b10;
    PBURST = 3'b000;

    @(posedge HCLK);

    PTRANS = 2'b00;

    wait(PDONE);

    @(posedge HCLK);
end
endtask


initial begin

    HRESETn = 1'b0;

    PADDR  = 32'h00000000;
    PWDATA = 32'h00000000;
    PWRITE = 1'b0;
    PSIZE  = 3'b000;
    PTRANS = 2'b00;
    PBURST = 3'b000;

    #20;

    HRESETn = 1'b1;

    $display("");
    $display("============================================================");
    $display("TEST CASE 1: Single Write Transfer (No Wait-state)");
    $display("============================================================");

    single_write(
        32'h00000010,
        32'hAABBCCDD
    );

    $display("TEST CASE 1 COMPLETED");
    $display("Address = %h", 32'h00000010);
    $display("Data    = %h", 32'hAABBCCDD);


    $display("");
    $display("============================================================");
    $display("TEST CASE 2: Single Read Transfer (No Wait-state)");
    $display("============================================================");

    single_read(
        32'h00000010
    );

    $display("TEST CASE 2 COMPLETED");
    $display("Address = %h", 32'h00000010);
    $display("Data    = %h", HRDATA);


    $display("");
    $display("============================================================");
    $display("TEST CASE 3: Write with Wait-state Insertion");
    $display("============================================================");

    @(posedge HCLK);

    PADDR  = 32'h00000020;
    PWDATA = 32'h11223344;
    PWRITE = 1'b1;
    PSIZE  = 3'b010;
    PTRANS = 2'b10;
    PBURST = 3'b000;

    @(posedge HCLK);

    $display("Wait-state test started");
    $display("HREADY = %b", HREADY);

    wait(HREADY);

    @(posedge HCLK);

    PTRANS = 2'b00;
    PWRITE = 1'b0;

    wait(PDONE);

    $display("TEST CASE 3 COMPLETED");


    $display("");
    $display("============================================================");
    $display("TEST CASE 4: Burst Transfer (INCR4 - 4 transfers)");
    $display("============================================================");

    @(posedge HCLK);

    PADDR  = 32'h00000040;
    PWDATA = 32'h11111111;
    PWRITE = 1'b1;
    PSIZE  = 3'b010;
    PTRANS = 2'b10;
    PBURST = 3'b011;

    @(posedge HCLK);

    $display("INCR4 Transfer 1: Address=%h Data=%h",
             PADDR, PWDATA);

    PADDR  = 32'h00000044;
    PWDATA = 32'h22222222;
    PTRANS = 2'b11;

    @(posedge HCLK);

    $display("INCR4 Transfer 2: Address=%h Data=%h",
             PADDR, PWDATA);

    PADDR  = 32'h00000048;
    PWDATA = 32'h33333333;
    PTRANS = 2'b11;

    @(posedge HCLK);

    $display("INCR4 Transfer 3: Address=%h Data=%h",
             PADDR, PWDATA);

    PADDR  = 32'h0000004C;
    PWDATA = 32'h44444444;
    PTRANS = 2'b11;

    @(posedge HCLK);

    $display("INCR4 Transfer 4: Address=%h Data=%h",
             PADDR, PWDATA);

    PTRANS = 2'b00;
    PWRITE = 1'b0;

    @(posedge HCLK);

    $display("TEST CASE 4 COMPLETED");


    $display("");
    $display("============================================================");
    $display("TEST CASE 5: Invalid Address with Error Response");
    $display("============================================================");

    @(posedge HCLK);

    PADDR  = 32'hC0000010;
    PWDATA = 32'hDEADBEEF;
    PWRITE = 1'b1;
    PSIZE  = 3'b010;
    PTRANS = 2'b10;
    PBURST = 3'b000;

    @(posedge HCLK);

    $display("Invalid Address = %h", PADDR);
    $display("HRESP = %b", HRESP);

    PTRANS = 2'b00;
    PWRITE = 1'b0;

    @(posedge HCLK);

    $display("TEST CASE 5 COMPLETED");


    $display("");
    $display("============================================================");
    $display("ALL AHB TEST CASES COMPLETED");
    $display("============================================================");

    #20;

    $finish;

end

endmodule
