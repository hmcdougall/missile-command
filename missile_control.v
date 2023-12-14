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
	output VGA_CLK,
	
	//ps2Keyboard
	//--------------------------------------------------
	inout ps2ck,
	inout ps2dt
	
	);
	
	// variables used for vga
	//---------------------------------------------------------------
	reg plot = 1'b1; 
	reg [31:0]x;
	reg [31:0]y;
	reg [2:0]color;
	reg back_color = 3'b000;
	//ps2Keyboard variables
	//----------------------------------------------------------------
	reg [3:0]arrows;
	reg [3:0]wasd;
	reg space;
	reg enter;
	
	// counter variables used for displaying
	reg [31:0]count_x;
	reg [31:0]count_y;
	
	vga_adapter my_vga(rst, clk, color, x, y, plot, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);

	reg [2:0]A1_color;
	
	// grid color parameters
	parameter city_color = 3'b010,
	          missile_color = 3'b101,
	          default_color = 3'b111,
				 game_over_color = 3'b100;
	
	// state variables for FSM
	reg [7:0]S;
	reg [7:0]NS;
	
	// state parameters
	//-----------------------------------------------------------------
	parameter 
		INIT = 8'd255,
		
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
		EM1_UPDATE_Y = 8'd38,
		EM1_UPDATE_X = 8'd39,
		EM1_DRAW = 8'd40,
		EM1_END = 8'd41,
		
		EM2_START = 8'd42,
		EM2_CHECK_Y = 8'd43,
		EM2_UPDATE_Y = 8'd44,
		EM2_UPDATE_X = 8'd45,
		EM2_DRAW = 8'd46,
		EM2_END = 8'd47,
		EM2_WAIT = 8'd108,
		EM2_WAITING = 8'd109,
		
		EM3_START = 8'd48,
		EM3_CHECK_Y = 8'd49,
		EM3_UPDATE_Y = 8'd50,
		EM3_UPDATE_X = 8'd51,
		EM3_DRAW = 8'd52,
		EM3_END = 8'd53,
		
		EM4_START = 8'd54,
		EM4_CHECK_Y = 8'd55,
		EM4_UPDATE_Y = 8'd56,
		EM4_UPDATE_X = 8'd57,
		EM4_DRAW = 8'd58,
		EM4_END = 8'd59,
		
		EM5_START = 8'd60,
		EM5_CHECK_Y = 8'd61,
		EM5_UPDATE_Y = 8'd62,
		EM5_UPDATE_X = 8'd63,
		EM5_DRAW = 8'd64,
		EM5_END = 8'd65,
		
		EM6_START = 8'd66,
		EM6_CHECK_Y = 8'd67,
		EM6_UPDATE_Y = 8'd68,
		EM6_UPDATE_X = 8'd69,
		EM6_DRAW = 8'd70,
		EM6_END = 8'd71,
		
		EM7_START = 8'd72,
		EM7_CHECK_Y = 8'd73,
		EM7_UPDATE_Y = 8'd74,
		EM7_UPDATE_X = 8'd75,
		EM7_DRAW = 8'd76,
		EM7_END = 8'd77,
		
		EM8_START = 8'd78,
		EM8_CHECK_Y = 8'd79,
		EM8_UPDATE_Y = 8'd80,
		EM8_UPDATE_X = 8'd81,
		EM8_DRAW = 8'd82,
		EM8_END = 8'd83,
		
		EM9_START = 8'd84,
		EM9_CHECK_Y = 8'd85,
		EM9_UPDATE_Y = 8'd86,
		EM9_UPDATE_X = 8'd87,
		EM9_DRAW = 8'd88,
		EM9_END = 8'd89,
		
		EM10_START = 8'd90,
		EM10_CHECK_Y = 8'd91,
		EM10_UPDATE_Y = 8'd92,
		EM10_UPDATE_X = 8'd93,
		EM10_DRAW = 8'd94,
		EM10_END = 8'd95,
		
		EM11_START = 8'd96,
		EM11_CHECK_Y = 8'd97,
		EM11_UPDATE_Y = 8'd98,
		EM11_UPDATE_X = 8'd99,
		EM11_DRAW = 8'd100,
		EM11_END = 8'd101,
		
		EM12_START = 8'd102,
		EM12_CHECK_Y = 8'd103,
		EM12_UPDATE_Y = 8'd104,
		EM12_UPDATE_X = 8'd105,
		EM12_DRAW = 8'd106,
		EM12_END = 8'd107,
		
		GAME_RUNNER = 8'd108,
		MOVE_EM1 = 8'd109,
		MOVE_EM2 = 8'd110,
		MOVE_EM3 = 8'd111,
		MOVE_EM4 = 8'd112,
		MOVE_EM5 = 8'd113,
		MOVE_EM6 = 8'd114,
		MOVE_EM7 = 8'd115,
		MOVE_EM8 = 8'd116,
		MOVE_EM9 = 8'd117,
		MOVE_EM10 = 8'd118,
		MOVE_EM11 = 8'd119,
		MOVE_EM12 = 8'd120,
		CHECK_MISSILES = 8'd121,
		GAME_WAIT = 8'd122,
		GAME_WAITING = 8'd123,
		MISSILE_SPAWN = 8'd124,
		CHECK_GAME_OVER = 8'd125,
		
		GAME_OVER_START = 8'd247,
		GAME_OVER_CHECK_Y = 8'd248,
		GAME_OVER_CHECK_X = 8'd249,
		GAME_OVER_UPDATE_Y = 8'd250,
		GAME_OVER_UPDATE_X = 8'd251, 
		GAME_OVER_DRAW = 8'd252,
		GAME_OVER_END = 8'd253,

		DONE = 8'd254,
		
		ERROR = 8'hF;
	// PS2 Keyboard Instantiation 
