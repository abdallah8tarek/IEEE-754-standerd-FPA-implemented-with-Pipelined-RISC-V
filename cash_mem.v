module cash_mem (address,data_in,data_out,clk,we,read_miss);
parameter length = 128;
parameter width = 32;

input clk,we,read_miss;
input [width-1:0]address;
input [(width*4)-1:0]data_in;
output [width-1:0]data_out;

reg [width-1:0] mem [length-1:0];

wire [$clog2(length)-1:0]trunc_add;
function [$clog2(length)-1:0] address_trunc;
input [width-1:0]add;
address_trunc = add;
endfunction

assign trunc_add = address_trunc (address);
assign data_out = mem [trunc_add];

always@(negedge clk)
begin
	if (we)
	begin
		if (read_miss)
		begin
			mem [{trunc_add[$clog2(length)-1:2],2'b00}] <= data_in [width-1:0];
			mem [{trunc_add[$clog2(length)-1:2],2'b01}] <= data_in [(width*2)-1:width];
			mem [{trunc_add[$clog2(length)-1:2],2'b10}] <= data_in [(width*3)-1:(width*2)];
			mem [{trunc_add[$clog2(length)-1:2],2'b11}] <= data_in [(width*4)-1:(width*3)];
		end
		else
		begin
			mem [trunc_add] <= data_in [width-1:0];
		end
	end
	else
	begin
		mem [trunc_add] <= mem [trunc_add];
	end
end
endmodule