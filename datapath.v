`include "MUX.v"
`include "adder.v"
`include "reg_file.v"
`include "sign_extend.v"
`include "ALU.v"
`include "FPAU.v"
`include "d_flip_flop_32.v"
`include "hazerd_unit.v"
module datapath (instr,instrD,read_data,clk,reset
				,mem_read,reg_write,alu_sel,alu_control
				,fpu_control,result_sel,imm_sel,pc_out
				,alu_result_out,write_dataM,jalr_sel,bne_beq_sel
				,jump,branch,mem_write,mem_writeM,mem_readM,stall
				,rd1_selD,rd2_selD,rdW_selD,reg_writeD_sel,sourceAB_sel_D);

input [31:0] instr;
input [31:0] read_data;
input clk,reset,stall,mem_read,reg_write;
input alu_sel,jalr_sel,bne_beq_sel,jump,branch,mem_write;
input rd1_selD,rd2_selD,rdW_selD,reg_writeD_sel,sourceAB_sel_D;
input [2:0] alu_control;
input [3:0] fpu_control;
input [1:0] result_sel,imm_sel;

output mem_writeM,mem_readM;
output [31:0] pc_out;
output [31:0] alu_result_out;
output [31:0] write_dataM;
output [31:0] instrD;

wire reset_F,reset_D,reset_E,reset_M,reset_W;
wire pc_sel,en_F,en_D,en_E,en_M,en_W;

wire [31:0] pcF;

wire [31:0] pcD,pc_plus4D,rd1,rd2,immexD;
wire [4:0] rs1D,rs2D,rdD;
assign rs1D = instrD [19:15];
assign rs2D = instrD [24:20];
assign rdD = instrD [11:7];

wire mem_readE,reg_writeE,alu_selE,jalr_selE,bne_beq_selE;
wire mem_writeE,jumpE,branchE;
wire [2:0] alu_controlE;
wire [1:0] result_selE;
wire [31:0] pcE,pc_plus4E,rd1E,rd2E,immexE;
wire [4:0] rs1E,rs2E,rdE;
wire [31:0] write_dataE;

wire reg_writeM;
wire [1:0] result_selM;
wire [31:0] pc_plus4M,alu_fpu_resultM;
wire [4:0] rdM;

wire reg_writeW,reg_writeW_sel,rdW_selW;
wire [1:0] result_selW;
wire [31:0] pc_plus4W,alu_fpu_resultW,read_dataW;
wire [4:0] rdW;

wire [1:0] forwardAE,forwardBE;
wire stallF,stallD,stallE,stallM,stallW,flushD,flushE;

wire [31:0] sourceB,sourceA;
wire zero,zero_flag;

//mux2 (mux_out,in0,in1,sel)
wire pc_sel_real;
wire [31:0] pc_next,pc_target,pc_plus4;
wire [31:0] pc_or_reg;    //for jalr selection
mux2 pc_mux(.mux_out (pc_next),
			.in0 (pc_plus4),
			.in1 (pc_or_reg),
			.sel (pc_sel_real));

//full_adder_behave (f_sum,a,b)
full_adder_behave add_plus_4(.f_sum (pc_plus4),
					         .a (32'd4),
							 .b (pcF));		 

//mux2 (mux_out,in0,in1,sel)
wire [31:0] rd1_int,rd1_float;
mux2 rd1_mux(.mux_out (rd1),
			 .in0 (rd1_int),
			 .in1 (rd1_float),
			 .sel (rd1_selD)); //0 --> rd1 (sourceA) is int | 1 --> rd1 (sourceA) is int float 
		
//mux2 (mux_out,in0,in1,sel)
wire [31:0] rd2_int,rd2_float;
mux2 rd2_mux(.mux_out (rd2),
		   	 .in0 (rd2_int),
			 .in1 (rd2_float),
			 .sel (rd2_selD)); //0 --> rd2 (sourceB) is int | 1 --> rd2 (sourceB) is int float 

//dmux2 (#parameter n = 32)(dmux_in,out0,out1,sel)
wire [4:0] rdW_int,rdW_float;
dmux2 #(5) wb_add_dmux(.dmux_in(rdW),
					   .out0(rdW_int),
					   .out1(rdW_float),
					   .sel(rdW_selW)); //0 --> write in int reg_file | 1 --> write in float reg_file
					 
//dmux2 (#parameter n = 32)(dmux_in,out0,out1,sel)
wire reg_writeW_int,reg_writeW_float;
dmux2 #(1) wb_en_dmux(.dmux_in(reg_writeW),
				      .out0(reg_writeW_int),
				      .out1(reg_writeW_float),
					  .sel(reg_writeW_sel)); //0 --> write in int reg_file | 1 --> write in float reg_file

