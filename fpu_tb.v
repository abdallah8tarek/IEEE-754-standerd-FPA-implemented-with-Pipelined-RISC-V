module fpu_tb ();

reg [31:0] a;
reg [31:0] b;
reg [2:0] FPUControl;
wire [31:0] FPUout;
wire tt;

reg [31:0] FPUout_expected;

localparam t = 10; 
 
FPU ff(FPUout,a,b,FPUControl,);

//test ADD
initial
begin
FPUControl = 3'b000; //ADD
//test a + (+or- zero)
a = 32'b0_00001001_00000000000000000001111; 
b = 32'd0;
FPUout_expected = a;
#t
if (FPUout == FPUout_expected)
	$display ("the test a + (+or- zero) succeded");
else
	$display ("the test a + (+or- zero) falid and the out is : %b", FPUout);

//test a + (+or- zero)
a = 32'b0_00001001_00000000000000000001111; 
b = 32'd0;
FPUout_expected = a;
#t
if (FPUout == FPUout_expected)
	$display ("the test a + (+or- zero) succeded");
else
	$display ("the test a + (+or- zero) falid and the out is : %b", FPUout);

//test a + NAN
a = 32'b0_00001001_00000000000000000001111; 
b = 32'b0_11111111_00000000000000000001111; 
FPUout_expected = 32'b0_11111111_00000000000000000000001; // NAN
#t
if ((FPUout [30:23] == FPUout_expected [30:23]) & (FPUout [22:0] != 23'd0)) // if out = NAN
	$display ("the test a + NAN succeded");
else
	$display ("the test a + NAN falid and the out is : %b", FPUout);
		
//test a + (+or- inifity)
a = 32'b0_00001001_00000000000000000001111; 
b = 32'b0_11111111_00000000000000000000000;
FPUout_expected = b;
#t
if (FPUout == FPUout_expected)
	$display ("the test a + (+or- inifity) succeded");
else
	$display ("the test a + (+or- inifity) falid and the out is : %b", FPUout);
	
//test b + (+or- inifity)
b = 32'b0_00001001_00000000000000000001111; 
a = 32'b0_11111111_00000000000000000000000;
FPUout_expected = a;
#t
if (FPUout == FPUout_expected)
	$display ("the test b + (+or- inifity) succeded");
else
	$display ("the test b + (+or- inifity) falid and the out is : %b", FPUout);
	
//test (+or- inifity) + (+or- inifity)
a = 32'b0_11111111_00000000000000000000000;
b = 32'b0_11111111_00000000000000000000000;
FPUout_expected = a;
#t
if (FPUout == FPUout_expected)
	$display ("the test (+or- inifity) + (+or- inifity) succeded");
else
	$display ("the test (+or- inifity) + (+or- inifity) falid and the out is : %b", FPUout);
	
//test (+or- inifity) + (-or+ inifity)
a = 32'b0_11111111_00000000000000000000000;
b = 32'b1_11111111_00000000000000000000000;
FPUout_expected = 32'b0_11111111_00000000000000000000001; //NAN
#t
if ((FPUout [30:23] == FPUout_expected [30:23]) & (FPUout [22:0] != 23'd0)) // if out = NAN
	$display ("the test (+or- inifity) + (-or+ inifity) succeded");
else
	$display ("the test (+or- inifity) + (-or+ inifity) falid and the out is : %b", FPUout);



//test a_expo = b_expo !=0 --> (+-1.) + (+-1.) --> no overflow
a = 32'b0_00001001_00000000000000000000001; 
b = 32'b0_00001001_00000000000000000000001; 
FPUout_expected = 32'b0_00001010_00000000000000000000001;
#t
if (FPUout == FPUout_expected)
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (+-1.) --> no overflow succeded");
else
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (+-1.) --> no overflow falid and the out is : %b", FPUout);
	
	

//test a_expo = b_expo !=0 --> (+-1.) + (+-1.) --> overflow
a = 32'b0_00001001_11111111111111111111111; 
b = 32'b0_00001001_00000000000000000000001; 
FPUout_expected = 32'b0_00001010_10000000000000000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (+-1.) --> overflow succeded");
else
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (+-1.) --> overflow falid and the out is : %b", FPUout);
	
	

//test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (+>-) and test normalize --> expo < shift
a = 32'b0_00001001_00000000000000000000011; 
b = 32'b1_00001001_00000000000000000000001; 
FPUout_expected = 32'b0_00000000_00000000000001000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (+>-) and test normalize --> expo < shift succeded");
else
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (+>-) and test normalize --> expo < shift falid and the out is : %b", FPUout);



//test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (+>-) and test normalize --> expo > shift
a = 32'b0_00100010_00000000000000000000011; 
b = 32'b1_00100010_00000000000000000000001; 
FPUout_expected = 32'b0_00001100_00000000000000000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (+>-) and test normalize --> expo > shift succeded");
else
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (+>-) and test normalize --> expo > shift falid and the out is : %b", FPUout);
	
	
//test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (->+) and test normalize --> expo > shift
a = 32'b1_00100010_00000000000000000000011; 
b = 32'b0_00100010_00000000000000000000001; 
FPUout_expected = 32'b1_00001100_00000000000000000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (->+) and test normalize --> expo > shift succeded");
else
	$display ("the test a_expo = b_expo !=0 --> (+-1.) + (-+1.) -->  (->+) and test normalize --> expo > shift falid and the out is : %b", FPUout);
	
	
//test a_expo = b_expo = 0 --> (+-0.) + (-+0.) -->  (->+) or (+>-) tested with a_expo = b_expo !=0 --> (+-1.) + (-+1.)

//test a_expo = b_expo = 0 --> (+-0.) + (+-0.) no overflow
a = 32'b0_00000000_00000000000000000000011; 
b = 32'b0_00000000_00000000000000000000001; 
FPUout_expected = 32'b0_00000000_00000000000000000000100;
#t
if (FPUout == FPUout_expected)
	$display ("the test a_expo = b_expo = 0 --> (+-0.) + (+-0.) no overflow succeded");
else
	$display ("the test a_expo = b_expo = 0 --> (+-0.) + (+-0.) no overflow falid and the out is : %b", FPUout);


//test a_expo = b_expo = 0 --> (+-0.) + (+-0.) overflow
a = 32'b0_00000000_11111111111111111111111; 
b = 32'b0_00000000_00000000000000000000001; 
FPUout_expected = 32'b0_00000001_00000000000000000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test a_expo = b_expo = 0 --> (+-0.) + (+-0.) overflow succeded");
else
	$display ("the test a_expo = b_expo = 0 --> (+-0.) + (+-0.) overflow falid and the out is : %b", FPUout);
	


//test [a_expo > b_expo] & [b_expo= 0] & [a_expo >= 23]
a = 32'b0_00100000_11111111111111111111111; 
b = 32'b0_00000000_00000000000000000000001; 
FPUout_expected = a;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo >= 23] succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo >= 23] falid and the out is : %b", FPUout);



//test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) overflow
a = 32'b0_00000010_11111111111111111111111; 
b = 32'b0_00000000_00000000000000000000100; 
FPUout_expected = 32'b0_00000011_00000000000000000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) overflow succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) overflow falid and the out is : %b", FPUout);


//test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) no overflow
a = 32'b0_00000010_11111111111111111111000; 
b = 32'b0_00000000_00000000000000000000100; 
FPUout_expected = 32'b0_00000010_11111111111111111111010;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) no overflow succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) no overflow falid and the out is : %b", FPUout);


//test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (-+0.) no borrow
a = 32'b0_00000010_11111111111111111111000; 
b = 32'b1_00000000_00000000000000000100000; 
FPUout_expected = 32'b0_00000010_11111111111111111101000;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) no borrow succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) no borrow falid and the out is : %b", FPUout);


//test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (-+0.) borrow
a = 32'b0_00000010_00000000000000000000000; 
b = 32'b1_00000000_10000000000000000000000; 
FPUout_expected = 32'b0_00000001_10000000000000000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) borrow succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo= 0] & [a_expo < 23] --> (+-1.) + (+-0.) borrow falid and the out is : %b", FPUout);	
	

//test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo >= 24]
a = 32'b0_00100000_11111111111111111111111;
b = 32'b0_00000100_00000000000000000000001;
FPUout_expected = a;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_exp!o= 0] & [a_expo-b_expo >= 24] succeded");
else
	$display ("the test [a_expo > b_expo] & [b_exp!o= 0] & [a_expo-b_expo >= 24] falid and the out is : %b", FPUout);



//test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) overflow
a = 32'b0_00000110_11111111111111111111111; 
b = 32'b0_00000100_00000000000000000000100; 
FPUout_expected = 32'b0_00000111_00100000000000000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) overflow succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) overflow falid and the out is : %b", FPUout);


//test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) no overflow
a = 32'b0_00000110_10111111111111111111000; 
b = 32'b0_00000100_00000000000000000000100; 
FPUout_expected = 32'b0_00000110_11111111111111111111001;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) no overflow succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) no overflow falid and the out is : %b", FPUout);


//test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (-+0.) no borrow
a = 32'b0_00000110_11111111111111111111000; 
b = 32'b1_00000100_00000000000000000100000; 
FPUout_expected = 32'b0_00000110_10111111111111111110000;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) no borrow succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) no borrow falid and the out is : %b", FPUout);


//test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (-+0.) borrow
a = 32'b0_00000110_00000000000000000000000; 
b = 32'b1_00000100_00000000000000000000000; 
FPUout_expected = 32'b0_00000101_10000000000000000000000;
#t
if (FPUout == FPUout_expected)
	$display ("the test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) borrow succeded");
else
	$display ("the test [a_expo > b_expo] & [b_expo!= 0] & [a_expo-b_expo < 24] --> (+-1.) + (+-0.) borrow falid and the out is : %b", FPUout);

$stop;
end




endmodule
