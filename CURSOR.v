module CURSOR(
input clk, 
input rst,
input player_x_up,
input player_x_down,
input player_y_up,
input player_y_down,
output reg [3:0]player_cursor_x_reg,
output reg [3:0]player_cursor_y_reg
);



//register to hold player cursor
always@ (posedge clk)
if (rst == 0)
	begin
	player_cursor_x_reg <= 0;
	player_cursor_y_reg <= 0;
	end
else

begin

//add 1 to x
if((player_x_up == 4'd0) & (player_cursor_x_reg < 4'd2))
begin
player_cursor_x_reg <= player_cursor_x_reg + 4'd1;
end

//sub 1 from x
if((player_x_down == 4'd0) & (player_cursor_x_reg > 4'd1))
begin
player_cursor_x_reg <= player_cursor_x_reg - 4'd1;
end

//add 1 to y
if((player_y_up == 4'd0) & (player_cursor_y_reg < 4'd1))
begin
player_cursor_y_reg <= player_cursor_y_reg + 4'd1;
end

//sub 1 from y
if((player_y_down == 4'd0) & (player_cursor_y_reg > 4'd1))
begin
player_cursor_y_reg <= player_cursor_y_reg - 4'd1;
end

end

endmodule 