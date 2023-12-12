//module draws a missile at the given x & y coordinates. 
//x & y coordniates passed in are to by 1 bit
//requires extrenal reset


module missle_enemy(
input clk,
input restmissile,

input [2:0]in_colour,
input input_x,
input input_y,



output reg output_x,
output reg output_y,
output reg [2:0]out_colour

);
//signals for this module
reg enable
out_colour = in_colour;
//missle coordinate for this module
reg missilexcoord;
reg missileycoord;

input_x = missilexcoord;
input_y = missileycoord;
//new state parameters
reg [3:0]S;
reg [3:0]NS;



//parameters for states
parameters:



//clk and rst signals
always @(posedge clk or negedge rst)
	begin
		if (restmissile == 1'b0)
			S <= MissileSTART;
		else
			S <= NS;
	end
	
	

//states 
always @(*)
begin
	case(S)
		MissileSTART:
		begin
			enable = 1;
			NS = MissileDrawx;
		end
		MissileDrawx
		begin
		
		
			NS = MissileDrawy;
			
		end
		MissileDrawy
		begin
		
				NS = 
		end
end

