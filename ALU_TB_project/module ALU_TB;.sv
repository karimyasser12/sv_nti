// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
module ALU_TB;
  logic [15:0] A, B;
  logic [3:0]  ALU_FUN;
  logic        CLK;
  logic        Arith_Flag;
  logic        Carry_Flag;   
  logic        Logic_Flag; 
  logic        CMP_Flag;
  logic        Shift_Flag;
  logic [15:0] ALU_OUT;
  parameter N=10;
////////////////////////////
    bit[15:0] in1;        //generator dec
    bit[15:0] in2;
    bit[3:0] in_fun;
    bit[15:0] a;         //monitor 1 out
    bit[15:0] b;
    bit[3:0] in_Fun;
    bit[15:0] alu_out_mon;  //monitor 2 dec
    logic arith_FL;
    logic carry_FL;
    logic cmp_FL;
    logic shift_FL;
    logic logic_FL;
    bit [15:0]alu_out;       //golden dec
    logic arith;
    logic carry;
    logic cmp;
    logic shift;
    logic logic_F; 
    bit[16:0] wide_out;
    bit[31:0] mult_temp;
////////////////////////////////
initial     CLK=0;
always  #10 CLK= ~CLK;
ALU_16B DUT (.A(A),.B(B),.ALU_OUT(ALU_OUT),.Arith_Flag(Arith_Flag),.Carry_Flag(Carry_Flag),.Logic_Flag(Logic_Flag),.CMP_Flag(CMP_Flag),.Shift_Flag(Shift_Flag),.CLK(CLK),.ALU_FUN(ALU_FUN));
/////////////////////////////////
task generator();
  repeat(N+1) begin
@(posedge CLK);
    in1=$urandom_range(0,65535);
    in2=$urandom_range(0,65535);
    in_fun=$urandom_range(0,15);
end
endtask
/////////////////////////////////
task driver();
forever begin
@(negedge CLK); 
    A=in1;
    B=in2;
    ALU_FUN=in_fun;
end
endtask
/////////////////////////////////
task monitor1();
forever begin
@(posedge CLK);
    a=A;
    b=B;
    in_Fun=ALU_FUN;
$display("input one is :%0d input two is :%0d alu_fun is :%0d",a,b,in_Fun);
end
endtask
/////////////////////////////////
task monitor2();
forever begin
@(posedge CLK);
#1;
    arith_FL=Arith_Flag;
    carry_FL=Carry_Flag;
    cmp_FL=CMP_Flag;
    shift_FL=Shift_Flag;
    logic_FL=Logic_Flag;
    alu_out_mon=ALU_OUT;
$display("arith flag :%0d carry flag :%0d cmp flag :%0d shift flag : %0d logic flag : %0d alu out :%0d",arith_FL,carry_FL,cmp_FL,shift_FL,logic_FL,alu_out_mon);
end
endtask
////////////////////////////    
task predictor();
forever begin
@(negedge CLK);
     arith =1'b0 ;
     logic_F=1'b0 ; 
     cmp=1'b0 ;
     shift=1'b0 ;
	 carry=1'b0 ;
	 alu_out=1'b0 ;

case(in_Fun)
4'b0000:begin
    wide_out=a+b;
    {carry,alu_out}=wide_out;
    arith=1;
end
4'b0001:begin
    wide_out=a-b;
    carry=wide_out[16];
    alu_out=wide_out[15:0];
    arith=1;
end
4'b0010:begin
    mult_temp=a*b;
    alu_out=mult_temp[15:0];
    arith=1;
end
4'b0011:begin
    alu_out=a/b;
    arith=1;
end
4'b0100:begin
    alu_out=a&b;
	logic_F = 1'b1 ;
end
    4'b0101: begin
    alu_out=a | b;
	logic_F = 1'b1 ;
end
    4'b0110: begin
    alu_out= ~ (a & b);
	logic_F = 1'b1 ;
end
    4'b0111: begin
    alu_out = ~ (a | b);
	logic_F = 1'b1 ;
end     
    4'b1000: begin
    alu_out=  (a ^ b);
	logic_F=1'b1 ;
end
    4'b1001: begin
    alu_out= ~ (a ^ b);
	logic_F=1'b1 ;
end
  4'b1010: begin
	cmp=1'b1 ;
    if (a==b)
    alu_out= 16'b1;
    else
    alu_out= 16'b0;
end
    4'b1011: begin
	cmp= 1'b1 ;
    if (a>b)
    alu_out = 16'b10;
    else
    alu_out = 16'b0;
end 
    4'b1100: begin
	cmp= 1'b1;
    if (a<b)
    alu_out= 16'b11;
    else
    alu_out = 16'b0;
end      
    4'b1101: begin
	shift =1'b1;
    alu_out=a>>1;
end
    4'b1110: begin 
	shift = 1'b1 ;
    alu_out= a<<1;
end
default: begin
	carry= 1'b0 ;
	arith= 1'b0 ;
    logic_F= 1'b0 ; 
    cmp= 1'b0 ;
    shift= 1'b0 ;
    alu_out= 16'b0;
end
endcase
end
endtask
task check();
forever
begin 
@(negedge CLK);
#1;
if(alu_out==alu_out_mon && carry==carry_FL && arith==arith_FL && logic_F==logic_FL && cmp==cmp_FL && shift==shift_FL && alu_out == alu_out_mon)
    $display("test passed FUN=%0d A=%0d B=%0d OUT=%0d",
                in_Fun, a, b, alu_out_mon);
else
begin
     $display("test failed FUN=%0d A=%0d B=%0d", in_Fun, a, b);
      $display("predicted out=%0d flags arith,carry,cmp,shift,logic=%b%b%b%b%b",
               alu_out, arith, carry, cmp, shift, logic_F);
      $display("actual out=%0d flags arith,carry,cmp,shift,logic=%b%b%b%b%b",
               alu_out_mon, arith_FL, carry_FL, cmp_FL, shift_FL, logic_FL);
end
end
endtask
initial begin
  fork
    driver();
    monitor1();
    monitor2();
    predictor();
    check();
  join_none

  generator();
  $finish;
end
endmodule

