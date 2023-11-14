module memory_control_unit (clk,reset,add_in,mem_read,mem_write,ready_mem,stall
							,we_mem,re_mem,we_cash,read_miss);

parameter data_mem_length = 1024;
parameter cash_mem_length = 128;
parameter cash_mem_block_size = 4; //(cash_mem_block_size)per data_mem_word

localparam mem_block_no_bits = $clog2(data_mem_length) - $clog2(cash_mem_length);

localparam idle  		   = 4'd0;  //idle and read hit
localparam read_mem        = 4'd1;  //read miss and prepare data from mem
localparam read_miss_cash  = 4'd2; 	// read_miss and deliver data from mem to cash
localparam write 		   = 4'd3;  //write hit or miss

input clk,reset,mem_read,mem_write,ready_mem;
input [31:0] add_in;
output reg stall,we_mem,re_mem,we_cash,read_miss;

reg [0:0] valid [(cash_mem_length/cash_mem_block_size)-1:0];
wire tag;
reg [mem_block_no_bits-1:0] mem_block_no [(cash_mem_length/cash_mem_block_size)-1:0];


wire h_m = (tag) & (valid [add_in [$clog2(cash_mem_length)-1:$clog2(cash_mem_block_size)]]);

reg [2:0] current_state,next_state;
always@(negedge clk)
begin
	if (reset)
		current_state <= idle;
	else
		current_state <= next_state;
end

always@(current_state,h_m,mem_read,mem_write,ready_mem)
begin
	case (current_state)
	idle:begin 
			case ({mem_read,mem_write}) // synopsys full_case
			2'b10:begin
					if (h_m)
						next_state = idle;
					else 
						next_state = read_mem;
				  end
			2'b01: next_state = write;
			2'b00: next_state = idle;
		    endcase
		end
	read_mem:begin
			if (ready_mem)
				next_state = read_miss_cash;
			else
				next_state = read_mem;
		 end
	read_miss_cash:begin
					case ({mem_read,mem_write}) // synopsys full_case
					2'b10:begin
							if (h_m)
								next_state = idle;
							else 
								next_state = read_mem;
						  end
					2'b01: next_state = write;
					2'b00: next_state = idle;
					endcase
				   end
	write:begin
			if (ready_mem)
				next_state = idle;
			else
				next_state = write;
		  end
	default: next_state = idle;
	endcase
end

always@(current_state)
begin
	case (current_state)	//synopsys full_case
	idle:begin
			we_cash = 1'b0;
			we_mem = 1'b0;
			re_mem = 1'b0;
			read_miss = 1'b1;
			stall = 1'b0;
		end
	read_mem:begin
				we_cash = 1'b1;
				we_mem = 1'b0;
				re_mem = 1'b1;
				read_miss = 1'b1;
				stall = 1'b1;
			  end
	read_miss_cash:begin
					we_cash = 1'b1;
					we_mem = 1'b0;
					re_mem = 1'b0;
					read_miss = 1'b1;
					stall = 1'b0;
				   end		  
	write:begin
			if (h_m)
			begin
				we_cash = 1'b1;
				we_mem = 1'b1;
				re_mem = 1'b0;
				read_miss = 1'b0;
				stall = 1'b1;
			end
			else
			begin
				we_cash = 1'b0;
				we_mem = 1'b1;
				re_mem = 1'b0;
				read_miss = 1'b0;
				stall = 1'b1;
			end
		  end
	endcase
end

assign tag = (mem_block_no [add_in [$clog2(cash_mem_length)-1:$clog2(cash_mem_block_size)]]
				== add_in[$clog2(data_mem_length)-1:$clog2(cash_mem_length)]) ? 1'b1 : 1'b0;


integer i;
always@(posedge clk)
begin
	if (reset)
	begin
		for (i=0;i<=(cash_mem_length/cash_mem_block_size)-1;i=i+1)
		  begin
			valid[i] = 0;
			mem_block_no[i] = 0;
		  end
	end
	else if ((~h_m) & mem_read)
	begin
		valid [add_in [$clog2(cash_mem_length)-1:$clog2(cash_mem_block_size)]] = 1'b1;
		mem_block_no [add_in [$clog2(cash_mem_length)-1:$clog2(cash_mem_block_size)]] 
							= add_in[$clog2(data_mem_length)-1:$clog2(cash_mem_length)];
	end
end


endmodule