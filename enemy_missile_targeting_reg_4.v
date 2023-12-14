module enemy_missile_targeting_reg_4(
input clk,
output reg [2:0]num_out
);

//initial values for the registers
reg [2:0]num1 = 1;
reg [2:0]num2 = 1;
reg [2:0]num3 = 2;
reg [2:0]num4 = 1;
reg [2:0]num5 = 0;
reg [2:0]num6 = 2;
reg [2:0]num7 = 0;
reg [2:0]num8 = 0;
reg [2:0]num9 = 2;
reg [2:0]num10 = 0;
reg [2:0]num11 = 0;
reg [2:0]num12 = 1;
reg [2:0]num13 = 2;
reg [2:0]num14 = 2;
reg [2:0]num15 = 1;
reg [2:0]num16 = 0;


//registers shift valuse

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

num_out <= num3;//registers that the module outputs

end

endmodule 