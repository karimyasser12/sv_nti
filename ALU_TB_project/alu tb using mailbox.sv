
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
  parameter N = 10;
////////////////////////////
typedef struct {logic [31:0] a; logic [31:0] b; logic [31:0] alu_fn;} data_struct;
typedef struct {bit ar_f; bit car_f; bit cmp_f; bit shift_f; bit log_f; logic [31:0] alu_Out;} data_struct_check;
///////////////////////////
mailbox #(data_struct)        mb  = new();
mailbox #(data_struct)        mb1 = new();
mailbox #(data_struct_check)  mb2 = new();
mailbox #(data_struct_check)  mb3 = new();
mailbox #(data_struct)        mb4 = new();
///////////////////////////
initial     CLK=0;
always  #10 CLK= ~CLK;
ALU_16B DUT (.A(A),.B(B),.ALU_OUT(ALU_OUT),.Arith_Flag(Arith_Flag),.Carry_Flag(Carry_Flag),.Logic_Flag(Logic_Flag),.CMP_Flag(CMP_Flag),.Shift_Flag(Shift_Flag),.CLK(CLK),.ALU_FUN(ALU_FUN));
/////////////////////////////////
task generator();
    data_struct packet;
    repeat(N+1) begin
        @(posedge CLK);
        packet.a=$urandom_range(0,65535);
        packet.b=$urandom_range(0,65535);
        packet.alu_fn=$urandom_range(0,15);
        mb.put(packet);
    end
endtask
/////////////////////////////////
task driver();
    data_struct packet2;
    forever begin
        @(negedge CLK);
        mb.get(packet2);
        A=packet2.a;
        B=packet2.b;
        ALU_FUN=packet2.alu_fn;
    end
endtask
/////////////////////////////////
task monitor1();
    data_struct packet;
    forever begin
        @(posedge CLK);
        packet.a=A;
        packet.b=B;
        packet.alu_fn=ALU_FUN;
        mb1.put(packet);
        mb4.put(packet);
        $display("input one is :%0d input two is :%0d alu_fun is :%0d",packet.a,packet.b,packet.alu_fn);
    end
endtask
/////////////////////////////////
task monitor2();
    data_struct_check packet;
    forever begin
        @(posedge CLK);
        #1;
        packet.ar_f=Arith_Flag;
        packet.car_f=Carry_Flag;
        packet.cmp_f=CMP_Flag;
        packet.shift_f=Shift_Flag;
        packet.log_f=Logic_Flag;
        packet.alu_Out=ALU_OUT;
        mb2.put(packet);
        $display("arith flag :%0d carry flag :%0d cmp flag :%0d shift flag : %0d logic flag : %0d alu out :%0d",packet.ar_f,packet.car_f,packet.cmp_f,packet.shift_f,packet.log_f,packet.alu_Out);
    end
