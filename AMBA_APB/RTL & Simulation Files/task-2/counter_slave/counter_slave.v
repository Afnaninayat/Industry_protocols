
module counter_slave (
	input wire clk,
	input wire rst,
	input wire out_ready,
	output reg out_valid,
	output reg [7:0] out_data = 8'd0
);

always @(posedge clk ) begin
	if (rst) begin
		out_valid <= 1'b0;
		out_data <= 8'd0;
	end else begin
		out_valid <= 1'b1;
		if (out_ready) out_data <= out_data + 8'd1;
	end
end
endmodule
