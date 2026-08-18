
module tb_handshake;
	reg clk_tb;
	reg rst_tb;
	reg out_ready_tb;
	wire out_valid_tb;
	wire [7:0] out_data_tb;

	counter_slave uut
	(
		.clk(clk_tb),
		.rst(rst_tb),
		.out_ready(out_ready_tb),
		.out_valid(out_valid_tb),
		.out_data(out_data_tb)
	);

	always #5 clk_tb = ~clk_tb;

	initial begin
		$monitor("Time=0%t reset=%b valid=%b ready=%b data=%b", 
			$time, rst_tb, out_valid_tb, out_ready_tb, out_data_tb);

		clk_tb = 1'b0;
		out_ready_tb = 1'b0;
		rst_tb = 1'b1;
		#20;

		rst_tb = 1'b0;
		out_ready_tb = 1'b1;
		#10;

		rst_tb = 1'b0;
		out_ready_tb = 1'b1;
		#10;

		rst_tb = 1'b1;
		out_ready_tb = 1'b1;
		#10;

		rst_tb = 1'b0;
		out_ready_tb = 1'b1;
		#100
		
		$finish;
	end
endmodule
