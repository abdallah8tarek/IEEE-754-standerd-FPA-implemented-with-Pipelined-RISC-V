module ALU (zero,ALUout,a,b,ALUControl);
	
	output reg zero;
	output reg signed [31:0] ALUout;
	input [2:0] ALUControl;
	input [31:0] a,b;
	
	always @(*) 
	begin
		case (ALUControl)
		3'd2 : ALUout = a & b;   //bitwise and //& no op. (FPU op.)
		3'd3 : ALUout = a | b;   //bitwise or
		3'd0 : ALUout = a + b;   //addition
		3'd1 : ALUout = a - b;   //subtraction
		3'd5 : ALUout = (a<b)? 1:0;   //compare
		3'd7 : ALUout = a;	//
		default : ALUout = 0;
		endcase
		
		if (ALUout == 0)
			zero = 1;
		else 
			zero = 0;
	end
endmodule