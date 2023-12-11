module missile_control(

// top level module for project
	input clk, 
	input rst,
	
	// VGA outputs
	output [9:0]VGA_R,
	output [9:0]VGA_G,
	output [9:0]VGA_B,
	output VGA_HS,
	output VGA_VS,
	output VGA_BLANK,
	output VGA_SYNC,
	output VGA_CLK
	
	);
	
	// variables used for vga
	reg plot = 1'b1; 
	reg [31:0]x;
	reg [31:0]y;
	reg [2:0]color;
	reg back_color = 3'b000;
	
	// counter variables used for displaying
	reg [31:0]count_x;
	reg [31:0]count_y;
	
	vga_adapter my_vga(rst, clk, color, x, y, plot, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);
				 
	// variables to be used
	reg valid;
	reg [1:0]user;
	reg [2:0]outcome;
	reg [2:0]A1_color;
	
	// grid color parameters
	parameter p1_color = 3'b010,
	          p2_color = 3'b101,
	          default_color = 3'b111;
	
	// state variables for FSM
	reg [7:0]S;
	reg [7:0]NS;
	
	// state parameters
	parameter 
		INIT = 8'd70,
		
		// background
		BACK_START = 8'd0,
		BACK_CHECK_Y = 8'd1,
		BACK_CHECK_X = 8'd2,
		BACK_UPDATE_Y = 8'd3,
		BACK_UPDATE_X = 8'd4,
		BACK_DRAW = 8'd5,
		BACK_END = 8'd6,
		
		// Background graphics
		BACK_GRAPH_START = 8'd7,
		BACK_GRAPH_CHECK_Y = 8'd8,
		BACK_GRAPH_CHECK_X = 8'd9,
		BACK_GRAPH_UPDATE_Y = 8'd10,
		BACK_GRAPH_UPDATE_X = 8'd11,
		BACK_GRAPH_DRAW = 8'd12,
		BACK_GRAPH_END = 8'd13,
		
		DONE = 8'd71,
		
		ERROR = 8'hF;
			
			
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
			S <= INIT;
		else
			S <= NS;
	end
	
	// state travel chart
	always @(*)
	begin
	
		case(S)
			INIT: NS = BACK_START;
			
			// Background 
			// ------------------------------------------------------------------
			BACK_START: NS = BACK_CHECK_Y;
			
			BACK_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = BACK_CHECK_X;
				end
				else
				begin
					NS = BACK_END;
				end
			end
			
			BACK_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = BACK_DRAW;
				end
				else
				begin
					NS = BACK_UPDATE_Y;
				end
			end
			
			BACK_UPDATE_Y: NS = BACK_CHECK_Y;
			
			BACK_UPDATE_X: NS = BACK_CHECK_X;
			
			BACK_DRAW: NS = BACK_UPDATE_X;
			
			BACK_END: NS = BACK_GRAPH_START;
			
			
			// Background graphics (ground line)
			// ---------------------------------------------------------------------
			BACK_GRAPH_START: NS = BACK_GRAPH_CHECK_Y;
			BACK_GRAPH_CHECK_Y: 
			begin
				if (count_y < 215)
				begin
					NS = BACK_GRAPH_CHECK_X;
				end
				else
				begin
					NS = BACK_GRAPH_END;
				end
			end
			BACK_GRAPH_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = BACK_GRAPH_DRAW;
				end
				else
				begin
					NS = BACK_GRAPH_UPDATE_Y;
				end
			end
			BACK_GRAPH_UPDATE_Y: NS = BACK_GRAPH_CHECK_Y;
			BACK_GRAPH_UPDATE_X: NS = BACK_GRAPH_CHECK_X;
			BACK_GRAPH_DRAW: NS = BACK_GRAPH_UPDATE_X;
			BACK_GRAPH_END: NS = DONE;
	
			
			default: NS = ERROR;
		endcase
	end
	
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			// initializing variables
			valid <= 1'b0;
		
			// default colors for board
			A1_color <= default_color;
			
			// vga variables
			count_x <= 32'd0;
			count_y <= 32'd0;
			x <= 9'd0;
			y <= 8'd0;
			color <= 3'b111;
			
		end
		else
		begin		
			case(S)
				INIT:
				begin
					// initializing variables
					valid <= 1'b0;
				
					// default colors for board
					A1_color <= default_color;
					
					// vga variables
					count_x <= 32'd0;
					count_y <= 32'd0;
					x <= 9'd0;
					y <= 8'd0;
					color <= 3'b111;
					
				end
				
				// background
				BACK_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd0;
				end
				BACK_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				BACK_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				BACK_DRAW:
				begin
					color <= back_color;
					x <= count_x;
					y <= count_y;
				end
				
				// A1
				BACK_GRAPH_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd210;
				end
				BACK_GRAPH_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				BACK_GRAPH_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				BACK_GRAPH_DRAW:
				begin
					color <= A1_color;
					x <= count_x;
					y <= count_y;
				end
				
				
				
				ERROR:
				begin
				end
				default:
				begin
				end
			endcase
		end
	end
				
endmodule