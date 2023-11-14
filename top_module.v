`include "datapath.v"
`include "memory_system.v"
`include "control_unit.v"
module top_module (clk,pc_out,instr,reset_ms,reset);

input clk,reset_ms,reset;
input [31:0] instr;
output [31:0] pc_out;

wire [31:0] write_data,read_data,alu_result;
wire write_en,read_en,stall;

//memory_system (clk,mem_read,mem_write,reset,add_in,data_in,stall,data_out);
memory_system ms(.clk(clk),
				 .mem_read(read_en),
				 .mem_write(write_en),
				 .reset(reset_ms),
				 .add_in(alu_result),
				 .data_in(write_data),
				 .stall(stall),
				 .data_out(read_data));

//control_unit (instr,result_sel,mem_write,alu_sel,imm_sel
//				,mem_read,reg_write,alu_control,fpu_control
//				,jalr_sel,bne_beq_sel,jump,branch,rd1_selD
//				,rd2_selD,rdW_selD,reg_writeD_sel,sourceAB_sel_D);
wire alu_sel,mem_read,reg_write,jalr_sel,bne_beq_sel,jump,branch,mem_write;
wire [1:0] result_sel,imm_sel;
wire [2:0] alu_control;
wire [3:0] fpu_control;
wire [31:0] instrD;
wire rd1_selD,rd2_selD,rdW_selD,reg_writeD_sel,sourceAB_sel_D;
control_unit c1(.instr(instrD),
				.result_sel(result_sel),
				.mem_write(mem_write),
				.alu_sel(alu_sel),
				.imm_sel(imm_sel),
				.mem_read(mem_read),
				.reg_write(reg_write),
				.alu_control(alu_control),
				.fpu_control(fpu_control),
				.jalr_sel(jalr_sel),
				.bne_beq_sel(bne_beq_sel),
				.jump(jump),
				.branch(branch),
				.rd1_selD(rd1_selD),
				.rd2_selD(rd2_selD),
				.rdW_selD(rdW_selD),
				.reg_writeD_sel(reg_writeD_sel),
				.sourceAB_sel_D(sourceAB_sel_D));

//datapath (instr,instrD,read_data,clk,reset
//			,mem_read,reg_write,alu_sel,alu_control
//			,fpu_control,result_sel,imm_sel,pc_out
//			,alu_result_out,write_dataM,jalr_sel,bne_beq_sel
//			,jump,branch,mem_write,mem_writeM,mem_readM,stall
//			,rd1_selD,rd2_selD,rdW_selD,reg_writeD_sel,sourceAB_sel_D);
datapath d1(.instr(instr),
			.instrD(instrD),
			.read_data(read_data),
			.clk(clk),
			.reset(reset),
			.mem_read(mem_read),
			.reg_write(reg_write),
			.alu_sel(alu_sel),
			.alu_control(alu_control),
			.fpu_control(fpu_control),
			.result_sel(result_sel),
			.imm_sel(imm_sel),
			.pc_out(pc_out),
			.alu_result_out(alu_result),
			.write_dataM(write_data),
			.jalr_sel(jalr_sel),
			.bne_beq_sel(bne_beq_sel),
			.jump(jump),
			.branch(branch),
			.mem_write(mem_write),
			.mem_writeM(write_en),
			.mem_readM(read_en),
			.stall(stall),
			.rd1_selD(rd1_selD),
			.rd2_selD(rd2_selD),
			.rdW_selD(rdW_selD),
			.reg_writeD_sel(reg_writeD_sel),
			.sourceAB_sel_D(sourceAB_sel_D));   //remove read_en in case of normal ram or mem
endmodule