//	ps2Keyboard keyboard_mod(clk,ps2ck,ps2dt,enter,space,arrows,wasd);

	
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
	
	reg missile_launcher_status = 1'b1;


	// Enemy missile variables
	// -------------------------------------------------------------------
	wire [31:0] em1_x_init = 32'd54;
	wire [31:0] em1_y_init = 32'd0;
	wire [31:0] em1_x_final = 32'd80;
	wire [31:0] em1_y_final = 32'd208;
	wire [31:0] em1_dx = 32'd1;
	wire [31:0] em1_dy = 32'd8;
	reg [31:0] em1_currX = 32'd64;
	reg [31:0] em1_currY = 32'd0;
	reg em1_active;
	
	wire [31:0] em2_x_init = 32'd128;
	wire [31:0] em2_y_init = 32'd0;
	wire [31:0] em2_x_final = 32'd80;
	wire [31:0] em2_y_final = 32'd206;
	wire [31:0] em2_dx = 32'd2;
	wire [31:0] em2_dy = 32'd8;
	reg [31:0] em2_currX = 32'd128;
	reg [31:0] em2_currY = 32'd0;
	reg em2_active;
	
	wire [31:0] em3_x_init = 32'd184;
	wire [31:0] em3_y_init = 32'd0;
	wire [31:0] em3_x_final = 32'd80;
	wire [31:0] em3_y_final = 32'd206;
	wire [31:0] em3_dx = 32'd4;
	wire [31:0] em3_dy = 32'd8;
	reg [31:0] em3_currX = 32'd184;
	reg [31:0] em3_currY = 32'd0;
	reg em3_active;
	
	wire [31:0] em4_x_init = 32'd262;
	wire [31:0] em4_y_init = 32'd0;
	wire [31:0] em4_x_final = 32'd80;
	wire [31:0] em4_y_final = 32'd206;
	wire [31:0] em4_dx = 32'd7;
	wire [31:0] em4_dy = 32'd8;
	reg [31:0] em4_currX = 32'd262;
	reg [31:0] em4_currY = 32'd0;
	reg em4_active;
	
	wire [31:0] em5_x_init = 32'd56;
	wire [31:0] em5_y_init = 32'd0;
	wire [31:0] em5_x_final = 32'd160;
	wire [31:0] em5_y_final = 32'd206;
	wire [31:0] em5_dx = 32'd4;
	wire [31:0] em5_dy = 32'd8;
	reg [31:0] em5_currX = 32'd56;
	reg [31:0] em5_currY = 32'd0;
	reg em5_active;
	
	wire [31:0] em6_x_init = 32'd134;
	wire [31:0] em6_y_init = 32'd0;
	wire [31:0] em6_x_final = 32'd160;
	wire [31:0] em6_y_final = 32'd206;
	wire [31:0] em6_dx = 32'd1;
	wire [31:0] em6_dy = 32'd8;
	reg [31:0] em6_currX = 32'd134;
	reg [31:0] em6_currY = 32'd0;
	reg em6_active;
	
	wire [31:0] em7_x_init = 32'd186;
	wire [31:0] em7_y_init = 32'd0;
	wire [31:0] em7_x_final = 32'd160;
	wire [31:0] em7_y_final = 32'd206;
	wire [31:0] em7_dx = 32'd1;
	wire [31:0] em7_dy = 32'd8;
	reg [31:0] em7_currX = 32'd186;
	reg [31:0] em7_currY = 32'd0;
	reg em7_active;

	
	wire [31:0] em8_x_init = 32'd264;
	wire [31:0] em8_y_init = 32'd0;
	wire [31:0] em8_x_final = 32'd160;
	wire [31:0] em8_y_final = 32'd206;
	wire [31:0] em8_dx = 32'd4;
	wire [31:0] em8_dy = 32'd8;
	reg [31:0] em8_currX = 32'd264;
	reg [31:0] em8_currY = 32'd0;
	reg em8_active;
	
	wire [31:0] em9_x_init = 32'd58;
	wire [31:0] em9_y_init = 32'd0;
	wire [31:0] em9_x_final = 32'd240;
	wire [31:0] em9_y_final = 32'd206;
	wire [31:0] em9_dx = 32'd7;
	wire [31:0] em9_dy = 32'd8;
	reg [31:0] em9_currX = 32'd58;
	reg [31:0] em9_currY = 32'd0;
	reg em9_active;
	
	wire [31:0] em10_x_init = 32'd136;
	wire [31:0] em10_y_init = 32'd0;
	wire [31:0] em10_x_final = 32'd240;
	wire [31:0] em10_y_final = 32'd206;
	wire [31:0] em10_dx = 32'd4;
	wire [31:0] em10_dy = 32'd8;
	reg [31:0] em10_currX = 32'd136;
	reg [31:0] em10_currY = 32'd0;
	reg em10_active;
	
	wire [31:0] em11_x_init = 32'd188;
	wire [31:0] em11_y_init = 32'd0;
	wire [31:0] em11_x_final = 32'd240;
	wire [31:0] em11_y_final = 32'd206;
	wire [31:0] em11_dx = 32'd2;
	wire [31:0] em11_dy = 32'd8;
	reg [31:0] em11_currX = 32'd188;
	reg [31:0] em11_currY = 32'd0;
	reg em11_active;

	
	wire [31:0] em12_x_init = 32'd266;
	wire [31:0] em12_y_init = 32'd0;
	wire [31:0] em12_x_final = 32'd240;
	wire [31:0] em12_y_final = 32'd206;
	wire [31:0] em12_dx = 32'd1;
	wire [31:0] em12_dy = 32'd8;
	reg [31:0] em12_currX = 32'd266;
	reg [31:0] em12_currY = 32'd0;
	reg em12_active;
	
	//missile spawning randomizer
	//--------------------------------------------------------------------

	
	wire missile_1_hot; 
	wire missile_2_hot; 
	wire missile_3_hot; 
	wire missile_4_hot;
	
	
	
	enemy_missile_shift_reg_1 missile_1_fire(clk,missile_1_hot);
	enemy_missile_shift_reg_2 missile_2_fire(clk,missile_2_hot);
	enemy_missile_shift_reg_3 missile_3_fire(clk,missile_3_hot);
	enemy_missile_shift_reg_4 missile_4_fire(clk,missile_4_hot);
	
	reg missile_1_hot_reg;
	reg missile_2_hot_reg;
	reg missile_3_hot_reg;
	reg missile_4_hot_reg;
	

	
	//missile targeting point randomizer
	//----------------------------------------------------------------------------
	
	wire [2:0]missile_1_target;
	wire [2:0]missile_2_target;
	wire [2:0]missile_3_target;
	wire [2:0]missile_4_target;
	
	enemy_missile_targeting_reg_1 missile_1_target_sel(clk,missile_1_target);
	enemy_missile_targeting_reg_2 missile_2_target_sel(clk,missile_2_target);
	enemy_missile_targeting_reg_3 missile_3_target_sel(clk,missile_3_target);
	enemy_missile_targeting_reg_4 missile_4_target_sel(clk,missile_4_target);
	

	
	reg [2:0]missile_1_target_reg;
	reg [2:0]missile_2_target_reg;
	reg [2:0]missile_3_target_reg;
	reg [2:0]missile_4_target_reg;
	
	always @(*)
	begin
		missile_1_hot_reg = missile_1_hot;
		missile_2_hot_reg = missile_2_hot;
		missile_3_hot_reg = missile_3_hot;
		missile_4_hot_reg = missile_4_hot;
						
		missile_1_target_reg = missile_1_target;
		missile_2_target_reg = missile_2_target;
		missile_3_target_reg = missile_3_target;
		missile_4_target_reg = missile_4_target;
	end
	
	// Game Variables 
	// -------------------------------------------------------------------
	reg [1:0] game_over = 2'b0;
	reg [31:0] game_i = 32'd0;
	
	
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

			
			// Enemy Missile 1 graphics
			// ---------------------------------------------------------------------
			EM1_START: 
			begin
				NS = EM2_START;
			end
			EM1_CHECK_Y: NS = EM1_DRAW;
			EM1_UPDATE_Y: NS = EM1_CHECK_Y;
			EM1_UPDATE_X: NS = EM1_UPDATE_Y;
			EM1_DRAW: 
			begin
				if (em1_active == 1'b0 & em1_currY < em1_y_final)
					NS = EM1_UPDATE_X;
				else
					NS = MOVE_EM2;
			end
			EM1_END: NS = MOVE_EM2;
			
			// Enemy Missile 2 graphics
			// ---------------------------------------------------------------------
			EM2_START: 
			begin
				NS = EM3_START;
			end
			EM2_CHECK_Y: NS = EM2_DRAW;
			EM2_UPDATE_Y: NS = EM2_CHECK_Y;
			EM2_UPDATE_X: NS = EM2_UPDATE_Y;
			EM2_DRAW: 
			begin
				if (em2_active == 1'b0 & em2_currY < em2_y_final)
					NS = EM2_UPDATE_X;
				else
					NS = MOVE_EM3;
			end
			EM2_END: NS = MOVE_EM3;
			
			
			// Enemy Missile 3 graphics
			// ---------------------------------------------------------------------
			EM3_START: 
			begin
				NS = EM4_START;
			end
			EM3_CHECK_Y: NS = EM3_DRAW;
			EM3_UPDATE_Y: NS = EM3_CHECK_Y;
			EM3_UPDATE_X: NS = EM3_UPDATE_Y;
			EM3_DRAW: 
			begin
			if (em3_active == 1'b0 & em3_currY < em3_y_final)
					NS = EM3_UPDATE_X;
			else
					NS = MOVE_EM4;
			end
			EM3_END: NS = MOVE_EM4;
			
			// Enemy Missile 4 graphics
			// ---------------------------------------------------------------------
			EM4_START: 
			begin
				NS = EM5_START;
			end
			EM4_CHECK_Y: NS = EM4_DRAW;
			EM4_UPDATE_Y: NS = EM4_CHECK_Y;
			EM4_UPDATE_X: NS = EM4_UPDATE_Y;
			EM4_DRAW: 
			begin
			if (em4_active == 1'b0 & em4_currY < em4_y_final)
					NS = EM4_UPDATE_X;
			else
					NS = MOVE_EM5;
			end
			EM4_END: NS = MOVE_EM5;
			
			// Enemy Missile 5 graphics
			// ---------------------------------------------------------------------
			EM5_START: 
			begin
				NS = EM6_START;
			end
			EM5_CHECK_Y: NS = EM5_DRAW;
			EM5_UPDATE_Y: NS = EM5_CHECK_Y;
			EM5_UPDATE_X: NS = EM5_UPDATE_Y;
			EM5_DRAW: 
			begin
			if (em5_active == 1'b0 & em5_currY < em5_y_final)
					NS = EM5_UPDATE_X;
			else
					NS = MOVE_EM6;
			end
			EM5_END: NS = MOVE_EM6;
			
			// Enemy Missile 6 graphics
			// ---------------------------------------------------------------------
			EM6_START: 
			begin
				NS = EM7_START;
			end
			EM6_CHECK_Y: NS = EM6_DRAW;
			EM6_UPDATE_Y: NS = EM6_CHECK_Y;
			EM6_UPDATE_X: NS = EM6_UPDATE_Y;
			EM6_DRAW:
			begin
			if (em6_active == 1'b0 & em6_currY < em6_y_final)
					NS = EM6_UPDATE_X;
			else
					NS = MOVE_EM7;
			end
			EM6_END: NS = MOVE_EM7;
			
			// Enemy Missile 7 graphics
			// ---------------------------------------------------------------------
			EM7_START: 
			begin
				NS = EM8_START;
			end
			EM7_CHECK_Y: NS = EM7_DRAW;
			EM7_UPDATE_Y: NS = EM7_CHECK_Y;
			EM7_UPDATE_X: NS = EM7_UPDATE_Y;
			EM7_DRAW:
			begin
			if (em7_active == 1'b0 & em7_currY < em7_y_final)
					NS = EM7_UPDATE_X;
			else
					NS = MOVE_EM8;
			end
			EM7_END: NS = MOVE_EM8;
			
			// Enemy Missile 8 graphics
			// ---------------------------------------------------------------------
			EM8_START: 
			begin
				NS = EM9_START;
			end
			EM8_CHECK_Y: NS = EM8_DRAW;
			EM8_UPDATE_Y: NS = EM8_CHECK_Y;
			EM8_UPDATE_X: NS = EM8_UPDATE_Y;
			EM8_DRAW:
			begin
			if (em8_active == 1'b0 & em8_currY < em8_y_final)
					NS = EM8_UPDATE_X;
			else
					NS = MOVE_EM9;
			end
			EM8_END: NS = MOVE_EM9;
			
			// Enemy Missile 9 graphics
			// ---------------------------------------------------------------------
			EM9_START: 
			begin
				NS = EM10_START;
			end
			EM9_CHECK_Y: NS = EM9_DRAW;
			EM9_UPDATE_Y: NS = EM9_CHECK_Y;
			EM9_UPDATE_X: NS = EM9_UPDATE_Y;
			EM9_DRAW:
			begin
			if (em9_active == 1'b0 & em9_currY < em9_y_final)
					NS = EM9_UPDATE_X;
			else
					NS = MOVE_EM10;
			end
			EM9_END: NS = MOVE_EM10;
			
			// Enemy Missile 10 graphics
			// ---------------------------------------------------------------------
			EM10_START: 
			begin
				NS = EM11_START;
			end
			EM10_CHECK_Y: NS = EM10_DRAW;
			EM10_UPDATE_Y: NS = EM10_CHECK_Y;
			EM10_UPDATE_X: NS = EM10_UPDATE_Y;
			EM10_DRAW:
			begin
			if (em10_active == 1'b0 & em10_currY < em10_y_final)
					NS = EM10_UPDATE_X;
			else
					NS = MOVE_EM11;
			end
			EM10_END: NS = MOVE_EM11;
			
			// Enemy Missile 11 graphics
			// ---------------------------------------------------------------------
			EM11_START: 
			begin
				NS = EM12_START;
			end
			EM11_CHECK_Y: NS = EM11_DRAW;
			EM11_UPDATE_Y: NS = EM11_CHECK_Y;
			EM11_UPDATE_X: NS = EM11_UPDATE_Y;
			EM11_DRAW: 
			begin
			if (em11_active == 1'b0 & em11_currY < em11_y_final)
					NS = EM11_UPDATE_X;
			else
					NS = MOVE_EM12;
			end
			EM11_END: NS = MOVE_EM12;
			
			// Enemy Missile 12 graphics
			// ---------------------------------------------------------------------
			EM12_START: 
			begin
				NS = CHECK_GAME_OVER;
			end
			EM12_CHECK_Y: NS = EM12_DRAW;
			EM12_UPDATE_Y: NS = EM12_CHECK_Y;
			EM12_UPDATE_X: NS = EM12_UPDATE_Y;
			EM12_DRAW: 
			begin
				if (em12_active == 1'b0 & em12_currY < em12_y_final)
					NS = EM12_UPDATE_X;
				else
					NS = CHECK_GAME_OVER;
			end
			EM12_END: NS = CHECK_GAME_OVER;
			
			
			// GAME RUNNER
			// ---------------------------------------------------------------------
			GAME_RUNNER: NS = MOVE_EM1;
			
			MOVE_EM1: 
			begin
			
				if(em1_active == 1)
				begin
				NS = EM1_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM2;
				end
			
			end
			MOVE_EM2: 
			begin
			
				if(em2_active == 1)
				begin
				NS = EM2_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM3;
				end
			
			end
			MOVE_EM3:
			begin
			
				if(em3_active == 1)
				begin
				NS = EM3_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM4;
				end
			
			end
			MOVE_EM4:
			begin
			
				if(em4_active == 1)
				begin
				NS = EM4_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM5;
				end
			
			end
			MOVE_EM5:
			begin
			
				if(em5_active == 1)
				begin
				NS = EM5_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM6;
				end
			
			end
			MOVE_EM6:
			begin
			
				if(em6_active == 1)
				begin
				NS = EM6_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM7;
				end
			
			end
			
			MOVE_EM7:
			begin
			
				if(em7_active == 1)
				begin
				NS = EM7_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM8;
				end
			
			end
			
			MOVE_EM8:
			begin
			
				if(em8_active == 1)
				begin
				NS = EM8_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM9;
				end
			
			end
			MOVE_EM9:
			begin
			
				if(em9_active == 1)
				begin
				NS = EM9_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM10;
				end
			
			end		
			MOVE_EM10:
			begin
			
				if(em10_active == 1)
				begin
				NS = EM10_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM11;
				end
			
			end
			MOVE_EM11:
			begin
			
				if(em11_active == 1)
				begin
				NS = EM11_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_EM12;
				end
			
			end
			MOVE_EM12:
			begin
			
				if(em12_active == 1)
				begin
				NS = EM12_UPDATE_X;
				end
				
				else
				begin
				NS = CHECK_MISSILES;
				end
			
			end
			
			CHECK_MISSILES: NS = MISSILE_SPAWN;
				
			
			MISSILE_SPAWN: NS = GAME_WAIT;
			GAME_WAIT:
			begin
				if (game_i < 32'd12500000)
					NS = GAME_WAITING;
				else
//				begin
//					if (game_over == 2'd2)
//						NS = GAME_OVER_START;
//					else
					NS = CHECK_GAME_OVER;
//				end
			end
			GAME_WAITING: NS = GAME_WAIT;
			
			CHECK_GAME_OVER: 
			begin
				if ((city1_status == 1'b0 & city2_status == 1'b0) | missile_launcher_status == 1'b0)
					NS = GAME_OVER_START;
				else 
					NS = MOVE_EM1;
			end
			
			// game over
			// ---------------------------------------------------------------------
			GAME_OVER_START: NS = GAME_OVER_CHECK_Y;
			GAME_OVER_CHECK_Y: 
			begin
				if (count_y < 240)
					NS = GAME_OVER_CHECK_X;
				else
					NS = GAME_OVER_END;
			end
			GAME_OVER_CHECK_X:
			begin
				if (count_x < 320)
					NS = GAME_OVER_DRAW;
				else
					NS = GAME_OVER_UPDATE_Y;
			end
			GAME_OVER_UPDATE_Y: NS = GAME_OVER_CHECK_Y;
			GAME_OVER_UPDATE_X: NS = GAME_OVER_CHECK_X;
			GAME_OVER_DRAW: NS = GAME_OVER_UPDATE_X;
			GAME_OVER_END: NS = DONE;
			
			default: NS = ERROR;
		endcase
	end
	
	
	// STATE BEHAVIOR
	// ====================================================================================================
	// ====================================================================================================
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
					color <= city_color;
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
					if (city1_status == 1'b1)
						color <= city_color;
					else
						color <= back_color;
					x <= city1_x;
					y <= city1_y;
				end
			
				// City 2 graphics
				// ---------------------------------------------------------------------
				
				CITY2_START:
				begin
					city2_x <= (city2_x_init - 32'd2);
					city2_y <= (city2_y_init - 32'd7);
				end
				CITY2_UPDATE_Y: 
				begin
					city2_y <= city2_y + 32'd1;
					if (city2_y < city2_y_init - 32'd5)
						city2_x = city2_x_init - 32'd2;
					else 
						city2_x <= city2_x_init - 32'd5;
				end
				CITY2_UPDATE_X:
					city2_x <= city2_x + 32'd1;
				CITY2_DRAW:
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
				end
				EM1_UPDATE_X:
				begin
					em1_currX <= em1_currX + em1_dx;
				end
				EM1_DRAW:
				begin
					if (em1_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em1_currX;
					y <= em1_currY;
					
					if (em1_currY >= em1_y_final)
					begin
						em1_active = 1'b0;
						em1_currX <= em1_x_init;
						em1_currY <= em1_y_init;
					end
				end

				
				// Enemy missle 2 graphics
				// ---------------------------------------------------------------------
				EM2_START:
				begin
					em2_currX <= em2_x_init;
					em2_currY <= em2_y_init;
				end
				EM2_UPDATE_Y:
				begin
					em2_currY <= em2_currY + em2_dy;
				end
				EM2_UPDATE_X:
				begin
					em2_currX <= em2_currX - em2_dx;
				end
				EM2_DRAW:
				begin
					if (em2_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em2_currX;
					y <= em2_currY;
					
					if (em2_currY >= em2_y_final)
					begin
						em2_active = 1'b0;
						em2_currX <= em2_x_init;
						em2_currY <= em2_y_init;
					end
				end

				
				// Enemy missle 3 graphics
				// ---------------------------------------------------------------------
				EM3_START:
				begin
					em3_currX <= em3_x_init;
					em3_currY <= em3_y_init;
				end
				EM3_UPDATE_Y:
				begin
					em3_currY <= em3_currY + em3_dy;
				end
				EM3_UPDATE_X:
				begin
					em3_currX <= em3_currX - em3_dx;
				end
				EM3_DRAW:
				begin
					if (em3_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em3_currX;
					y <= em3_currY;
					
					if (em3_currY >= em3_y_final)
					begin
						em3_active = 1'b0;
						em3_currX <= em3_x_init;
						em3_currY <= em3_y_init;
					end
				end

				
				// Enemy missle 4 graphics
				// ---------------------------------------------------------------------
				EM4_START:
				begin
					em4_currX <= em4_x_init;
					em4_currY <= em4_y_init;
				end
				EM4_UPDATE_Y:
				begin
					em4_currY <= em4_currY + em4_dy;
				end
				EM4_UPDATE_X:
				begin
					em4_currX <= em4_currX - em4_dx;
				end
				EM4_DRAW:
				begin
					if (em4_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em4_currX;
					y <= em4_currY;
					
					if (em4_currY >= em4_y_final)
					begin
						em4_active = 1'b0;
						em4_currX <= em4_x_init;
						em4_currY <= em4_y_init;
					end
				end

				
				// Enemy missile 5 graphics
				// ---------------------------------------------------------------------
				EM5_START:
				begin
					em5_currX <= em5_x_init;
					em5_currY <= em5_y_init;
				end
				EM5_UPDATE_Y:
				begin
					em5_currY <= em5_currY + em5_dy;
				end
				EM5_UPDATE_X:
				begin
					em5_currX <= em5_currX + em5_dx;
				end
				EM5_DRAW:
				begin
					if (em5_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em5_currX;
					y <= em5_currY;
					
					if (em5_currY >= em5_y_final)
					begin
						em5_active = 1'b0;
						em5_currX <= em5_x_init;
						em5_currY <= em5_y_init;
					end
				end
			
				// Enemy missile 6 graphics
				// ---------------------------------------------------------------------
				EM6_START:
				begin
					em6_currX <= em6_x_init;
					em6_currY <= em6_y_init;
				end
				EM6_UPDATE_Y:
				begin
					em6_currY <= em6_currY + em6_dy;
				end
				EM6_UPDATE_X:
				begin
					em6_currX <= em6_currX + em6_dx;
				end
				EM6_DRAW:
				begin
					if (em6_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em6_currX;
					y <= em6_currY;
					
					if (em6_currY >= em6_y_final)
					begin
						em6_active = 1'b0;
						em6_currX <= em6_x_init;
						em6_currY <= em6_y_init;
					end
				end
				
				// Enemy missile 7 graphics
				// ---------------------------------------------------------------------
				EM7_START:
				begin
					em7_currX <= em7_x_init;
					em7_currY <= em7_y_init;
				end
				EM7_UPDATE_Y:
				begin
					em7_currY <= em7_currY + em7_dy;
				end
				EM7_UPDATE_X:
				begin
					em7_currX <= em7_currX - em7_dx;
				end
				EM7_DRAW:
				begin
					if (em7_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em7_currX;
					y <= em7_currY;
					
					if (em7_currY >= em7_y_final)
					begin
						em7_active = 1'b0;
						em7_currX <= em7_x_init;
						em7_currY <= em7_y_init;
					end
				end

				// Enemy missile 8 graphics
				// ---------------------------------------------------------------------
				EM8_START:
				begin
					em8_currX <= em8_x_init;
					em8_currY <= em8_y_init;
				end
				EM8_UPDATE_Y:
				begin
					em8_currY <= em8_currY + em8_dy;
				end
				EM8_UPDATE_X:
				begin
					em8_currX <= em8_currX - em8_dx;
				end
				EM8_DRAW:
				begin
					if (em8_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em8_currX;
					y <= em8_currY;
					
					if (em8_currY >= em8_y_final)
					begin
						em8_active = 1'b0;
						em8_currX <= em8_x_init;
						em8_currY <= em8_y_init;
					end
				end
			
				// Enemy missile 9 graphics
				// ---------------------------------------------------------------------
				EM9_START:
				begin
					em9_currX <= em9_x_init;
					em9_currY <= em9_y_init;
				end
				EM9_UPDATE_Y:
				begin
					em9_currY <= em9_currY + em9_dy;
				end
				EM9_UPDATE_X:
				begin
					em9_currX <= em9_currX + em9_dx;
				end
				EM9_DRAW:
				begin
					if (em9_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em9_currX;
					y <= em9_currY;
					
					if (em9_currY >= em9_y_final)
					begin
						em9_active = 1'b0;
						em9_currX <= em9_x_init;
						em9_currY <= em9_y_init;
					end
				end
				
				// Enemy missile 10 graphics
				// ---------------------------------------------------------------------
				EM10_START:
				begin
					em10_currX <= em10_x_init;
					em10_currY <= em10_y_init;
				end
				EM10_UPDATE_Y:
				begin
					em10_currY <= em10_currY + em10_dy;
				end
				EM10_UPDATE_X:
				begin
					em10_currX <= em10_currX + em10_dx;
				end
				EM10_DRAW:
				begin
					if (em10_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em10_currX;
					y <= em10_currY;
					
					if (em10_currY >= em10_y_final)
					begin
						em10_active = 1'b0;
						em10_currX <= em10_x_init;
						em10_currY <= em10_y_init;
					end
				end
				
				// Enemy missile 11 graphics
				// ---------------------------------------------------------------------
				EM11_START:
				begin
					em11_currX <= em11_x_init;
					em11_currY <= em11_y_init;
				end
				EM11_UPDATE_Y:
				begin
					em11_currY <= em11_currY + em11_dy;
				end
				EM11_UPDATE_X:
				begin
					em11_currX <= em11_currX + em11_dx;
				end
				EM11_DRAW:
				begin
					if (em11_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em11_currX;
					y <= em11_currY;
					
					if (em11_currY >= em11_y_final)
					begin
						em11_active = 1'b0;
						em11_currX <= em11_x_init;
						em11_currY <= em11_y_init;
					end
				end

				
				// Enemy missile 12 graphics
				// ---------------------------------------------------------------------
				EM12_START:
				begin
					em12_currX <= em12_x_init;
					em12_currY <= em12_y_init;
				end
				EM12_UPDATE_Y:
				begin
					em12_currY <= em12_currY + em12_dy;
				end
				EM12_UPDATE_X:
				begin
					em12_currX <= em12_currX - em12_dx;
				end
				EM12_DRAW:
				begin
					if (em12_active == 1'b1)
						color <= missile_color;
					else
						color <= back_color;
					x <= em12_currX;
					y <= em12_currY;
					
					if (em12_currY >= em12_y_final)
					begin
						em12_active = 1'b0;
						em12_currX <= em12_x_init;
						em12_currY <= em12_y_init;
					end
				end
				MISSILE_SPAWN:
			begin
				
					//Missile Spawning
					//====================================================================
					
					
					//missile spawn 1
					if(( missile_1_hot_reg == 1) & (missile_1_target_reg == 0))
						begin
							em1_active <= 1'b1;
							color <= missile_color;
					x <= 30;
					y <= 30;
						end
					else
						begin
							em1_active <= 1'b0;
						end
						
					if(( missile_1_hot_reg == 1) & (missile_1_target_reg == 1))
						begin
							em5_active <= 1'b1;
						end
					else
						begin
							em5_active <= 1'b0;
						end
						
					if(( missile_1_hot_reg == 1) & (missile_1_target_reg == 2))
						begin
							em9_active <= 1'b1;
						end
					else
						begin
							em9_active <= 1'b0;
						end
						
					//missile spawn 2
					if(( missile_2_hot_reg == 1) & (missile_2_target_reg == 0))
						begin
							em2_active <= 1'b1;
						end
					else
						begin
							em2_active <= 1'b0;
						end
						
					if(( missile_2_hot_reg == 1) & (missile_2_target_reg == 1))
						begin
							em6_active <= 1'b1;
						end
					else
						begin
							em6_active <= 1'b0;
						end
						
					if(( missile_2_hot_reg == 1) & (missile_2_target_reg == 2))
						begin
							em10_active <= 1'b1;
						end
					else
						begin
							em10_active <= 1'b0;
						end
					
					//missile spawn 3
					if(( missile_3_hot_reg == 1) & (missile_3_target_reg == 0))
						begin
							em3_active <= 1'b1;
						end
					else
						begin
							em3_active <= 1'b0;
						end
						
					if(( missile_3_hot_reg == 1) & (missile_3_target_reg == 1))
						begin
							em7_active <= 1'b1;
						end
					else
						begin
							em7_active <= 1'b0;
						end
						
					if(( missile_3_hot_reg == 1) & (missile_3_target_reg == 2))
						begin
							em11_active <= 1'b1;
						end
					else
						begin
							em11_active <= 1'b0;
						end
						
					//missile spawn4
					
					if(( missile_4_hot_reg == 1) & (missile_4_target_reg == 0))
						begin
							em4_active <= 1'b1;
						end
					else
						begin
							em4_active <= 1'b0;
						end
						
					if(( missile_4_hot_reg == 1) & (missile_4_target_reg == 1))
						begin
							em8_active <= 1'b1;
						end
					else
						begin
							em8_active <= 1'b0;
						end
						
					if(( missile_4_hot_reg == 1) & (missile_4_target_reg == 2))
						begin
							em12_active <= 1'b1;
						end
					else
						begin
							em12_active <= 1'b0;
						end
						
			end
				
			// GAME RUNNER
			// ---------------------------------------------------------------------
			GAME_RUNNER: 
			begin
				game_i <= 32'd0;
			end
			CHECK_MISSILES:
			begin
				game_i <= 32'd0;
			end
			GAME_WAITING:
			begin
				game_i <= game_i + 32'd1;
			end
			
			CHECK_GAME_OVER:
			begin
				if (em1_currY - city1_y_init < 5 | em2_currY - city1_y_init < 5 | em3_currY - city1_y_init < 5 | em4_currY - city1_y_init < 5)
					city1_status <= 1'b0;
		
//				if (em5_currY - 32'd210 < 5)
//					missile_launcher_status <= 1'b0;
//				if (em6_currY - 32'd210 < 5)
//					missile_launcher_status <= 1'b0;
//				if (em7_currY - 32'd210 < 5)
//					missile_launcher_status <= 1'b0;
//				if (em8_currY - 32'd210 < 5)
//					missile_launcher_status <= 1'b0;
				
				if (em9_currY - city2_y_init < 5 | em10_currY - city2_y_init < 5 | em11_currY - city2_y_init < 5 | em12_currY - city2_y_init < 5)
				begin
					city2_status <= 1'b0;
					color <= game_over_color;
					x <= 32'd10;
					y <= 32'd10;
				end
			end
			
			// game over
			// ---------------------------------------------------------------------
			GAME_OVER_START:
			begin
				count_x <= 32'd0;
				count_y <= 32'd0;
				
				color <= game_over_color;
				x <= 32'd10;
				y <= 32'd10;
			end
			GAME_OVER_UPDATE_Y:
			begin
				count_y <= count_y + 32'd1;
				count_x <= 32'd0;
			end
			GAME_OVER_UPDATE_X:
			begin
				count_x <= count_x + 32'd1;
			end
			GAME_OVER_DRAW:
			begin
				color <= game_over_color;
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
