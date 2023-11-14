module sign_extend (in,out,sel);

input [31:7] in;
input [1:0] sel;
output reg [31:0] out;

always@(*)
	if (sel == 2'b00)   // I_type
		out = {{20{in[31]}}, in[31:20]};
	else if (sel == 2'b01)  // S_type
		out = {{20{in[31]}}, in[31:25], in[11:7]};
	else if (sel == 2'b10)		// B_type
		out = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};
	else      // sel = 2'b11	// J_type
		out = {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0};
endmodule