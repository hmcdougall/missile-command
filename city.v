module city(

	input clk, 
	input rst,
	
	input in_x, // x position of center of city
	input in_y, // y position on ground
	input city_color,
	
	output reg status, // alive (1) or dead (0)
	
	output reg out_x,
	output reg out_y,
	output reg out_color,
	output reg done
	
	// VGA outputs
//	output [9:0]VGA_R,
//	output [9:0]VGA_G,
//	output [9:0]VGA_B,
//	output VGA_HS,
//	output VGA_VS,
//	output VGA_BLANK,
//	output VGA_SYNC,
//	output VGA_CLK
	
	);
	
	// variables used for vga
//	reg plot = 1'b1; 
//	reg [31:0]x;
//	reg [31:0]y;
//	reg [2:0]color;
//	reg back_color = city_color;
	
//	vga_adapter my_vga(rst, clk, color, x, y, plot, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);
	
	reg [31:0] city_x = 32'd80;
	reg [31:0] city_y = 32'd210;
	
	// state variables for FSM
	reg [3:0]S;
	reg [3:0]NS;
	
	parameter 
		INIT = 8'd0,
		
		// City graphics
		CITY_START = 8'd1,
		CITY_CHECK_Y = 8'd2,
		CITY_CHECK_X = 8'd3,
		CITY_UPDATE_Y = 8'd4,
		CITY_UPDATE_X = 8'd5,
		CITY_DRAW = 8'd6,
		CITY_END = 8'd7,
		
		DONE = 8'd8,
		
		ERROR = 8'hF;
	
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
			S <= INIT;
		else
			S <= NS;
	end
	
	always@(*)
	begin
		case(S)
			INIT: NS <= CITY_START;
			CITY_START: NS = CITY_CHECK_Y;
			CITY_CHECK_Y: 
			begin
				if (city_y < 32'd210)
				begin
					NS = CITY_CHECK_X;
				end
				else
				begin
					NS = CITY_END;
				end
			end
			CITY_CHECK_X:
			begin
//				if (city_x < (32'd80+32'd2) & city_y < (32'd210-32'd4) | (city_x < (32'd80+32'd5) & (city_y < 32'd210)))
				if (city_x < (32'd80+32'd5))
				begin
					NS = CITY_DRAW;
				end
				else
				begin
					NS = CITY_UPDATE_Y;
				end
			end
			CITY_UPDATE_Y: NS = CITY_CHECK_Y;
			CITY_UPDATE_X: NS = CITY_CHECK_X;
			CITY_DRAW: NS = CITY_UPDATE_X;
			CITY_END: NS = DONE;
			default: NS <= ERROR;
		endcase
	end
	
	always @(posedge clk or negedge rst)
	begin
	
		if (rst == 1'b0)
		begin
			status <= 1'b1;
			done <= 1'b0;
		end
		
		else
		begin
		case(S)
			INIT:
			begin
				status <= 1'b1;
				done <= 1'b0;
			end
				
			CITY_START:
				begin
					city_x <= (32'd80 - 32'd2);
					city_y <= (32'd210 - 32'd7);
				end
				CITY_UPDATE_Y:
				begin
					city_y <= city_y + 32'd1;
//					city_x <= (32'd80 - 32'd5);
					if (city_y < 32'd205)
						city_x = 32'd80 - 32'd2;
					else 
						city_x <= 32'd80 - 32'd5;
				end
				CITY_UPDATE_X:
					city_x <= city_x + 32'd1;
				CITY_DRAW:
				begin
					out_color <= city_color;
					out_x <= city_x;
					out_y <= city_y;
				end
				
				DONE:
					done <= 1'b1;
				
		endcase
		end
	end
	
endmodule