module d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
input [n-1:0] in;
input clk,reset,en;
output reg [n-1:0] out;

always@(posedge clk)
	if (!en)
	begin
		if (reset)
			out <= 32'd0;
		else
			out <= in;
	end
	else
		out <= out;
endmodule