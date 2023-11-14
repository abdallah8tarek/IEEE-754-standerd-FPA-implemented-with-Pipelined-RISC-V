module reg_file (a1,a2,a3,wd3,rd1,rd2,clk,we3);

input clk,we3;
input [4:0] a1,a2,a3;
input [31:0] wd3;
output [31:0] rd1,rd2;

reg [31:0] mem [31:0];

assign  rd2 = (a2 == 5'd0) ? 32'd0 : mem [a2];
assign 	rd1 = (a1 == 5'd0) ? 32'd0 : mem [a1];

always@(negedge clk)
begin
	if (we3)
		mem [a3] <= wd3;
	else
		mem [a3] <= mem [a3];
end
endmodule