//reg_file (a1,a2,a3,wd3,rd1,rd2,clk,we3)
wire [31:0] result;
reg_file reg_file1_int(.a1 (instrD[19:15]),
					   .a2 (instrD[24:20]),
					   .a3 (rdW_int),
					   .wd3 (result),
					   .rd1 (rd1_int),
					   .rd2 (rd2_int),
					   .clk (clk),
					   .we3 (reg_writeW_int));
				   
//reg_file (a1,a2,a3,wd3,rd1,rd2,clk,we3)
reg_file reg_file_float(.a1 (instrD[19:15]),
					    .a2 (instrD[24:20]),
						.a3 (rdW_float),
						.wd3 (result),
						.rd1 (rd1_float),
						.rd2 (rd2_float),
						.clk (clk),
						.we3 (reg_writeW_float));

//sign_extend (in,out,sel)
sign_extend extend(.in (instrD[31:7]),
				   .out (immexD),
				   .sel (imm_sel));

//mux3 (mux_out,in0,in1,in2,sel)
mux3 source_forwardingA(.mux_out (sourceA),
						.in0 (rd1E),
						.in1 (result),
						.in2 (alu_fpu_resultM),
						.sel (forwardAE));

//mux3 (mux_out,in0,in1,in2,sel)
mux3 source_forwardingB(.mux_out (write_dataE),
						.in0 (rd2E),
						.in1 (result),
						.in2 (alu_fpu_resultM),
						.sel (forwardBE));
				
//full_adder_behave (f_sum,a,b)
full_adder_behave add_imm(.f_sum (pc_target),
						  .a (immexE),
					      .b (pcE));						   			   

//mux2 (mux_out,in0,in1,sel)
wire [31:0] sourceB_int;
mux2 reg_out_mux(.mux_out (sourceB),
				 .in0 (sourceB_int),
				 .in1 (immexE),
				 .sel (alu_selE));

//dmux2 (#parameter n = 32)(dmux_in,out0,out1,sel)
wire [31:0] sourceB_float;
wire sourceAB_sel_E;
dmux2 #(32) srcB_dmux(.dmux_in(write_dataE),
					  .out0(sourceB_int),
					  .out1(sourceB_float),
					  .sel(sourceAB_sel_E)); //0 int sourceB | 1 float sourceB

//dmux2 (#parameter n = 32)(dmux_in,out0,out1,sel)
wire [31:0] sourceA_int,sourceA_float;
dmux2 #(32) srcA_dmux(.dmux_in(sourceA),
				     .out0(sourceA_int),
				     .out1(sourceA_float),
					 .sel(sourceAB_sel_E)); //0 int sourceA | 1 float sourceA

//FPAU (FPUout,a,b,FPUControl)
wire [31:0] fpu_res;
wire [3:0] fpu_controlE;
FPAU fpu1(.FPUout(fpu_res),
		 .a(sourceA_float),
		 .b(sourceB_float),
		 .FPUControl(fpu_controlE),
		 .rs2E_0(rs2E[0]));

//ALU (zero,ALUout,a,b,ALUControl)
wire [31:0] alu_res;
ALU alu1(.zero (zero),
		 .ALUout (alu_res),
		 .a (sourceA_int),
		 .b (sourceB),
		 .ALUControl (alu_controlE));
assign zero_flag = bne_beq_selE ? zero : ~zero;
assign pc_sel_real = pc_sel ? (jumpE | (zero_flag & branchE)) : 1'b0;


//mux2 (mux_out,in0,in1,sel)
wire [31:0] alu_fpu_res;
mux2 ALU_FPU_out_mux(.mux_out (alu_fpu_res),
					 .in0 (alu_res),
					 .in1 (fpu_res),
					 .sel (sourceAB_sel_E)); //0 int out of ALU | 1 float out of FPU

//mux2 (mux_out,in0,in1,sel)
mux2 jalr_mux(.mux_out (pc_or_reg),
			  .in0 (pc_target),
			  .in1 (alu_res),
			  .sel (jalr_selE));

//mux3 (mux_out,in0,in1,in2,sel)
mux3 result_mux(.mux_out (result),
				.in0 (alu_fpu_resultW),
				.in1 (read_dataW),
				.in2 (pc_plus4W),
				.sel (result_selW));

wire en_F_real = en_F ? stallF : 1'b0;
//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
d_flip_flop #(32) featch(.in(pc_next),
						 .out(pcF),
						 .clk(clk),
						 .reset(reset_F),
						 .en(en_F_real));

wire reset_D_real = reset_D ? 1'b1 : flushD;
wire en_D_real = en_D ? stallD : 1'b0;
//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
wire [95:0] decode_in = {instr,pcF,pc_plus4};
wire [95:0] decode_out;
assign {instrD,pcD,pc_plus4D} = decode_out;
d_flip_flop #(96) decode(.in(decode_in),
						 .out(decode_out),
						 .clk(clk),
						 .reset(reset_D_real),
						 .en(en_D_real));

