`include "instruction_memory.v"
`include "top_module.v"
module top_tb ();

localparam t = 25;

reg clk,reset_ms,reset;
wire [31:0] instr,pc_out;

top_module t1(.clk(clk),
			  .reset_ms(reset_ms),
			  .reset(reset),
			  .pc_out(pc_out),
			  .instr(instr));

//instruction_memory (address,data_out,clk);
instruction_memory instruct(.address (pc_out),
							  .data_out (instr));

initial 
begin
	clk = 0;
	forever #(t/2) clk = ~clk;
end

initial 
begin
	
	$dumpfile ("top_tb.vcd");
	$dumpvars (0,top_tb);
	reset_ms = 1'b1;
	reset = 1'b1;
	#t
	reset_ms = 1'b0;	//to free the memory system reset
	reset = 1'b0;    	//to free RISC resets and enables and pc_sel
	#t
	#(t*85)    ///wait for the program to finish
	$dumpoff;
/* mem_add_h  mem_add_d  	val_h 

	0x46        70  >> 		0x00000293
	0x3c        60  >> 		0x00000293
	0x37        55  >> 		0x00000293
	0x31        49  >> 		0x4424C000
	0x2a        42  >> 		0xC528C000
	0x1e  		30  !> 		0x00000293
	0x23  		35  >> 		0xC528C000
	0x19   		25  >> 		0xC4ACC000
	0xf    		15  >> 		0x4424C000
	0x5    		5   >> 		0xC4FF2000
*/

///////////////cash check///////////////////////////
	if (t1.ms.data_mem1.mem[5] == 32'hC4FF2000)
		$display ("success in add 0x5 -->	success fstore \n 		     --> success conv int to float \n 		     --> success forwarding from reg and from freg");
	else
			$display ("failure in add 0x5 -->	failure fstore \n 		     --> failure conv int to float \n 		     --> failure forwarding from reg and from freg");
////////////////////////////////////////////			
	if (t1.ms.data_mem1.mem[15] == 32'h4424C000)
		$display ("success in add 0xf --> success conv unsigend to float");
	else
		$display ("failure in add 0xf --> failure conv unsigend to float");			
////////////////////////////////////////////			
	if (t1.ms.data_mem1.mem[25] == 32'hC4ACC000)
		$display ("success in add 0x19 --> success add");
	else
		$display ("failure in add 0x19 --> failure add");		
////////////////////////////////////////////		
	if (t1.ms.data_mem1.mem[35] == 32'hC528C000)
		$display ("success in add 0x23 --> success sub");
	else 
		$display ("failure in add 0x23 --> failure sub");
////////////////////////////////////////////
	if (t1.ms.data_mem1.mem[30] != 32'h00000293)
		$display ("success in add 0x1e --> success no forwarding between x3 in reg to f3 in freg ");
	else
		$display ("failure in add 0x1e --> failure no forwarding between x3 in reg to f3 in freg ");	
////////////////////////////////////////////			
	if (t1.ms.data_mem1.mem[42] == 32'hC528C000)
		$display ("success in add 0x2a --> success conv float to signed");
	else
		$display ("failure in add 0x2a --> failure conv float to signed");		
////////////////////////////////////////////		
	if (t1.ms.data_mem1.mem[49] == 32'h4424C000)
		$display ("success in add 0x31 --> failure conv float to unsigned");
	else 
		$display ("failure in add 0x31 --> failure conv float to unsigned");
////////////////////////////////////////////
	if (t1.ms.data_mem1.mem[55] == 32'h00000293)
		$display ("success in add 0x37 --> success mov to float freg");
	else
		$display ("failure in add 0x37 --> failure mov to float freg");
////////////////////////////////////////////
	if (t1.ms.data_mem1.mem[60] == 32'h00000293)
		$display ("success in add 0x3c --> success mov to int reg");
	else
			$display ("failure in 0x3c --> failure mov to int reg");		
////////////////////////////////////////////			
	if (t1.ms.data_mem1.mem[70] == 32'h00000293)
		$display ("success in add 0x46 --> success float load (flw)");
	else
		$display ("failure in add 0x46 --> failure float load (flw)");		
////////////////////////////////////////////
	$stop;
								
end
endmodule