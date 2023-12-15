module CURSOR(
input clk, 
input rst,
//inputs passed from main module
input player_x_up,
input player_x_down,
input player_y_up,
input player_y_down,
//register to hold player cursor
output reg [3:0]player_cursor_x_reg,
output reg [3:0]player_cursor_y_reg
);


reg [31:0]counter;
// state variables for FSM
reg [3:0]S;
reg [3:0]NS;

parameter
	Start = 4'd0,
	CHECK = 4'd1,
	ADD = 4'd2,
	HOLD = 4'd3;
	
	//FSM States
always @ (posedge clk)
begin

		if (rst == 1'b0)
			S <= Start;
		else
			S <= NS;
end
always @ (posedge clk)
begin
			case (S)
				Start: NS = CHECK;
				
				CHECK:
				begin
				if (counter < 32'd50000000)
					NS = ADD;
				else
					NS = HOLD;
				end
				ADD: NS = CHECK;
				HOLD:
				begin
				if(counter == 32'd50000000)
					NS = HOLD;
				else
					NS = CHECK;
				end
			endcase
			
end			
			
				
//FSM runtime	

always@ (posedge clk)
begin
		if (rst == 0)
			begin//intial @ 0
			player_cursor_x_reg <= 0;
			player_cursor_y_reg <= 0;
			end
		else

		ADD:
			begin
				counter <= counter + 32'd1;
			end
		HOLD:
		begin

			//add 1 to x
			if((player_x_up == 4'd0) & (player_cursor_x_reg < 4'd3))
			begin
			player_cursor_x_reg <= player_cursor_x_reg + 4'd1;
			counter <= 0;
			end

			//sub 1 from x
			if((player_x_down == 4'd0) & (player_cursor_x_reg > 4'd0))
			begin
			player_cursor_x_reg <= player_cursor_x_reg - 4'd1;
			counter <= 0;
			end

			//add 1 to y
			if((player_y_up == 4'd0) & (player_cursor_y_reg < 4'd2))
			begin
			player_cursor_y_reg <= player_cursor_y_reg + 4'd1;
			counter <= 0;
			end

			//sub 1 from y
			if((player_y_down == 4'd0) & (player_cursor_y_reg > 4'd0))
			begin
			player_cursor_y_reg <= player_cursor_y_reg - 4'd1;
			counter <= 0;
			end

		end
end

endmodule 