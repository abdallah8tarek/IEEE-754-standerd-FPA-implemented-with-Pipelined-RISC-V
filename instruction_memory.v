module instruction_memory (address,data_out);

parameter length = 256;
parameter width = 32;

input [31:0]address;
output [31:0]data_out;
reg [width-1:0] mem [length-1:0];

assign data_out = mem [address>>2];

initial
begin
	$readmemh("instruction_mem_for_pipeline_and_FPAU.txt", mem);
end
endmodule