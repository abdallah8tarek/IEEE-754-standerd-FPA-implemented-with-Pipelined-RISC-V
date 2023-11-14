`include "data_mem.v"
`include "cash_mem.v"
`include "memory_control_unit.v"
module memory_system (clk,mem_read,mem_write,reset,add_in,data_in,stall,data_out);

input clk,mem_read,mem_write,reset;
input [31:0] add_in,data_in;

output stall;
output [31:0] data_out;

//memory_control_unit (clk,reset,add_in,mem_read,mem_write,ready_mem,stall,we_mem
//						,re_mem,we_cash,read_miss);
wire ready_mem,we_mem,re_mem,we_cash,read_miss;
wire [127:0] data_interm_mem,data_interm_cash;
memory_control_unit mcu(.clk(clk),
						.reset(reset),
						.add_in(add_in),
						.mem_read(mem_read),
						.mem_write(mem_write),
						.ready_mem(ready_mem),
						.stall(stall),
						.we_mem(we_mem),
						.re_mem(re_mem),
						.we_cash(we_cash),
						.read_miss(read_miss));

//data_mem (address,data_in,data_out,clk,we,re,ready);
data_mem #(1024,32) data_mem1 (.address(add_in),		//length = 1024; width = 32;
							   .data_in(data_in),
							   .data_out(data_interm_mem),
							   .clk(clk),
							   .mem_read(mem_read),
							   .mem_write(mem_write),
						       .we(we_mem),
							   .re(re_mem),
							   .ready(ready_mem));
							   
assign data_interm_cash = read_miss ? data_interm_mem : {96'd0,data_in};
//cash_mem (address,data_in,data_out,clk,we,read_miss)
cash_mem #(128,32) cash_mem1 (.address(add_in),		//length = 128; width = 32;
							  .data_in(data_interm_cash),
							  .data_out(data_out),
							  .clk(clk),
							  .we(we_cash),
							  .read_miss(read_miss));

endmodule