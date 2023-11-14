module mux2 (mux_out,in0,in1,sel);
	output [31:0] mux_out;
	input [31:0] in0,in1;
	input sel;
	
	assign mux_out = sel ? in1 : in0;
endmodule

module dmux2 #(parameter n = 32)(dmux_in,out0,out1,sel);
	output [n-1:0] out0,out1;
	input [n-1:0] dmux_in;
	input sel;
	
	assign {out0,out1} = sel ? {{n{1'b0}},dmux_in} : {dmux_in,{n{1'b0}}};
endmodule

module mux3 (mux_out,in0,in1,in2,sel);
	output reg [31:0] mux_out;
	input [31:0] in0,in1,in2;
	input [1:0] sel;
	
	always@(*)
		case (sel)
		2'b00:	mux_out = in0;
		2'b01:	mux_out = in1;
		2'b10:	mux_out = in2;
		2'b11:	mux_out = 32'd0;
		endcase
endmodule