module full_adder_behave (f_sum,a,b);
	
	output [31:0] f_sum;
	input [31:0] a,b;
	
	assign f_sum = a + b ;
endmodule

module full_adder_behave_carry_out #(parameter n = 32)(f_sum,a,b,c_out);
	
	output [n-1:0] f_sum;
	output c_out;
	input [n-1:0] a,b;
		
	assign {c_out,f_sum} = a + b ;

endmodule