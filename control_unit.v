module control_unit (instr,result_sel,mem_write,alu_sel,imm_sel
					,mem_read,reg_write,alu_control,fpu_control
					,jalr_sel,bne_beq_sel,jump,branch,rd1_selD
					,rd2_selD,rdW_selD,reg_writeD_sel,sourceAB_sel_D);

localparam lw 	  = 7'b0000011;
localparam sw 	  = 7'b0100011;
localparam R_type = 7'b0110011;
localparam I_type = 7'b0010011;
localparam jal    = 7'b1101111;
localparam beq    = 7'b1100011;
localparam jalr   = 7'b1100111;

localparam R_type_float   = 7'b1010011;
localparam lw_float       = 7'b0000111;
localparam sw_float  	  = 7'b0100111;

localparam add 	      				    		= 7'b0000000;
localparam sub 	 	   				  			= 7'b0000100;
localparam sign_inject 				  			= 7'b0010000;//& nsign_inject &xor_sign_inject
localparam min					     		    = 7'b0010100; //& max
localparam compare    				  			= 7'b1010000; // '=' & '<' &'<='
localparam conv_float_to_unsigned_or_signed_int = 7'b1100000;
localparam conv_unsigned_or_signed_int_to_float = 7'b1101000;
localparam mov_to_int_reg 			 			= 7'b1110000;
localparam mov_to_float_reg			  			= 7'b1111000;



input [31:0] instr;

output mem_read,reg_write,alu_sel,mem_write,jalr_sel,branch,jump;
output rd1_selD,rd2_selD,rdW_selD,reg_writeD_sel,sourceAB_sel_D;
output reg bne_beq_sel;
output reg [2:0] alu_control;
output reg [3:0] fpu_control;

output [1:0] result_sel,imm_sel;

wire [6:0] op_code = instr [6:0];
wire [2:0] func3 = instr [14:12];
wire [6:0] func7 = instr [31:25];
wire [1:0] alu_operation;
reg [17:0] op;
assign sourceAB_sel_D = op [17];
assign rd1_selD = op [16];
assign rd2_selD = op [15];
assign rdW_selD = op [14];
assign reg_writeD_sel = op [13];
assign mem_read = op [12];
assign reg_write = op [11];
assign imm_sel = op [10:9];
assign alu_sel = op [8];
assign mem_write = op [7];
assign result_sel = op [6:5];
assign branch = op [4];
assign jump = op [3];
assign alu_operation = op [2:1];
assign jalr_sel = op [0];

