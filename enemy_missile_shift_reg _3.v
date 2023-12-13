module enemy_missile_shift_reg_3(
input clk,
output reg num_out
);


reg num1 = 1;
reg num2 = 0;
reg num3 = 0;
reg num4 = 0;
reg num5 = 1;
reg num6 = 0;
reg num7 = 0;
reg num8 = 0;
reg num9 = 1;
reg num10 = 0;
reg num11 = 0;
reg num12 = 0;
reg num13 = 1;
reg num14 = 0;
reg num15 = 0;
reg num16 = 1;



always @(posedge clk)
begin



num1 <= num2;
num2 <= num3;
num3 <= num4;
num4 <= num5;
num5 <= num6;
num6 <= num7;
num7 <= num8;
num8 <= num9;
num9 <= num10;
num10 <= num11;
num11 <= num12;
num12 <= num13;
num13 <= num14;
num14 <= num15;
num15 <= num16;
num16 <= num1;

num_out <= num16;

end

endmodule 