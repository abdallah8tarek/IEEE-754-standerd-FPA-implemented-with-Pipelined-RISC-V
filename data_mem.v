// 32bit word memory edged write edged read with coounter 4 
//to emilate 0.25 speed compared to clk and one block read 16 byte
module data_mem (address,data_in,data_out,clk,mem_read,mem_write,we,re,ready);

parameter length = 1024;
parameter width = 32;

localparam idle 	 = 3'd0;
localparam rm1  	 = 3'd1;
localparam rm2 	     = 3'd2;
localparam rm3 	     = 3'd3;
localparam rm4 	     = 3'd4;

input clk,we,re,mem_read,mem_write;
input [width-1:0]address;
input [width-1:0]data_in;

output [(width*4)-1:0]data_out;
output reg ready;


reg [(width*4)-1:0] temp;
reg [width-1:0] mem [length-1:0];

wire [$clog2(length)-1:0]trunc_add;

function [$clog2(length)-1:0] address_trunc;
input [width-1:0]add;

address_trunc = add;
endfunction

assign trunc_add = address_trunc (address);

reg [2:0] current_state,next_state;
wire reset = ~(mem_write | mem_read);
always@(negedge clk)
begin
	if (reset)
		current_state <= idle;
	else
		current_state <= next_state;
end

always@(current_state,we,re)
begin
	case (current_state)	// synopsys full_case
	idle:begin 
			next_state = rm1;
		end
	rm1:begin
			next_state = rm2;
		 end
	rm2:begin
			next_state = rm3;
		 end
	rm3:begin
			next_state = rm4;
		 end
	rm4:begin
			next_state = idle;
		 end
	endcase
end

always@(posedge clk)
begin
	if (current_state == rm4)
	begin
		if (we)
		begin
			mem [trunc_add] <= data_in;
			ready = 1'b1;
		end
		else if (re)
		begin
			temp = {mem [{trunc_add[$clog2(length)-1:2],2'b11}],
					mem [{trunc_add[$clog2(length)-1:2],2'b10}],
					mem [{trunc_add[$clog2(length)-1:2],2'b01}],
					mem [{trunc_add[$clog2(length)-1:2],2'b00}]};
			ready = 1'b1;
		end
		else 
		begin
			mem [trunc_add] <= mem [trunc_add];
			ready = 1'b0;
		end
	end
	else 
	begin
		ready = 1'b0;
		mem [trunc_add] <= mem [trunc_add];
	end
end

assign 	data_out = temp;
endmodule