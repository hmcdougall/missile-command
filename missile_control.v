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
	//---------------------------------------------------------------
	reg plot = 1'b1; 
	reg [31:0]x;
	reg [31:0]y;
	reg [2:0]color;
	reg back_color = 3'b000;
	
	// counter variables used for displaying
	reg [31:0]count_x;
	reg [31:0]count_y;
	
	vga_adapter my_vga(rst, clk, color, x, y, plot, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);

	reg [2:0]A1_color;
	
	// grid color parameters
	parameter city_color = 3'b010,
	          missile_color = 3'b101,
	          default_color = 3'b111;
	
	// state variables for FSM
	reg [7:0]S;
	reg [7:0]NS;
	
	// state parameters
	//-----------------------------------------------------------------
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
		
		// missile launcher graphics
		LAUNCHER_START = 8'd14,
		LAUNCHER_CHECK_Y = 8'd15,
		LAUNCHER_CHECK_X = 8'd16,
		LAUNCHER_UPDATE_Y = 8'd17,
		LAUNCHER_UPDATE_X = 8'd18,
		LAUNCHER_DRAW = 8'd19,
		LAUNCHER_END = 8'd20,
		
		// City graphics
		CITY1_START = 8'd21,
		CITY1_CHECK_Y = 8'd22,
		CITY1_CHECK_X = 8'd23,
		CITY1_UPDATE_Y = 8'd24,
		CITY1_UPDATE_X = 8'd25,
		CITY1_DRAW = 8'd26,
		CITY1_END = 8'd27,
		
		CITY2_START = 8'd28,
		CITY2_CHECK_Y = 8'd29,
		CITY2_CHECK_X = 8'd30,
		CITY2_UPDATE_Y = 8'd31,
		CITY2_UPDATE_X = 8'd32,
		CITY2_DRAW = 8'd33,
		CITY2_END = 8'd34,
		
		// Enemy Missiles
		EM1_START = 8'd35,
		EM1_CHECK_Y = 8'd36,
		EM1_CHECK_X = 8'd37,
		EM1_UPDATE_Y = 8'd38,
		EM1_UPDATE_X = 8'd39,
		EM1_DRAW = 8'd40,
		EM1_END = 8'd41,

		DONE = 8'd71,
		
		ERROR = 8'hF;
		
	// City variables
	// -------------------------------------------------------------------
	wire [31:0] city1_x_init = 32'd80;
	wire [31:0] city1_y_init = 32'd210;
	reg [31:0] city1_x = 32'd80;
	reg [31:0] city1_y = 32'd210;
	reg city1_status = 1'b1;
	
	wire [31:0] city2_x_init = 32'd240;
	wire [31:0] city2_y_init = 32'd210;
	reg [31:0] city2_x = 32'd240;
	reg [31:0] city2_y = 32'd210;
	reg city2_status = 1'b1;
	
	// Enemy missile variables
	// -------------------------------------------------------------------
	wire em1_x_init = 32'd64;
	wire em1_y_init = 32'd0;
	wire em1_x_final = 32'd80;
	wire em1_y_final = 32'd208;
	wire em1_dx = 32'd1;
	wire em1_dy = 32'd13;
	reg em1_currX = 32'd64;
	reg em1_currY = 32'd0;
	reg em1_active = 0;
	
	wire em2_x_init = 32'd128;
	wire em2_y_init = 32'd0;
	wire em2_x_final = 32'd80;
	wire em2_y_final = 32'd206;
	
	wire em3_x_init = 32'd192;
	wire em3_y_init = 32'd0;
	wire em3_x_final = 32'd80;
	wire em3_y_final = 32'd206;
	
	wire em4_x_init = 32'd256;
	wire em4_y_init = 32'd0;
	wire em4_x_final = 32'd80;
	wire em4_y_final = 32'd206;
	
	wire em5_x_init = 32'd64;
	wire em5_y_init = 32'd0;
	wire em5_x_final = 32'd160;
	wire em5_y_final = 32'd206;
	
	wire em6_x_init = 32'd128;
	wire em6_y_init = 32'd0;
	wire em6_x_final = 32'd160;
	wire em6_y_final = 32'd206;
	
	wire em7_x_init = 32'd192;
	wire em7_y_init = 32'd0;
	wire em7_x_final = 32'd160;
	wire em7_y_final = 32'd206;
	
	wire em8_x_init = 32'd256;
	wire em8_y_init = 32'd0;
	wire em8_x_final = 32'd160;
	wire em8_y_final = 32'd206;
	
	wire em9_x_init = 32'd64;
	wire em9_y_init = 32'd0;
	wire em9_x_final = 32'd240;
	wire em9_y_final = 32'd206;
	
	wire em10_x_init = 32'd128;
	wire em10_y_init = 32'd0;
	wire em10_x_final = 32'd240;
	wire em10_y_final = 32'd206;
	
	wire em11_x_init = 32'd192;
	wire em11_y_init = 32'd0;
	wire em11_x_final = 32'd240;
	wire em11_y_final = 32'd206;
	
	wire em12_x_init = 32'd256;
	wire em12_y_init = 32'd0;
	wire em12_x_final = 32'd240;
	wire em12_y_final = 32'd206;
	
	
	
	// Game Variables 
	// -------------------------------------------------------------------
	reg [1:0] game_over = 2'b0;
	
	
	// Logic
	// =======================================================================================
	// =======================================================================================
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
			S <= INIT;
		else
			S <= NS;
	end
	
	
	always @(*)
	begin
	
		case(S)
			INIT: NS = BACK_START;
			
			// Background fill
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
			
			
			// Background graphics (ground)
			// ---------------------------------------------------------------------
			BACK_GRAPH_START: NS = BACK_GRAPH_CHECK_Y;
			BACK_GRAPH_CHECK_Y: 
			begin
				if (count_y < 240)
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
			BACK_GRAPH_END: NS = LAUNCHER_START;
			
			// Missile launcher graphics (raised platform)
			// ---------------------------------------------------------------------
			LAUNCHER_START: NS = LAUNCHER_CHECK_Y;
			LAUNCHER_CHECK_Y: 
			begin
				if (count_y < 210)
				begin
					NS = LAUNCHER_CHECK_X;
				end
				else
				begin
					NS = LAUNCHER_END;
				end
			end
			LAUNCHER_CHECK_X:
			begin
				if (count_x < 168)
				begin
					NS = LAUNCHER_DRAW;
				end
				else
				begin
					NS = LAUNCHER_UPDATE_Y;
				end
			end
			LAUNCHER_UPDATE_Y: NS = LAUNCHER_CHECK_Y;
			LAUNCHER_UPDATE_X: NS = LAUNCHER_CHECK_X;
			LAUNCHER_DRAW: NS = LAUNCHER_UPDATE_X;
			LAUNCHER_END: NS = CITY1_START;
			
			// City 1 graphics
			// ---------------------------------------------------------------------
			CITY1_START: NS = CITY1_CHECK_Y;
			CITY1_CHECK_Y: 
			begin
				if (city1_y < city1_y_init)
				begin
					NS = CITY1_CHECK_X;
				end
				else
				begin
					NS = CITY1_END;
				end
			end
			CITY1_CHECK_X:
			begin
				if (city1_x < (city1_x_init+32'd5))
				begin
					NS = CITY1_DRAW;
				end
				else
				begin
					NS = CITY1_UPDATE_Y;
				end
			end
			CITY1_UPDATE_Y: NS = CITY1_CHECK_Y;
			CITY1_UPDATE_X: NS = CITY1_CHECK_X;
			CITY1_DRAW: NS = CITY1_UPDATE_X;
			CITY1_END: NS = CITY2_START;
			
			// City 2 graphics
			// ---------------------------------------------------------------------
			CITY2_START: NS = CITY2_CHECK_Y;
			CITY2_CHECK_Y: 
			begin
				if (city2_y < city2_y_init)
				begin
					NS = CITY2_CHECK_X;
				end
				else
				begin
					NS = CITY2_END;
				end
			end
			CITY2_CHECK_X:
			begin
				if (city2_x < (city2_x_init+32'd5))
				begin
					NS = CITY2_DRAW;
				end
				else
				begin
					NS = CITY2_UPDATE_Y;
				end
			end
			CITY2_UPDATE_Y: NS = CITY2_CHECK_Y;
			CITY2_UPDATE_X: NS = CITY2_CHECK_X;
			CITY2_DRAW: NS = CITY2_UPDATE_X;
			CITY2_END: NS = EM1_START;
			
			// Enemy Missile graphics
			// ---------------------------------------------------------------------
			EM1_START: 
			begin
				if (em1_active == 1)
					NS = EM1_CHECK_Y;
				else
					NS = DONE;
			end
			EM1_CHECK_Y: 
			begin
				if (em1_currY < em1_y_final)
				begin
					NS = EM1_CHECK_X;
				end
				else
				begin
					NS = EM1_END;
				end
			end
			EM1_CHECK_X:
			begin
				if (em1_currX < em1_x_final)
				begin
					NS = EM1_DRAW;
				end
				else
				begin
					NS = EM1_UPDATE_Y;
				end
			end
			EM1_UPDATE_Y: NS = EM1_CHECK_Y;
			EM1_UPDATE_X: NS = EM1_CHECK_X;
			EM1_DRAW: NS = EM1_UPDATE_X;
			EM1_END: NS = DONE;
	
			
			default: NS = ERROR;
		endcase
	end
	
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
		
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
				// ---------------------------------------------------------------------
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
				
				// Background graphics (ground)
				// ---------------------------------------------------------------------
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
				
				// Missile launcher graphics
				// ---------------------------------------------------------------------
				LAUNCHER_START:
				begin
					count_x <= 32'd152;
					count_y <= 32'd200;
				end
				LAUNCHER_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd152;
				end
				LAUNCHER_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				LAUNCHER_DRAW:
				begin
					color <= A1_color;
					x <= count_x;
					y <= count_y;
				end
				
				// City 1 graphics
				// ---------------------------------------------------------------------
				
				CITY1_START:
				begin
					city1_x <= (city1_x_init - 32'd2);
					city1_y <= (city1_y_init - 32'd7);
				end
				CITY1_UPDATE_Y:
				begin
					city1_y <= city1_y + 32'd1;
					if (city1_y < city1_y_init - 32'd5)
						city1_x = city1_x_init - 32'd2;
					else 
						city1_x <= city1_x_init - 32'd5;
				end
				CITY1_UPDATE_X:
					city1_x <= city1_x + 32'd1;
				CITY1_DRAW:
				begin
					color <= city_color;
					x <= city1_x;
					y <= city1_y;
				end
			
				// City 2 graphics
				// ---------------------------------------------------------------------
				
				CITY1_START:
				begin
					city2_x <= (city2_x_init - 32'd2);
					city2_y <= (city2_y_init - 32'd7);
				end
				CITY1_UPDATE_Y:
				begin
					city2_y <= city2_y + 32'd1;
					if (city2_y < city2_y_init - 32'd5)
						city2_x = city2_x_init - 32'd2;
					else 
						city2_x <= city2_x_init - 32'd5;
				end
				CITY1_UPDATE_X:
					city2_x <= city2_x + 32'd1;
				CITY1_DRAW:
				begin
					color <= city_color;
					x <= city2_x;
					y <= city2_y;
				end
				
				// Enemy missle 1 graphics
				// ---------------------------------------------------------------------
				EM1_START:
				begin
					em1_currX <= em1_x_init;
					em1_currY <= em1_y_init;
				end
				EM1_UPDATE_Y:
				begin
					em1_currY <= em1_currY + em1_dy;
					em1_currX <= em1_currX;
				end
				EM1_UPDATE_X:
				begin
					em1_currX <= em1_currX + em1_dx;
				end
				EM1_DRAW:
				begin
					color <= missile_color;
					x <= em1_currX;
					y <= em1_currY;
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
	
	
	always@(*)
	begin
		if (game_over == 2'd2)
		begin
			// eventually, this will stop the game
			game_over = 2'd2;
		end
	end
				
endmodule