endtask
/////////////////////////////////
task predictor();
    bit [15:0]alu_out;
    logic arith;
    logic carry;
    logic cmp;
    logic shift;
    logic logic_F;
    bit[16:0] wide_out;
    bit[31:0] mult_temp;
    data_struct packet_mon1;
    data_struct_check packet_checker;
    forever begin
        @(negedge CLK);
        mb1.get(packet_mon1);

        arith =1'b0 ;
        logic_F=1'b0 ;
        cmp=1'b0 ;
        shift=1'b0 ;
        carry=1'b0 ;
        alu_out=1'b0 ;

        case(packet_mon1.alu_fn)
        4'b0000:begin
            wide_out=packet_mon1.a+packet_mon1.b;
            {carry,alu_out}=wide_out;
            arith=1;
        end
        4'b0001:begin
            wide_out=packet_mon1.a-packet_mon1.b;
            carry=wide_out[16];
            alu_out=wide_out[15:0];
            arith=1;
        end
        4'b0010:begin
            mult_temp=packet_mon1.a*packet_mon1.b;
            alu_out=mult_temp[15:0];
            arith=1;
        end
        4'b0011:begin
            alu_out=packet_mon1.a/packet_mon1.b;
            arith=1;
        end
        4'b0100:begin
            alu_out=packet_mon1.a&packet_mon1.b;
            logic_F = 1'b1 ;
        end
        4'b0101: begin
            alu_out=packet_mon1.a | packet_mon1.b;
            logic_F = 1'b1 ;
        end
        4'b0110: begin
            alu_out= ~ (packet_mon1.a & packet_mon1.b);
            logic_F = 1'b1 ;
        end
        4'b0111: begin
            alu_out = ~ (packet_mon1.a | packet_mon1.b);
            logic_F= 1'b1 ;
        end
        4'b1000: begin
            alu_out=  (packet_mon1.a ^ packet_mon1.b);
            logic_F=1'b1 ;
        end
        4'b1001: begin
            alu_out= ~ (packet_mon1.a ^ packet_mon1.b);
            logic_F=1'b1 ;
        end
        4'b1010: begin
            cmp=1'b1 ;
            if (packet_mon1.a==packet_mon1.b)
            alu_out= 16'b1;
            else
            alu_out= 16'b0;
        end
        4'b1011: begin
            cmp= 1'b1 ;
            if (packet_mon1.a > packet_mon1.b)
            alu_out= 16'b10;
            else
            alu_out= 16'b0;
        end
        4'b1100: begin
            cmp= 1'b1;
            if (packet_mon1.a < packet_mon1.b)
            alu_out= 16'b11;
            else
            alu_out = 16'b0;
        end
        4'b1101: begin
            shift=1'b1;
            alu_out=packet_mon1.a>>1;
        end
        4'b1110: begin
            shift = 1'b1 ;
            alu_out= packet_mon1.a<<1;
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
        packet_checker.ar_f=arith;
        packet_checker.cmp_f=cmp;
        packet_checker.shift_f=shift;
        packet_checker.log_f=logic_F;
        packet_checker.alu_Out=alu_out;
        packet_checker.car_f=carry;
        mb3.put(packet_checker);
    end
endtask
/////////////////////////////////
task check();
    data_struct       packet_alu_in;
    data_struct_check packet_alu_out;
    data_struct_check packet_golden;
    forever begin
        @(negedge CLK);
        #1;
        mb2.get(packet_alu_out);
        mb3.get(packet_golden);
        mb4.get(packet_alu_in);
        if(  packet_alu_out.car_f    == packet_golden.car_f    &&
             packet_alu_out.ar_f     == packet_golden.ar_f     &&
             packet_alu_out.log_f    == packet_golden.log_f    &&
             packet_alu_out.cmp_f    == packet_golden.cmp_f    &&
             packet_alu_out.shift_f  == packet_golden.shift_f  &&
             packet_alu_out.alu_Out  == packet_golden.alu_Out)
            $display("test passed FUN=%0d A=%0d B=%0d OUT=%0d",
                        packet_alu_in.alu_fn, packet_alu_in.a, packet_alu_in.b, packet_alu_out.alu_Out);
        else
        begin
            $display("test failed FUN=%0d A=%0d B=%0d", packet_alu_in.alu_fn, packet_alu_in.a, packet_alu_in.b);
            $display("predicted out=%0d flags arith,carry,cmp,shift,logic=%b%b%b%b%b",
                   packet_golden.alu_Out, packet_golden.ar_f, packet_golden.car_f, packet_golden.cmp_f, packet_golden.shift_f, packet_golden.log_f);
            $display("actual out=%0d flags arith,carry,cmp,shift,logic=%b%b%b%b%b",
                    packet_alu_out.alu_Out, packet_alu_out.ar_f, packet_alu_out.car_f, packet_alu_out.cmp_f, packet_alu_out.shift_f, packet_alu_out.log_f);
        end
    end
endtask
/////////////////////////////////
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