//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
wire reset_E_real = reset_E ? 1'b1 : flushE;
wire en_E_real = en_E ? stallE : 1'b0;
wire rd1_selE,rd2_selE,rdW_selE,reg_writeE_sel;
wire [196:0] excute_in = {mem_read,reg_write,alu_sel,jalr_sel
							,bne_beq_sel,alu_control,fpu_control,result_sel
							,mem_write,rd1,rd2,pcD,rs1D,rs2D,rdD
							,rd1_selD,rd2_selD,rdW_selD,immexD,pc_plus4D
							,jump,branch,reg_writeD_sel,sourceAB_sel_D};
wire [196:0] excute_out;
assign {mem_readE,reg_writeE,alu_selE,jalr_selE,bne_beq_selE
		,alu_controlE,fpu_controlE,result_selE,mem_writeE,rd1E,rd2E,pcE
		,rs1E,rs2E,rdE,rd1_selE,rd2_selE,rdW_selE,immexE,pc_plus4E
		,jumpE,branchE,reg_writeE_sel,sourceAB_sel_E} = excute_out;
d_flip_flop #(197) excute(.in(excute_in),
						  .out(excute_out),
						  .clk(clk),
						  .reset(reset_E_real),
						  .en(en_E_real));

//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
wire en_M_real = en_M ? stallM : 1'b0;
wire reg_writeM_sel,rdW_selM;
wire [107:0] mem_in = {mem_readE,reg_writeE,result_selE,mem_writeE
						,alu_fpu_res,write_dataE,rdE,pc_plus4E,reg_writeE_sel,rdW_selE};
wire [107:0] mem_out;
assign {mem_readM,reg_writeM,result_selM,mem_writeM,alu_fpu_resultM
		,write_dataM,rdM,pc_plus4M,reg_writeM_sel,rdW_selM} = mem_out;
d_flip_flop #(108) memory(.in(mem_in),
						  .out(mem_out),
						  .clk(clk),
						  .reset(reset_M),
						  .en(en_M_real));

//d_flip_flop #(parameter n = 32)(in,out,clk,reset,en);
wire en_W_real = en_W ? stallW : 1'b0;
wire [105:0] write_back_in = {reg_writeM,result_selM,alu_fpu_resultM
								,read_data,rdM,pc_plus4M,reg_writeM_sel,rdW_selM};
wire [105:0] write_back_out;
assign {reg_writeW,result_selW,alu_fpu_resultW,read_dataW,rdW
		,pc_plus4W,reg_writeW_sel,rdW_selW} = write_back_out;
d_flip_flop #(106) write_back(.in(write_back_in),
							  .out(write_back_out),
							  .clk(clk),
							  .reset(reset_W),
							  .en(en_W_real));

//hazerd_unit (rs1D,rs2D,rd1_selD,rd2_selD,rdW_selD,rdE,rs1E,rs2E
//				,rd1_selE,rd2_selE,rdW_selE,rdW_selM,rdW_selW,pc_sel
//				,result_selE,rdM,reg_writeM,rdW,reg_writeW,forwardAE
//				,forwardBE,stallF,stallD,stallE,stallM,stallW,flushD
//				,flushE,stall);
hazerd_unit u0(.rs1D(rs1D),
			   .rs2D(rs2D),
			   .rd1_selD(rd1_selD),
			   .rd2_selD(rd2_selD),
			   .rdW_selD(rdW_selD),
			   .rdE(rdE),
			   .rs1E(rs1E),
			   .rs2E(rs2E),
			   .rd1_selE(rd1_selE),
			   .rd2_selE(rd2_selE),
			   .rdW_selE(rdW_selE),
			   .rdW_selM(rdW_selM),
			   .rdW_selW(rdW_selW),
			   .pc_sel(pc_sel_real),
			   .result_selE(result_selE[0]),
			   .rdM(rdM),
			   .reg_writeM(reg_writeM),
			   .rdW(rdW),
			   .reg_writeW(reg_writeW),
			   .forwardAE(forwardAE),
			   .forwardBE(forwardBE),
			   .stallF(stallF),
			   .stallD(stallD),
			   .stallE(stallE),
			   .stallM(stallM),
			   .stallW(stallW),
			   .flushD(flushD),
			   .flushE(flushE),
			   .stall(stall));

//output assignment
assign pc_out = pcF;
assign alu_result_out = alu_fpu_resultM;
assign {en_F,en_D,en_E,en_M,en_W} = reset ? 5'b0_0_0_0_0 : 5'b1_1_1_1_1;
assign {reset_F,reset_D,reset_E,reset_M,reset_W} = reset ? 5'b1_1_1_1_1 : 5'b0_0_0_0_0;
assign pc_sel = reset ? 1'b0 : 1'b1;

endmodule