always@(instr)   //main decoder
begin
		case (op_code)
						//sourceAB_sel_D  rd1_selD	rd2_selD	rdW_selD	reg_writeD_sel	 mem_read reg_write  imm_sel  alu_sel   mem_write  result_sel   branch   jump   alu_operation   jalr_sel
		lw: op = 	 	{	  1'b0,			1'b0,	  1'b0,		  1'b0,			 1'b0,			1'b1,   1'b1,     2'b00,    1'b1,     1'b0,      2'b01,      1'b0,   1'b0,      2'b00,		1'b0};
		sw: op = 	 	{	  1'b0,			1'b0,	  1'b0,		  1'b0,			 1'b0,			1'b0,   1'b0,     2'b01,    1'b1,     1'b1,      2'b00,      1'b0,   1'b0,      2'b00,	    1'b0};
		beq: op =    	{	  1'b0,			1'b0,	  1'b0,		  1'b0,			 1'b0,			1'b0,   1'b0,     2'b10,    1'b0,     1'b0,      2'b00,      1'b1,   1'b0,      2'b01,		1'b0};
		jal: op = 	 	{	  1'b0,			1'b0,	  1'b0,		  1'b0,			 1'b0,			1'b0,   1'b1,     2'b11,    1'b0,     1'b0,      2'b10,      1'b0,   1'b1,      2'b00,		1'b0};
		I_type: op = 	{	  1'b0,			1'b0,	  1'b0,		  1'b0,			 1'b0,			1'b0,   1'b1,     2'b00,    1'b1,     1'b0,      2'b00,      1'b0,   1'b0,      2'b10,		1'b0};
		R_type: op = 	{	  1'b0,			1'b0,	  1'b0,		  1'b0,			 1'b0,			1'b0,   1'b1,     2'b00,    1'b0,     1'b0,      2'b00,      1'b0,   1'b0,      2'b10,		1'b0};
		jalr: op =   	{	  1'b0,			1'b0,	  1'b0,		  1'b0,			 1'b0,			1'b0,   1'b1,     2'b00,    1'b1,     1'b0,      2'b10,      1'b0,   1'b1,      2'b00,		1'b1};
		lw_float: op =  {	  1'b0,			1'b0,	  1'b0,		  1'b1,			 1'b1,			1'b1,   1'b1,     2'b00,    1'b1,     1'b0,      2'b01,      1'b0,   1'b0,      2'b00,		1'b0};		
		sw_float: op =  {	  1'b0,			1'b0,	  1'b1,		  1'b0,			 1'b0,			1'b0,   1'b0,     2'b01,    1'b1,     1'b1,      2'b00,      1'b0,   1'b0,      2'b00,	    1'b0};
		R_type_float:begin
						if (func7[6:5] != 2'b11)
							   //sourceAB_sel_D  rd1_selD	rd2_selD	rdW_selD	reg_writeD_sel	 mem_read reg_write  imm_sel  alu_sel   mem_write  result_sel   branch   jump   alu_operation   jalr_sel
							op={	  1'b1,			1'b1,	  1'b1,		  1'b1,			 1'b1,			1'b0,   1'b1,     2'b00,    1'b0,     1'b0,      2'b00,      1'b0,   1'b0,      2'b10,		1'b0}; 
						else 
							begin
								case (func7)
								conv_float_to_unsigned_or_signed_int:
										//sourceAB_sel_D  rd1_selD	rd2_selD	rdW_selD	reg_writeD_sel	 mem_read reg_write  imm_sel  alu_sel   mem_write  result_sel   branch   jump   alu_operation   jalr_sel
									op={	  1'b1,			1'b1,	  1'b1,		  1'b0,			 1'b0,			1'b0,   1'b1,     2'b00,    1'b0,     1'b0,      2'b00,      1'b0,   1'b0,      2'b10,		1'b0}; 
								
								conv_unsigned_or_signed_int_to_float:
										//sourceAB_sel_D  rd1_selD	rd2_selD	rdW_selD	reg_writeD_sel	 mem_read reg_write  imm_sel  alu_sel   mem_write  result_sel   branch   jump   alu_operation   jalr_sel
									op={	  1'b1,			1'b0,	  1'b1,		  1'b1,			 1'b1,			1'b0,   1'b1,     2'b00,    1'b0,     1'b0,      2'b00,      1'b0,   1'b0,      2'b11,		1'b0}; 
								
								mov_to_int_reg:
										//sourceAB_sel_D  rd1_selD	rd2_selD	rdW_selD	reg_writeD_sel	 mem_read reg_write  imm_sel  alu_sel   mem_write  result_sel   branch   jump   alu_operation   jalr_sel
									op={	  1'b1,			1'b1,	  1'b1,		  1'b0,			 1'b0,			1'b0,   1'b1,     2'b00,    1'b0,     1'b0,      2'b00,      1'b0,   1'b0,      2'b10,		1'b0}; 
									
								mov_to_float_reg:
										//sourceAB_sel_D  rd1_selD	rd2_selD	rdW_selD	reg_writeD_sel	 mem_read reg_write  imm_sel  alu_sel   mem_write  result_sel   branch   jump   alu_operation   jalr_sel
									op={	  1'b0,			1'b0,	  1'b1,		  1'b1,			 1'b1,			1'b0,   1'b1,     2'b00,    1'b0,     1'b0,      2'b00,      1'b0,   1'b0,      2'b10,		1'b0}; 
								endcase
							end
					end
		default : op = 0;
		endcase
end

always@(*)   //alu decoder
begin
	if (func3 == 3'b001)
		bne_beq_sel = 1'b0;
	else 
		bne_beq_sel = 1'b1;
	//alu_control = alu_control;
	case (alu_operation)
	2'b00: alu_control = 3'b000;   //add //lw,sw
	2'b01: alu_control = 3'b001;   //sub  //beq
	default: //R_type 2'b10
	begin
		case (func3)
		3'b000: 
			begin 
				if ({op_code[5],func7[5]} == 2'b11)
					alu_control = 3'b001;     ///sub
				else if (func7 == mov_to_float_reg)
					alu_control = 3'b111;     ///mov_to_float_reg
				else
					alu_control = 3'b000;     ///add
			end
		3'b010: alu_control = 3'b101;       //set less than ///slt
		3'b110: alu_control = 3'b011;       ///or
		3'b111: alu_control = 3'b010;       ///and
		default : 	alu_control = 3'b000;     ///add
		endcase
	end
	endcase
end

always@(*)   //fpu decoder
begin
	case (func7)
	add: fpu_control = 4'd0;
	sub: fpu_control = 4'd1;
	sign_inject: begin case (func3)	//synopsis full_case
					   3'b000: fpu_control = 4'd2; //sign_inject
					   3'b001: fpu_control = 4'd3; //neg_sign_inject
					   3'b010: fpu_control = 4'd4; //xor_sign_inject
					   endcase
				 end
	min: fpu_control = func3 ? 4'd5 /*max*/ : 4'd6 /*min*/;
	compare :begin case (func3)	//synopsis full_case
				   3'b010: fpu_control = 4'd7; // a == b
				   3'b001: fpu_control = 4'd8; // a <  b
				   3'b000: fpu_control = 4'd9; // a <= b
				   endcase
			 end
	mov_to_int_reg: fpu_control = 4'd10;
	conv_float_to_unsigned_or_signed_int: fpu_control = 4'd11;
	conv_unsigned_or_signed_int_to_float: fpu_control = 4'd12;
	default: fpu_control = 4'b1111;
	endcase
end
endmodule