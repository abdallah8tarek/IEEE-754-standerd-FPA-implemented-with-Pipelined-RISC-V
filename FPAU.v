module FPAU (FPUout,a,b,FPUControl,rs2E_0);
	
output reg [31:0] FPUout;
input [3:0] FPUControl;
input [31:0] a,b;
input rs2E_0;  //to differentiate convert to signed --> rs2E_0 = 1'b0 
				//from convert to unsigned --> rs2E_0 = 1'b1

// [31] --> s   // [30:23] --> Exponant   // [22:0] --> Mantiss
wire [7:0] a_expo = a[30:23];
wire a_sign = a[31];
wire [22:0] a_mant = a[22:0];
wire [7:0] b_expo = b[30:23];
reg b_sign;// to be equaled b[31] if add and ~b[31] if sub
wire [22:0] b_mant = b[22:0];

reg [23:0] temp;
reg [54:0] temp_conv;
reg [22:0] temp_ab;
always @(*) 
begin
	temp = 23'd0;
	temp_conv = {31'd0,1'b1,a_mant};
	temp_ab = 22'd0;
	if (FPUControl == 4'd1) //sub
		b_sign = ~b[31];
	else
		b_sign = b[31];
	case (FPUControl)
	4'd0,4'd1:	begin	//a'd0 addition & no op. (ALU op.)  ////4'd1 subtraction 
					//adding to +0 or -0
					if ({a_expo,a_mant} == 31'd0)
						FPUout = b;
					else if ({b_expo,b_mant} == 31'd0)
						FPUout = a;
					
					//NAN flag
					else if (((a_expo == 8'hff) && (a_mant != 23'd0)) || ((b_expo == 8'hff) && (b_mant != 23'd0)))
						FPUout = {1'b0,8'hff,23'd1}; //NAN OUTPUT 32'hFFFFFFFF
					
					//adding to +infinity or -infinity
					else if ((a_expo == 8'hff) && (a_mant == 23'd0))
						begin
							if (((b_expo == 8'hff) && (b_mant == 23'd0)))
								begin
									if (a_sign == b_sign)
										FPUout = a; //out = + or - infinity
									else
										FPUout = {1'b0,8'b11111111,23'd1}; //NAN OUTPUT 32'hFFFFFFFF	//FPUout = {a_sign,31'd0}; //out = +or-0
								end
							else
								FPUout = a; //out = + or - infinity		
						end
					else if ((b_expo == 8'hff) && (b_mant == 23'd0))
						FPUout = b; //out = + or - infinity		
					
					//a and b are impliced normalized or denormalized (pure fractional) form
					else if (a_expo == b_expo)
					begin
						if (a_sign == b_sign)
							begin
								temp = a_mant + b_mant;
								if (b_expo != 8'd0)	
									FPUout = {b_sign,(b_expo+8'd1),temp[23:1]};
								else
									begin
										if (temp[23])
											FPUout = {b_sign,8'd1,temp[22:0]};
										else
											FPUout = {b_sign,b_expo,temp[22:0]};
									end
							end
						else // (a_sign != b_sign)  +-1.0  +  -+1.0
								begin
									if (b_mant > a_mant)
										begin
											temp = b_mant - a_mant;
											FPUout = {b_sign,norm_out(b_expo,temp[22:0])};
										end
									else if (b_mant < a_mant)
										begin
											temp = a_mant - b_mant;
											FPUout = {a_sign,norm_out(b_expo,temp[22:0])};
										end
									else //+-a == -+b --> out = +or-0
										FPUout = {a_sign,31'd0};
								end
					end
					else if (a_expo > b_expo)
					begin
						if ((b_expo && ((a_expo-b_expo) >= 8'd24)) || (!(b_expo) && (a_expo >= 8'd23)))
							FPUout = a;
						else
							begin
								if (b_expo == 8'd0)
									begin
										case (a_expo) //synopsis full_case
										8'd1  : temp_ab = b_mant;
										8'd2  : temp_ab = (b_mant>>1);
										8'd3  : temp_ab = (b_mant>>2);
										8'd4  : temp_ab = (b_mant>>3);
										8'd5  : temp_ab = (b_mant>>4);
										8'd6  : temp_ab = (b_mant>>5);
										8'd7  : temp_ab = (b_mant>>6);
										8'd8  : temp_ab = (b_mant>>7);
										8'd9  : temp_ab = (b_mant>>8);
										8'd10 : temp_ab = (b_mant>>9);
										8'd11 : temp_ab = (b_mant>>10);
										8'd12 : temp_ab = (b_mant>>11);
										8'd13 : temp_ab = (b_mant>>12);
										8'd14 : temp_ab = (b_mant>>13);
										8'd15 : temp_ab = (b_mant>>14);
										8'd16 : temp_ab = (b_mant>>15);
										8'd17 : temp_ab = (b_mant>>16);
										8'd18 : temp_ab = (b_mant>>17);
										8'd19 : temp_ab = (b_mant>>18);
										8'd20 : temp_ab = (b_mant>>19);
										8'd21 : temp_ab = (b_mant>>20);
										8'd22 : temp_ab = (b_mant>>21);
										endcase
									end
								else
									begin
										case (a_expo - b_expo) //synopsis full_case
										8'd1  : temp_ab = ({1'b1,b_mant[22:1]});
										8'd2  : temp_ab = ({1'b1,b_mant[22:1]}>>1);
										8'd3  : temp_ab = ({1'b1,b_mant[22:1]}>>2);
										8'd4  : temp_ab = ({1'b1,b_mant[22:1]}>>3);
										8'd5  : temp_ab = ({1'b1,b_mant[22:1]}>>4);
										8'd6  : temp_ab = ({1'b1,b_mant[22:1]}>>5);
										8'd7  : temp_ab = ({1'b1,b_mant[22:1]}>>6);
										8'd8  : temp_ab = ({1'b1,b_mant[22:1]}>>7);
										8'd9  : temp_ab = ({1'b1,b_mant[22:1]}>>8);
										8'd10 : temp_ab = ({1'b1,b_mant[22:1]}>>9);
										8'd11 : temp_ab = ({1'b1,b_mant[22:1]}>>10);
										8'd12 : temp_ab = ({1'b1,b_mant[22:1]}>>11);
										8'd13 : temp_ab = ({1'b1,b_mant[22:1]}>>12);
										8'd14 : temp_ab = ({1'b1,b_mant[22:1]}>>13);
										8'd15 : temp_ab = ({1'b1,b_mant[22:1]}>>14);
										8'd16 : temp_ab = ({1'b1,b_mant[22:1]}>>16);
										8'd18 : temp_ab = ({1'b1,b_mant[22:1]}>>17);
										8'd19 : temp_ab = ({1'b1,b_mant[22:1]}>>18);
										8'd20 : temp_ab = ({1'b1,b_mant[22:1]}>>29);
										8'd21 : temp_ab = ({1'b1,b_mant[22:1]}>>20);
										8'd22 : temp_ab = ({1'b1,b_mant[22:1]}>>21);
										8'd23 : temp_ab = ({1'b1,b_mant[22:1]}>>22);
										endcase
									end
								if (a_sign == b_sign)
									begin
										temp = a_mant + temp_ab;
										if (temp[23])
											FPUout = {a_sign,(a_expo+8'd1),{1'b0},temp[22:1]};
										else
											FPUout = {a_sign,a_expo,temp[22:0]};
									end
								else 
									begin
										temp = {1'b1,a_mant} - {1'b0,temp_ab};
										if (temp[23])
											FPUout = {a_sign,a_expo,temp[22:0]};
										else
											FPUout = {a_sign,(a_expo-8'd1),temp[21:0],1'b0};
									end
							end
					end
					else if (b_expo > a_expo)
					begin
						if ((a_expo && ((b_expo-a_expo) >= 8'd24)) || (!(a_expo) && (b_expo >= 8'd23)))
							FPUout = b;
						else
							begin
								if (a_expo == 8'd0)
									begin
										case (b_expo) //synopsis full_case
										8'd1  : temp_ab = a_mant;
										8'd2  : temp_ab = (a_mant>>1);
										8'd3  : temp_ab = (a_mant>>2);
										8'd4  : temp_ab = (a_mant>>3);
										8'd5  : temp_ab = (a_mant>>4);
										8'd6  : temp_ab = (a_mant>>5);
										8'd7  : temp_ab = (a_mant>>6);
										8'd8  : temp_ab = (a_mant>>7);
										8'd9  : temp_ab = (a_mant>>8);
										8'd10 : temp_ab = (a_mant>>9);
										8'd11 : temp_ab = (a_mant>>10);
										8'd12 : temp_ab = (a_mant>>11);
										8'd13 : temp_ab = (a_mant>>12);
										8'd14 : temp_ab = (a_mant>>13);
										8'd15 : temp_ab = (a_mant>>14);
										8'd16 : temp_ab = (a_mant>>15);
										8'd17 : temp_ab = (a_mant>>16);
										8'd18 : temp_ab = (a_mant>>17);
										8'd19 : temp_ab = (a_mant>>18);
										8'd20 : temp_ab = (a_mant>>19);
										8'd21 : temp_ab = (a_mant>>20);
										8'd22 : temp_ab = (a_mant>>21);
										endcase
									end
								else
									begin
										case (b_expo - a_expo) //synopsis full_case
										8'd1  : temp_ab = ({1'b1,a_mant[22:1]});
										8'd2  : temp_ab = ({1'b1,a_mant[22:1]}>>1);
										8'd3  : temp_ab = ({1'b1,a_mant[22:1]}>>2);
										8'd4  : temp_ab = ({1'b1,a_mant[22:1]}>>3);
										8'd5  : temp_ab = ({1'b1,a_mant[22:1]}>>4);
										8'd6  : temp_ab = ({1'b1,a_mant[22:1]}>>5);
										8'd7  : temp_ab = ({1'b1,a_mant[22:1]}>>6);
										8'd8  : temp_ab = ({1'b1,a_mant[22:1]}>>7);
										8'd9  : temp_ab = ({1'b1,a_mant[22:1]}>>8);
										8'd10 : temp_ab = ({1'b1,a_mant[22:1]}>>9);
										8'd11 : temp_ab = ({1'b1,a_mant[22:1]}>>10);
										8'd12 : temp_ab = ({1'b1,a_mant[22:1]}>>11);
										8'd13 : temp_ab = ({1'b1,a_mant[22:1]}>>12);
										8'd14 : temp_ab = ({1'b1,a_mant[22:1]}>>13);
										8'd15 : temp_ab = ({1'b1,a_mant[22:1]}>>14);
										8'd16 : temp_ab = ({1'b1,a_mant[22:1]}>>16);
										8'd18 : temp_ab = ({1'b1,a_mant[22:1]}>>17);
										8'd19 : temp_ab = ({1'b1,a_mant[22:1]}>>18);
										8'd20 : temp_ab = ({1'b1,a_mant[22:1]}>>29);
										8'd21 : temp_ab = ({1'b1,a_mant[22:1]}>>20);
										8'd22 : temp_ab = ({1'b1,a_mant[22:1]}>>21);
										8'd23 : temp_ab = ({1'b1,a_mant[22:1]}>>22);
										endcase
									end
								if (a_sign == b_sign)
									begin
										temp = b_mant + temp_ab;
										if (temp[23])
											FPUout = {b_sign,(b_expo+8'd1),{1'b0},temp[22:1]};
										else
											FPUout = {b_sign,b_expo,temp[22:0]};
									end
								else 
									begin
										temp = {1'b1,b_mant} - {1'b0,temp_ab};
										if (temp[23])
											FPUout = {b_sign,b_expo,temp[22:0]};
										else
											FPUout = {b_sign,(b_expo-8'd1),temp[21:0],1'b0};
									end
							end
					end	
			end
	4'd2  : FPUout = {b[31],a[30:0]};   //sign_inject
	4'd3  : FPUout = {(~b[31]),a[30:0]};   //neg_sign_inject
	4'd4  : FPUout = {(b[31] ^ a[31]),a[30:0]};   //xor_sign_inject
	4'd5  : FPUout = ({(~a[31]),a[30:0]} < {(~b[31]),b[30:0]}) ? b : a;  //max
	4'd6  : FPUout = ({(~a[31]),a[30:0]} < {(~b[31]),b[30:0]}) ? a : b;  //min
	4'd7  : FPUout = (a == b) ? 32'd1 : 32'd0;	//compare (a == b)
	4'd8  : FPUout = (a < b) ? 32'd1 : 32'd0;	//compare (a < b)
	4'd9  : FPUout = (a <= b) ? 32'd1 : 32'd0;  //compare (a <= b)
	4'd10 : FPUout = a;	//mov_to_int_reg
	4'd11 : //convert_float_to_unsigned_or_signed_int --> rm --> rounding to zero
	begin 
		//[fraction 1.0*2^(neg) or 0.0*2(neg)] or negative number or out of range
		if ((a_expo < 8'd127) | (((a_sign == 1) | (a_expo > 8'd181)) & rs2E_0) | ((a_expo > 8'd180)&(~rs2E_0)))
				FPUout = 32'd0;
		else	//unsigned --> (8'd128 <= a_expo <= 8'd181) ||| signed --> (8'd128 <= a_expo <= 8'd180) 
			begin
				temp_conv = temp_conv<<(a_expo[5:0]+1);
				temp_conv[54:23] = ((~rs2E_0) & a_sign) ? (~temp_conv[54:23])+1 : temp_conv[54:23];
				FPUout = temp_conv [54:23];
			end
	end
	4'd12: //convert_unsigned_or_signed_int_to_float --> rm --> rounding to zero
	begin   
		FPUout[31] = rs2E_0 ? 1'b0 : a_sign;
		temp_conv[54:23] = ((~rs2E_0) & a_sign) ? ~(a-32'd1) : a;
		if (temp_conv[54:23] > 32'd65536) //2^16
		begin
			if (temp_conv [54:39] > 32'd256) //2^8
			begin
				if (temp_conv[54:47] > 32'd16) //2^4
				begin
					if (temp_conv[54]) 
						FPUout[30:0] = {8'd158,temp_conv[53:31]};
					else if (temp_conv[53]) 
						FPUout[30:0] = {8'd157,temp_conv[52:30]};
					else if (temp_conv[52])
						FPUout[30:0] = {8'd156,temp_conv[51:29]};
					else 
						FPUout[30:0] = {8'd155,temp_conv[50:28]};
				end
				else
				begin
					if (temp_conv[50]) 
						FPUout[30:0] = {8'd154,temp_conv[49:27]};
					else if (temp_conv[49]) 
						FPUout[30:0] = {8'd153,temp_conv[48:26]};
					else if (temp_conv[48])
						FPUout[30:0] = {8'd152,temp_conv[47:25]};
					else 
						FPUout[30:0] = {8'd151,temp_conv[46:24]};
				end
			end
			else
			begin
				if (temp_conv[46:39] > 32'd16) //2^4
				begin
					if (temp_conv[46]) 
						FPUout[30:0] = {8'd150,temp_conv[45:23]};
					else if (temp_conv[45]) 
						FPUout[30:0] = {8'd149,temp_conv[44:23],1'd0};
					else if (temp_conv[44])
						FPUout[30:0] = {8'd148,temp_conv[43:23],2'd0};
					else 
						FPUout[30:0] = {8'd147,temp_conv[42:23],3'd0};
				end
				else
				begin
					if (temp_conv[42]) 
						FPUout[30:0] = {8'd146,temp_conv[41:23],4'd0};
					else if (temp_conv[41]) 
						FPUout[30:0] = {8'd145,temp_conv[40:23],5'd0};
					else if (temp_conv[40])
						FPUout[30:0] = {8'd144,temp_conv[39:23],6'd0};
					else 
						FPUout[30:0] = {8'd143,temp_conv[38:23],7'd0};
				end
			end
		end
		else
		begin
			if (temp_conv[38:23] > 32'd256) //2^8
			begin
				if (temp_conv[38:31] > 32'd16) //2^4
				begin
					if (temp_conv[38]) 
						FPUout[30:0] = {8'd142,temp_conv[37:23],8'd0};
					else if (temp_conv[37]) 
						FPUout[30:0] = {8'd141,temp_conv[36:23],9'd0};
					else if (temp_conv[36])
						FPUout[30:0] = {8'd140,temp_conv[35:23],10'd0};
					else 
						FPUout[30:0] = {8'd139,temp_conv[34:23],11'd0};
				end
				else
				begin
					if (temp_conv[34]) 
						FPUout[30:0] = {8'd138,temp_conv[33:23],12'd0};
					else if (temp_conv[33]) 
				FPUout[30:0] = {8'd137,temp_conv[32:23],13'd0};
					else if (temp_conv[32])
						FPUout[30:0] = {8'd136,temp_conv[31:23],14'd0};
					else 
						FPUout[30:0] = {8'd135,temp_conv[30:23],15'd0};
				end
			end
			else
			begin
				if (temp_conv[30:23] > 32'd16) //2^4
				begin
					if (temp_conv[30]) 
						FPUout[30:0] = {8'd134,temp_conv[29:23],16'd0};
					else if (temp_conv[29]) 
						FPUout[30:0] = {8'd133,temp_conv[28:23],17'd0};
					else if (temp_conv[28])
						FPUout[30:0] = {8'd132,temp_conv[27:23],18'd0};
					else
						FPUout[30:0] = {8'd131,temp_conv[26:23],19'd0};
				end
				else
				begin
					if (temp_conv[26]) 
						FPUout[30:0] = {8'd130,temp_conv[25:23],20'd0};
					else if (temp_conv[25]) 
						FPUout[30:0] = {8'd129,temp_conv[24:23],21'd0};
					else if (temp_conv[24])
						FPUout[30:0] = {8'd128,temp_conv[23],22'd0};
					else 
						FPUout[30:0] = {8'd127,23'd0};
				end
			end		
		end	
	end
	default : FPUout = 0;	
	endcase
end
	
function [30:0] norm_out;

input [7:0] unnorm_expo;
input [22:0] unnorm_mant;

if (unnorm_expo == 8'b0)
	norm_out = {8'b0,unnorm_mant}; 
else
begin
if (unnorm_mant[22] == 1'b1)
begin
	if ((unnorm_expo > 8'd1))
		norm_out = {(unnorm_expo - 8'd1),(unnorm_mant<<1)};
	else 
		norm_out = {(8'b0),unnorm_mant};
end

else if (unnorm_mant[21] == 1'b1)
begin
	if ((unnorm_expo > 8'd2))
		norm_out = {(unnorm_expo - 8'd2),(unnorm_mant<<2)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[20] == 1'b1)
begin
	if ((unnorm_expo > 8'd3))
		norm_out = {(unnorm_expo - 8'd3),(unnorm_mant<<3)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[19] == 1'b1)
begin
	if ((unnorm_expo > 8'd4))
		norm_out = {(unnorm_expo - 8'd4),(unnorm_mant<<4)};
	else
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[18] == 1'b1)
begin
	if ((unnorm_expo > 8'd5))
		norm_out = {(unnorm_expo - 8'd5),(unnorm_mant<<5)};
	else
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[17] == 1'b1)
begin
	if ((unnorm_expo > 8'd6))
		norm_out = {(unnorm_expo - 8'd6),(unnorm_mant<<6)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[16] == 1'b1)
begin
	if ((unnorm_expo > 8'd7))
		norm_out = {(unnorm_expo - 8'd7),(unnorm_mant<<7)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[15] == 1'b1)
begin
	if ((unnorm_expo > 8'd8))
		norm_out = {(unnorm_expo - 8'd8),(unnorm_mant<<8)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[14] == 1'b1)
begin
	if ((unnorm_expo > 8'd9))
		norm_out = {(unnorm_expo - 8'd9),(unnorm_mant<<9)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[13] == 1'b1)
begin
	if ((unnorm_expo > 8'd10))
		norm_out = {(unnorm_expo - 8'd10),(unnorm_mant<<10)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[12] == 1'b1)
begin
	if ((unnorm_expo > 8'd11))
		norm_out = {(unnorm_expo - 8'd11),(unnorm_mant<<11)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[11] == 1'b1)
begin
	if ((unnorm_expo > 8'd12))
		norm_out = {(unnorm_expo - 8'd12),(unnorm_mant<<12)};
	else
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[10] == 1'b1)
begin
	if ((unnorm_expo > 8'd13))
		norm_out = {(unnorm_expo - 8'd13),(unnorm_mant<<13)};
	else
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[9] == 1'b1)
begin
	if ((unnorm_expo > 8'd14))
		norm_out = {(unnorm_expo - 8'd14),(unnorm_mant<<14)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[8] == 1'b1)
begin
	if ((unnorm_expo > 8'd15))
		norm_out = {(unnorm_expo - 8'd15),(unnorm_mant<<15)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[7] == 1'b1)
begin
	if ((unnorm_expo > 8'd16))
		norm_out = {(unnorm_expo - 8'd16),(unnorm_mant<<16)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[6] == 1'b1)
begin
	if ((unnorm_expo > 8'd17))
		norm_out = {(unnorm_expo - 8'd17),(unnorm_mant<<17)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[5] == 1'b1)
begin
	if ((unnorm_expo > 8'd18))
		norm_out = {(unnorm_expo - 8'd18),(unnorm_mant<<18)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[4] == 1'b1)
begin
	if ((unnorm_expo > 8'd19))
		norm_out = {(unnorm_expo - 8'd19),(unnorm_mant<<19)};
	else
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[3] == 1'b1)
begin
	if ((unnorm_expo > 8'd20))
		norm_out = {(unnorm_expo - 8'd20),(unnorm_mant<<20)};
	else
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[2] == 1'b1)
begin
	if ((unnorm_expo > 8'd21))
		norm_out = {(unnorm_expo - 8'd21),(unnorm_mant<<21)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else if (unnorm_mant[1] == 1'b1)
begin
	if ((unnorm_expo > 8'd22))
		norm_out = {(unnorm_expo - 8'd22),(unnorm_mant<<22)};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end

else //if (unnorm_mant[0] == 1'b1)
begin
	if ((unnorm_expo > 8'd23))
		norm_out = {(unnorm_expo - 8'd23),23'd0};
	else 
		norm_out = {(8'b0),(unnorm_mant<<unnorm_expo-1)};
end
end

endfunction
endmodule