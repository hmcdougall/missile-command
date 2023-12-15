module missile_control(

	// top level module for project
	input clk, 
	input rst,
	
	//player controls
	input player_x_up,
	input player_x_down,
	input player_y_up,
	input player_y_down,
	//player control switches
	input player_x_1,
	input player_x_2,
	input player_x_3,
	input player_x_4,
	
	input player_y_1,
	input player_y_2,
	input player_y_3,
	
		
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
	          enemy_missile_color = 3'b101,
				 player_missile_color = 3'b110,
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
		
		//player missile states
		PM1_START = 8'd127,
		PM1_CHECK_Y = 8'd128,
		PM1_UPDATE_Y = 8'd129,
		PM1_UPDATE_X = 8'd130,
		PM1_DRAW = 8'd131,
		PM1_END = 8'd132,

		PM2_START = 8'd133,
		PM2_CHECK_Y = 8'd134,
		PM2_UPDATE_Y = 8'd135,
		PM2_UPDATE_X = 8'd136,
		PM2_DRAW = 8'd137,
		PM2_END = 8'd138,

		PM3_START = 8'd139,
		PM3_CHECK_Y = 8'd140,
		PM3_UPDATE_Y = 8'd141,
		PM3_UPDATE_X = 8'd142,
		PM3_DRAW = 8'd143,
		PM3_END = 8'd144,

		PM4_START = 8'd145,
		PM4_CHECK_Y = 8'd146,
		PM4_UPDATE_Y = 8'd147,
		PM4_UPDATE_X = 8'd148,
		PM4_DRAW = 8'd149,
		PM4_END = 8'd150,

		PM5_START = 8'd151,
		PM5_CHECK_Y = 8'd152,
		PM5_UPDATE_Y = 8'd153,
		PM5_UPDATE_X = 8'd154,
		PM5_DRAW = 8'd155,
		PM5_END = 8'd156,

		PM6_START = 8'd157,
		PM6_CHECK_Y = 8'd158,
		PM6_UPDATE_Y = 8'd159,
		PM6_UPDATE_X = 8'd160,
		PM6_DRAW = 8'd161,
		PM6_END = 8'd162,

		PM7_START = 8'd163,
		PM7_CHECK_Y = 8'd164,
		PM7_UPDATE_Y = 8'd165,
		PM7_UPDATE_X = 8'd166,
		PM7_DRAW = 8'd167,
		PM7_END = 8'd168,

		PM8_START = 8'd169,
		PM8_CHECK_Y = 8'd170,
		PM8_UPDATE_Y = 8'd171,
		PM8_UPDATE_X = 8'd172,
		PM8_DRAW = 8'd173,
		PM8_END = 8'd174,

		PM9_START = 8'd175,
		PM9_CHECK_Y = 8'd176,
		PM9_UPDATE_Y = 8'd177,
		PM9_UPDATE_X = 8'd178,
		PM9_DRAW = 8'd179,
		PM9_END = 8'd180,

		PM10_START = 8'd181,
		PM10_CHECK_Y = 8'd182,
		PM10_UPDATE_Y = 8'd183,
		PM10_UPDATE_X = 8'd184,
		PM10_DRAW = 8'd185,
		PM10_END = 8'd186,

		PM11_START = 8'd187,
		PM11_CHECK_Y = 8'd188,
		PM11_UPDATE_Y = 8'd189,
		PM11_UPDATE_X = 8'd190,
		PM11_DRAW = 8'd191,
		PM11_END = 8'd192,

		PM12_START = 8'd193,
		PM12_CHECK_Y = 8'd194,
		PM12_UPDATE_Y = 8'd195,
		PM12_UPDATE_X = 8'd196,
		PM12_DRAW = 8'd197,
		PM12_END = 8'd198,

		MOVE_PM1 = 8'd199,
		MOVE_PM2 = 8'd200,
		MOVE_PM3 = 8'd201,
		MOVE_PM4 = 8'd202,
		MOVE_PM5 = 8'd203,
		MOVE_PM6 = 8'd204,
		MOVE_PM7 = 8'd205,
		MOVE_PM8 = 8'd206,
		MOVE_PM9 = 8'd207,
		MOVE_PM10 = 8'd208,
		MOVE_PM11 = 8'd209,
		MOVE_PM12 = 8'd210,
		
		PLAYER_CURSOR_CONTROL = 8'd211,
		
		PLAYER_FIRE_CONTROL = 8'd213,
		
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


	//player control modules
	//--------------------------------------------------------------------
	reg [2:0]player_cursor_x_reg;
	reg [2:0]player_cursor_y_reg;
	wire [2:0]wire_cursor_x;
	wire [2:0]wire_cursor_y;
	reg player_x_1_reg;
	reg player_x_2_reg;
	reg player_x_3_reg;
	reg player_x_4_reg;
	
	reg player_y_1_reg;
	reg player_y_2_reg;
	reg player_y_3_reg;
	
	CURSOR PLAYERCURSOR(clk,rst,player_x_up,player_x_down,player_y_up,player_y_down,wire_cursor_x,wire_cursor_y);
	
	always@(*)
	begin
	
	player_cursor_x_reg = wire_cursor_x;
	player_cursor_y_reg = wire_cursor_y;
	
	
	player_x_1_reg = player_x_1;
	player_x_2_reg = player_x_2;
	player_x_3_reg = player_x_3;
	player_x_4_reg = player_x_4;
	
	player_y_1_reg = player_y_1;
	player_y_2_reg = player_y_2;
	player_y_3_reg = player_y_3;
	end
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
	
	// player missile
	//-----------------------------------------------------------------
	wire [31:0] pm1_x_init = 32'd160;
	wire [31:0] pm1_y_init = 32'd210;
	wire [31:0] pm1_x_final = 32'd64;
	wire [31:0] pm1_y_final = 32'd53;
	wire [31:0] pm1_dx = 32'd6;
	wire [31:0] pm1_dy = 32'd12;
	reg [31:0] pm1_currX = 32'd160;
	reg [31:0] pm1_currY = 32'd210;
	reg pm1_active = 1'b1;

	wire [31:0] pm2_x_init = 32'd160;
	wire [31:0] pm2_y_init = 32'd210;
	wire [31:0] pm2_x_final = 32'd128;
	wire [31:0] pm2_y_final = 32'd53;
	wire [31:0] pm2_dx = 32'd4;
	wire [31:0] pm2_dy = 32'd6;
	reg [31:0] pm2_currX = 32'd160;
	reg [31:0] pm2_currY = 32'd210;
	reg pm2_active = 1'b1;

	wire [31:0] pm3_x_init = 32'd160;
	wire [31:0] pm3_y_init = 32'd210;
	wire [31:0] pm3_x_final = 32'd192;
	wire [31:0] pm3_y_final = 32'd53;
	wire [31:0] pm3_dx = 32'd4;
	wire [31:0] pm3_dy = 32'd6;
	reg [31:0] pm3_currX = 32'd160;
	reg [31:0] pm3_currY = 32'd210;
	reg pm3_active = 1'b1;

	wire [31:0] pm4_x_init = 32'd160;
	wire [31:0] pm4_y_init = 32'd210;
	wire [31:0] pm4_x_final = 32'd256;
	wire [31:0] pm4_y_final = 32'd53;
	wire [31:0] pm4_dx = 32'd6;
	wire [31:0] pm4_dy = 32'd12;
	reg [31:0] pm4_currX = 32'd160;
	reg [31:0] pm4_currY = 32'd210;
	reg pm4_active = 1'b0;

	wire [31:0] pm5_x_init = 32'd160;
	wire [31:0] pm5_y_init = 32'd210;
	wire [31:0] pm5_x_final = 32'd64;
	wire [31:0] pm5_y_final = 32'd105;
	wire [31:0] pm5_dx = 32'd7;
	wire [31:0] pm5_dy = 32'd12;
	reg [31:0] pm5_currX = 32'd160;
	reg [31:0] pm5_currY = 32'd210;
	reg pm5_active = 1'b0;

	wire [31:0] pm6_x_init = 32'd160;
	wire [31:0] pm6_y_init = 32'd210;
	wire [31:0] pm6_x_final = 32'd128;
	wire [31:0] pm6_y_final = 32'd105;
	wire [31:0] pm6_dx = 32'd4;
	wire [31:0] pm6_dy = 32'd7;
	reg [31:0] pm6_currX = 32'd160;
	reg [31:0] pm6_currY = 32'd210;
	reg pm6_active = 1'b0;

	wire [31:0] pm7_x_init = 32'd160;
	wire [31:0] pm7_y_init = 32'd210;
	wire [31:0] pm7_x_final = 32'd192;
	wire [31:0] pm7_y_final = 32'd105;
	wire [31:0] pm7_dx = 32'd4;
	wire [31:0] pm7_dy = 32'd7;
	reg [31:0] pm7_currX = 32'd160;
	reg [31:0] pm7_currY = 32'd210;
	reg pm7_active = 1'b0;

	wire [31:0] pm8_x_init = 32'd160;
	wire [31:0] pm8_y_init = 32'd210;
	wire [31:0] pm8_x_final = 32'd256;
	wire [31:0] pm8_y_final = 32'd105;
	wire [31:0] pm8_dx = 32'd7;
	wire [31:0] pm8_dy = 32'd12;
	reg [31:0] pm8_currX = 32'd160;
	reg [31:0] pm8_currY = 32'd210;
	reg pm8_active = 1'b0;

	wire [31:0] pm9_x_init = 32'd160;
	wire [31:0] pm9_y_init = 32'd210;
	wire [31:0] pm9_x_final = 32'd64;
	wire [31:0] pm9_y_final = 32'd158;
	wire [31:0] pm9_dx = 32'd7;
	wire [31:0] pm9_dy = 32'd12;
	reg [31:0] pm9_currX = 32'd160;
	reg [31:0] pm9_currY = 32'd210;
	reg pm9_active = 1'b0;

	wire [31:0] pm10_x_init = 32'd160;
	wire [31:0] pm10_y_init = 32'd210;
	wire [31:0] pm10_x_final = 32'd128;
	wire [31:0] pm10_y_final = 32'd158;
	wire [31:0] pm10_dx = 32'd4;
	wire [31:0] pm10_dy = 32'd7;
	reg [31:0] pm10_currX = 32'd160;
	reg [31:0] pm10_currY = 32'd210;
	reg pm10_active = 1'b0;

	wire [31:0] pm11_x_init = 32'd160;
	wire [31:0] pm11_y_init = 32'd210;
	wire [31:0] pm11_x_final = 32'd192;
	wire [31:0] pm11_y_final = 32'd158;
	wire [31:0] pm11_dx = 32'd4;
	wire [31:0] pm11_dy = 32'd7;
	reg [31:0] pm11_currX = 32'd160;
	reg [31:0] pm11_currY = 32'd210;
	reg pm11_active = 1'b0;

	wire [31:0] pm12_x_init = 32'd160;
	wire [31:0] pm12_y_init = 32'd210;
	wire [31:0] pm12_x_final = 32'd256;
	wire [31:0] pm12_y_final = 32'd158;
	wire [31:0] pm12_dx = 32'd7;
	wire [31:0] pm12_dy = 32'd12;
	reg [31:0] pm12_currX = 32'd160;
	reg [31:0] pm12_currY = 32'd210;
	reg pm12_active = 1'b0;

	
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
				NS = MOVE_PM1;
			end
			EM12_CHECK_Y: NS = EM12_DRAW;
			EM12_UPDATE_Y: NS = EM12_CHECK_Y;
			EM12_UPDATE_X: NS = EM12_UPDATE_Y;
			EM12_DRAW: 
			begin
				if (em12_active == 1'b0 & em12_currY < em12_y_final)
					NS = EM12_UPDATE_X;
				else
					NS = MOVE_PM1;
			end
			EM12_END: NS = MOVE_PM1;
			
			// Player Missile 1 graphics
			// ---------------------------------------------------------------------
			PM1_START: 
			begin
				NS = PM2_START;
			end
			PM1_CHECK_Y: NS = PM1_DRAW;
			PM1_UPDATE_Y: NS = PM1_CHECK_Y;
			PM1_UPDATE_X: NS = PM1_UPDATE_Y;
			PM1_DRAW: 
			begin
				if (pm1_active == 1'b0 & pm1_currY < pm1_y_final)
					NS = PM1_UPDATE_X;
				else
					NS = MOVE_PM2;
			end
			PM1_END: NS = MOVE_PM2;

			// Player Missile 2 graphics
			// ---------------------------------------------------------------------
			PM2_START: 
			begin
				NS = PM3_START;
			end
			PM2_CHECK_Y: NS = PM2_DRAW;
			PM2_UPDATE_Y: NS = PM2_CHECK_Y;
			PM2_UPDATE_X: NS = PM2_UPDATE_Y;
			PM2_DRAW: 
			begin
				if (pm2_active == 1'b0 & pm2_currY < pm2_y_final)
					NS = PM2_UPDATE_X;
				else
					NS = MOVE_PM3;
			end
			PM2_END: NS = MOVE_PM3;

			// Player Missile 3 graphics
			// ---------------------------------------------------------------------
			PM3_START: 
			begin
				NS = PM3_START;
			end
			PM3_CHECK_Y: NS = PM3_DRAW;
			PM3_UPDATE_Y: NS = PM3_CHECK_Y;
			PM3_UPDATE_X: NS = PM3_UPDATE_Y;
			PM3_DRAW: 
			begin
				if (pm3_active == 1'b0 & pm3_currY < pm3_y_final)
					NS = PM3_UPDATE_X;
				else
					NS = MOVE_PM4;
			end
			PM3_END: NS = MOVE_PM4;

			// Player Missile 4 graphics
			// ---------------------------------------------------------------------
			PM4_START: 
			begin
				NS = PM5_START;
			end
			PM4_CHECK_Y: NS = PM4_DRAW;
			PM4_UPDATE_Y: NS = PM4_CHECK_Y;
			PM4_UPDATE_X: NS = PM4_UPDATE_Y;
			PM4_DRAW: 
			begin
				if (pm4_active == 1'b0 & pm4_currY < pm4_y_final)
					NS = PM4_UPDATE_X;
				else
					NS = MOVE_PM5;
			end
			PM4_END: NS = MOVE_PM5;

			// Player Missile 5 graphics
			// ---------------------------------------------------------------------
			PM5_START: 
			begin
				NS = PM6_START;
			end
			PM5_CHECK_Y: NS = PM5_DRAW;
			PM5_UPDATE_Y: NS = PM5_CHECK_Y;
			PM5_UPDATE_X: NS = PM5_UPDATE_Y;
			PM5_DRAW: 
			begin
				if (pm5_active == 1'b0 & pm5_currY < pm5_y_final)
					NS = PM5_UPDATE_X;
				else
					NS = MOVE_PM6;
			end
			PM5_END: NS = MOVE_PM6;

			// Player Missile 6 graphics
			// ---------------------------------------------------------------------
			PM6_START: 
			begin
				NS = PM7_START;
			end
			PM6_CHECK_Y: NS = PM6_DRAW;
			PM6_UPDATE_Y: NS = PM6_CHECK_Y;
			PM6_UPDATE_X: NS = PM6_UPDATE_Y;
			PM6_DRAW: 
			begin
				if (pm6_active == 1'b0 & pm6_currY < pm6_y_final)
					NS = PM6_UPDATE_X;
				else
					NS = MOVE_PM7;
			end
			PM6_END: NS = MOVE_PM7;

			// Player Missile 7 graphics
			// ---------------------------------------------------------------------
			PM7_START: 
			begin
				NS = PM8_START;
			end
			PM7_CHECK_Y: NS = PM7_DRAW;
			PM7_UPDATE_Y: NS = PM7_CHECK_Y;
			PM7_UPDATE_X: NS = PM7_UPDATE_Y;
			PM7_DRAW: 
			begin
				if (pm7_active == 1'b0 & pm7_currY < pm7_y_final)
					NS = PM7_UPDATE_X;
				else
					NS = MOVE_PM8;
			end
			PM7_END: NS = MOVE_PM8;

			// Player Missile 8 graphics
			// ---------------------------------------------------------------------
			PM8_START: 
			begin
				NS = PM9_START;
			end
			PM8_CHECK_Y: NS = PM8_DRAW;
			PM8_UPDATE_Y: NS = PM8_CHECK_Y;
			PM8_UPDATE_X: NS = PM8_UPDATE_Y;
			PM8_DRAW: 
			begin
				if (pm8_active == 1'b0 & pm8_currY < pm8_y_final)
					NS = PM8_UPDATE_X;
				else
					NS = MOVE_PM9;
			end
			PM8_END: NS = MOVE_PM9;

			// Player Missile 9 graphics
			// ---------------------------------------------------------------------
			PM9_START: 
			begin
				NS = PM10_START;
			end
			PM9_CHECK_Y: NS = PM9_DRAW;
			PM9_UPDATE_Y: NS = PM9_CHECK_Y;
			PM9_UPDATE_X: NS = PM9_UPDATE_Y;
			PM9_DRAW: 
			begin
				if (pm9_active == 1'b0 & pm9_currY < pm9_y_final)
					NS = PM9_UPDATE_X;
				else
					NS = MOVE_PM10;
			end
			PM9_END: NS = MOVE_PM10;

			// Player Missile 10 graphics
			// ---------------------------------------------------------------------
			PM10_START: 
			begin
				NS = PM11_START;
			end
			PM10_CHECK_Y: NS = PM10_DRAW;
			PM10_UPDATE_Y: NS = PM10_CHECK_Y;
			PM10_UPDATE_X: NS = PM10_UPDATE_Y;
			PM10_DRAW: 
			begin
				if (pm10_active == 1'b0 & pm10_currY < pm10_y_final)
					NS = PM10_UPDATE_X;
				else
					NS = MOVE_PM11;
			end
			PM10_END: NS = MOVE_PM11;

			// Player Missile 11 graphics
			// ---------------------------------------------------------------------
			PM11_START: 
			begin
				NS = PM12_START;
			end
			PM11_CHECK_Y: NS = PM11_DRAW;
			PM11_UPDATE_Y: NS = PM11_CHECK_Y;
			PM11_UPDATE_X: NS = PM11_UPDATE_Y;
			PM11_DRAW: 
			begin
				if (pm11_active == 1'b0 & pm11_currY < pm11_y_final)
					NS = PM11_UPDATE_X;
				else
					NS = MOVE_PM12;
			end
			PM11_END: NS = MOVE_PM12;

			// Player Missile 12 graphics
			// ---------------------------------------------------------------------
			PM12_START: 
			begin
				NS = CHECK_GAME_OVER;
			end
			PM12_CHECK_Y: NS = PM12_DRAW;
			PM12_UPDATE_Y: NS = PM12_CHECK_Y;
			PM12_UPDATE_X: NS = PM12_UPDATE_Y;
			PM12_DRAW: 
			begin
				if (pm12_active == 1'b0 & pm12_currY < pm12_y_final)
					NS = PM12_UPDATE_X;
				else
					NS = CHECK_GAME_OVER;
			end
			PM12_END: NS = CHECK_GAME_OVER;

			
			
			// GAME RUNNER
			// ---------------------------------------------------------------------
			GAME_RUNNER: NS = MOVE_EM1;
			
			MOVE_EM1: 
			begin
				if(em1_active == 1)
					NS = EM1_UPDATE_X;
				else
					NS = MOVE_EM2;
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
				NS = MOVE_PM1;
				end
			
			end
			
			MOVE_PM1: 
			begin
				if(pm1_active == 1)
					NS = PM1_UPDATE_X;
				else
					NS = MOVE_PM2;
			end
			MOVE_PM2: 
			begin
			
				if(pm2_active == 1)
				begin
				NS = PM2_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM3;
				end
			
			end
			MOVE_PM3:
			begin
			
				if(pm3_active == 1)
				begin
				NS = PM3_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM4;
				end
			
			end
			MOVE_PM4:
			begin
			
				if(pm4_active == 1)
				begin
				NS = PM4_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM5;
				end
			
			end
			MOVE_PM5:
			begin
			
				if(pm5_active == 1)
				begin
				NS = PM5_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM6;
				end
			
			end
			MOVE_PM6:
			begin
			
				if(pm6_active == 1)
				begin
				NS = PM6_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM7;
				end
			
			end
			
			MOVE_PM7:
			begin
			
				if(pm7_active == 1)
				begin
				NS = PM7_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM8;
				end
			
			end
			
			MOVE_PM8:
			begin
			
				if(pm8_active == 1)
				begin
				NS = PM8_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM9;
				end
			
			end
			MOVE_PM9:
			begin
			
				if(pm9_active == 1)
				begin
				NS = PM9_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM10;
				end
			
			end		
			MOVE_PM10:
			begin
			
				if(pm10_active == 1)
				begin
				NS = PM10_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM11;
				end
			
			end
			MOVE_PM11:
			begin
			
				if(pm11_active == 1)
				begin
				NS = PM11_UPDATE_X;
				end
				
				else
				begin
				NS = MOVE_PM12;
				end
			
			end
			MOVE_PM12:
			begin
			
				if(pm12_active == 1)
				begin
				NS = PM12_UPDATE_X;
				end
				
				else
				begin
				NS = CHECK_MISSILES;
				end
			
			end

			
			CHECK_MISSILES: NS = PLAYER_CURSOR_CONTROL;
			PLAYER_CURSOR_CONTROL: NS = PLAYER_FIRE_CONTROL;
			
			PLAYER_FIRE_CONTROL: NS = MISSILE_SPAWN;
			
			MISSILE_SPAWN: NS = GAME_WAIT;
			GAME_WAIT:
			begin
				if (game_i < 32'd12500000)
					NS = GAME_WAITING;
				else
					NS = CHECK_GAME_OVER;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
						color <= enemy_missile_color;
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
				
				
				// Player missile 1 graphics
				// ---------------------------------------------------------------------
				PM1_START:
				begin
					pm1_currX <= pm1_x_init;
					pm1_currY <= pm1_y_init;
				end
				PM1_UPDATE_Y:
				begin
					pm1_currY <= pm1_currY - pm1_dy;
				end
				PM1_UPDATE_X:
				begin
					pm1_currX <= pm1_currX - pm1_dx;
				end
				PM1_DRAW:
				begin
					if (pm1_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm1_currX;
					y <= pm1_currY;
					
					if (pm1_currY < pm1_y_final)
					begin
						pm1_active = 1'b0;
						pm1_currX <= pm1_x_init;
						pm1_currY <= pm1_y_init;
					end
				end

				// Player missile 2 graphics
				// ---------------------------------------------------------------------
				PM2_START:
				begin
					pm2_currX <= pm2_x_init;
					pm2_currY <= pm2_y_init;
				end
				PM2_UPDATE_Y:
				begin
					pm2_currY <= pm2_currY - pm2_dy;
				end
				PM2_UPDATE_X:
				begin
					pm2_currX <= pm2_currX - pm2_dx;
				end
				PM2_DRAW:
				begin
					if (pm2_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm2_currX;
					y <= pm2_currY;
					
					if (pm2_currY < pm2_y_final)
					begin
						pm2_active = 1'b0;
						pm2_currX <= pm2_x_init;
						pm2_currY <= pm2_y_init;
					end
				end

				// Player missile 3 graphics
				// ---------------------------------------------------------------------
				PM3_START:
				begin
					pm3_currX <= pm3_x_init;
					pm3_currY <= pm3_y_init;
				end
				PM3_UPDATE_Y:
				begin
					pm3_currY <= pm3_currY - pm3_dy;
				end
				PM3_UPDATE_X:
				begin
					pm3_currX <= pm3_currX + pm3_dx;
				end
				PM3_DRAW:
				begin
					if (pm3_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm3_currX;
					y <= pm3_currY;
					
					if (pm3_currY < pm3_y_final)
					begin
						pm3_active = 1'b0;
						pm3_currX <= pm3_x_init;
						pm3_currY <= pm3_y_init;
					end
				end

				// Player missile 4 graphics
				// ---------------------------------------------------------------------
				PM4_START:
				begin
					pm4_currX <= pm4_x_init;
					pm4_currY <= pm4_y_init;
				end
				PM4_UPDATE_Y:
				begin
					pm4_currY <= pm4_currY - pm4_dy;
				end
				PM4_UPDATE_X:
				begin
					pm4_currX <= pm4_currX + pm4_dx;
				end
				PM4_DRAW:
				begin
					if (pm4_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm4_currX;
					y <= pm4_currY;
					
					if (pm4_currY < pm4_y_final)
					begin
						pm4_active = 1'b0;
						pm4_currX <= pm4_x_init;
						pm4_currY <= pm4_y_init;
					end
				end

				// Player missile 5 graphics
				// ---------------------------------------------------------------------
				PM5_START:
				begin
					pm5_currX <= pm5_x_init;
					pm5_currY <= pm5_y_init;
				end
				PM5_UPDATE_Y:
				begin
					pm5_currY <= pm5_currY - pm5_dy;
				end
				PM5_UPDATE_X:
				begin
					pm5_currX <= pm5_currX - pm5_dx;
				end
				PM5_DRAW:
				begin
					if (pm5_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm5_currX;
					y <= pm5_currY;
					
					if (pm5_currY < pm5_y_final)
					begin
						pm5_active = 1'b0;
						pm5_currX <= pm5_x_init;
						pm5_currY <= pm5_y_init;
					end
				end

				// Player missile 6 graphics
				// ---------------------------------------------------------------------
				PM6_START:
				begin
					pm6_currX <= pm6_x_init;
					pm6_currY <= pm6_y_init;
				end
				PM6_UPDATE_Y:
				begin
					pm6_currY <= pm6_currY - pm6_dy;
				end
				PM6_UPDATE_X:
				begin
					pm6_currX <= pm6_currX - pm6_dx;
				end
				PM6_DRAW:
				begin
					if (pm6_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm6_currX;
					y <= pm6_currY;
					
					if (pm6_currY < pm6_y_final)
					begin
						pm6_active = 1'b0;
						pm6_currX <= pm6_x_init;
						pm6_currY <= pm6_y_init;
					end
				end

				// Player missile 7 graphics
				// ---------------------------------------------------------------------
				PM7_START:
				begin
					pm7_currX <= pm7_x_init;
					pm7_currY <= pm7_y_init;
				end
				PM7_UPDATE_Y:
				begin
					pm7_currY <= pm7_currY - pm7_dy;
				end
				PM7_UPDATE_X:
				begin
					pm7_currX <= pm7_currX + pm7_dx;
				end
				PM7_DRAW:
				begin
					if (pm7_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm7_currX;
					y <= pm7_currY;
					
					if (pm7_currY < pm7_y_final)
					begin
						pm7_active = 1'b0;
						pm7_currX <= pm7_x_init;
						pm7_currY <= pm7_y_init;
					end
				end
	
				// Player missile 8 graphics
				// ---------------------------------------------------------------------
				PM8_START:
				begin
					pm8_currX <= pm8_x_init;
					pm8_currY <= pm8_y_init;
				end
				PM8_UPDATE_Y:
				begin
					pm8_currY <= pm8_currY - pm8_dy;
				end
				PM8_UPDATE_X:
				begin
					pm8_currX <= pm8_currX + pm8_dx;
				end
				PM8_DRAW:
				begin
					if (pm8_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm8_currX;
					y <= pm8_currY;
					
					if (pm8_currY < pm8_y_final)
					begin
						pm8_active = 1'b0;
						pm8_currX <= pm8_x_init;
						pm8_currY <= pm8_y_init;
					end
				end

				//Player missile 9 graphics
				// ---------------------------------------------------------------------
				PM9_START:
				begin
					pm9_currX <= pm9_x_init;
					pm9_currY <= pm9_y_init;
				end
				PM9_UPDATE_Y:
				begin
					pm9_currY <= pm9_currY - pm9_dy;
				end
				PM9_UPDATE_X:
				begin
					pm9_currX <= pm9_currX - pm9_dx;
				end
				PM9_DRAW:
				begin
					if (pm9_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm9_currX;
					y <= pm9_currY;
					
					if (pm9_currY < pm9_y_final)
					begin
						pm9_active = 1'b0;
						pm9_currX <= pm9_x_init;
						pm9_currY <= pm9_y_init;
					end
				end
	
				// Player missile 10 graphics
				// ---------------------------------------------------------------------
				PM10_START:
				begin
					pm10_currX <= pm10_x_init;
					pm10_currY <= pm10_y_init;
				end
				PM10_UPDATE_Y:
				begin
					pm10_currY <= pm10_currY - pm10_dy;
				end
				PM10_UPDATE_X:
				begin
					pm10_currX <= pm10_currX - pm10_dx;
				end
				PM10_DRAW:
				begin
					if (pm10_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm10_currX;
					y <= pm10_currY;
					
					if (pm10_currY < pm10_y_final)
					begin
						pm10_active = 1'b0;
						pm10_currX <= pm10_x_init;
						pm10_currY <= pm10_y_init;
					end
				end

				// Player missile 11 graphics
				// ---------------------------------------------------------------------
				PM11_START:
				begin
					pm11_currX <= pm11_x_init;
					pm11_currY <= pm11_y_init;
				end
				PM11_UPDATE_Y:
				begin
					pm11_currY <= pm11_currY - pm11_dy;
				end
				PM11_UPDATE_X:
				begin
					pm11_currX <= pm11_currX + pm11_dx;
				end
				PM11_DRAW:
				begin
					if (pm11_active == 11'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm11_currX;
					y <= pm11_currY;
					
					if (pm11_currY < pm11_y_final)
					begin
						pm11_active = 1'b0;
						pm11_currX <= pm11_x_init;
						pm11_currY <= pm11_y_init;
					end
				end

				// Player missile 12 graphics
				// ---------------------------------------------------------------------
				PM12_START:
				begin
					pm12_currX <= pm12_x_init;
					pm12_currY <= pm12_y_init;
				end
				PM12_UPDATE_Y:
				begin
					pm12_currY <= pm12_currY - pm12_dy;
				end
				PM12_UPDATE_X:
				begin
					pm12_currX <= pm12_currX + pm12_dx;
				end
				PM12_DRAW:
				begin
					if (pm12_active == 1'b1)
						color <= player_missile_color;
					else
						color <= back_color;
					x <= pm12_currX;
					y <= pm12_currY;
					
					if (pm12_currY < pm12_y_final)
					begin
						pm12_active = 12'b0;
						pm12_currX <= pm12_x_init;
						pm12_currY <= pm12_y_init;
					end
				end

				//Player controls
				//==========================================================================
				
				//cursor position
				//------------------------------------------------------------------------------
				PLAYER_CURSOR_CONTROL:
					begin
			
//		//Col 1	X= 0
//			//-------------------------------------------------------------------------------
//					if( (player_x_1_reg == 1) & (player_y_1_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 64;
//							y = 53;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 64;
//							y = 53;
//						end
//					
//					
//					if( (player_x_1_reg == 1) & (player_y_2_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 64;
//							y = 105;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 64;
//							y = 105;
//						end
//						
//						
//					if( (player_x_1_reg == 1) & (player_y_3_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 64;
//							y = 158;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 64;
//							y = 158;
//						end
//					//Col 2 X =1
//					//--------------------------------------------------------------------
//					
//					if( (player_x_2_reg == 1) & (player_y_1_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 128;
//							y = 53;
//						end
//					else
//						begin
//							color <= back_color;
//							x = 128;
//							y = 53;
//						end
//						
//						
//					if( (player_x_2_reg == 1) & (player_y_2_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 128;
//							y = 105;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 128;
//							y = 105;
//						end
//						
//					if( (player_x_2_reg == 1) & (player_y_3_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 128;
//							y = 158;
//						end
//					else
//						begin
//							color <= back_color;
//							x = 128;
//							y = 158;
//						end
//						
//				//Col 3  X=2
//				//--------------------------------------------------------------------------
//					if( (player_x_3_reg == 1) & (player_y_1_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 192;
//							y = 53;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 192;
//							y = 53;
//						end
//						
//					if( (player_x_3_reg == 1) & (player_y_2_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 192;
//							y = 105;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 192;
//							y = 105;
//						end
//					
//					if( (player_x_3_reg == 1) & (player_y_3_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 192;
//							y = 158;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 192;
//							y = 158;
//						end
//				//Col 4	X=3
//				//----------------------------------------------------------------------------
//					if( (player_x_4_reg == 1) & (player_y_1_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 256;
//							y = 53;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 256;
//							y = 53;
//						end
//						
//					if( (player_x_4_reg == 1) & (player_y_2_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 256;
//							y = 105;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 256;
//							y = 105;
//						end
//					
//					if( (player_x_4_reg == 1) & (player_y_3_reg == 1))
//						begin
//							color <= player_missile_color;
//							x = 256;
//							y = 158;
//						end
//					else
//						begin
//						color <= back_color;
//							x = 256;
//							y = 158;
//						end	
			//Col 1	x= 0
			//-------------------------------------------------------------------------------
				PLAYER_CURSOR_CONTROL_1:
					begin
					
						if( (player_cursor_x_reg == 0) &  (player_cursor_y_reg == 0))
							begin
								color <= player_missile_color;
								x = 64;
								y = 53;
							end
						else
							begin
							color <= back_color;
								x = 64;
								y = 53;
							end
					end
					
//						if( (player_cursor_x_reg == 0) &  (player_cursor_y_reg == 1))
//							begin
//								color <= player_missile_color;
//								x = 64;
//								y = 105;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 64;
//								y = 105;
//							end
//					
//					
//						if( (player_cursor_x_reg == 0) &  (player_cursor_y_reg == 2))
//							begin
//								color <= player_missile_color;
//								x = 64;
//								y = 158;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 64;
//								y = 158;
//							end
//					
//					
//					//Col 2 x =1
//					//--------------------------------------------------------------------
//				
//					
//						if( (player_cursor_x_reg == 1) &  (player_cursor_y_reg == 0))
//							begin
//								color <= player_missile_color;
//								x = 128;
//								y = 53;
//							end
//						else
//							begin
//								color <= back_color;
//								x = 128;
//								y = 53;
//							end
//					
//					
//						if( (player_cursor_x_reg == 1) &  (player_cursor_y_reg == 1))
//							begin
//								color <= player_missile_color;
//								x = 128;
//								y = 105;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 128;
//								y = 105;
//							end
//					
//						if( (player_cursor_x_reg == 1) &  (player_cursor_y_reg == 2))
//							begin
//								color <= player_missile_color;
//								x = 128;
//								y = 158;
//							end
//						else
//							begin
//								color <= back_color;
//								x = 128;
//								y = 158;
//							end
//					end
//				//Col 3  x=2
//				//--------------------------------------------------------------------------
//				
//						if( (player_cursor_x_reg == 2) &  (player_cursor_y_reg == 0))
//							begin
//								color <= player_missile_color;
//								x = 192;
//								y = 53;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 192;
//								y = 53;
//							end
//					
//						if( (player_cursor_x_reg == 2) &  (player_cursor_y_reg == 1))
//							begin
//								color <= player_missile_color;
//								x = 192;
//								y = 105;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 192;
//								y = 105;
//							end
//					
//						
//						if( (player_cursor_x_reg == 2) &  (player_cursor_y_reg == 2))
//							begin
//								color <= player_missile_color;
//								x = 192;
//								y = 158;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 192;
//								y = 158;
//							end
//					
//						
//				//Col 4	x=3
//				//----------------------------------------------------------------------------
//			
//					
//						if( (player_cursor_x_reg == 3) &  (player_cursor_y_reg == 0))
//							begin
//								color <= player_missile_color;
//								x = 256;
//								y = 53;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 256;
//								y = 53;
//							end
//					
//					
//						if( (player_cursor_x_reg == 3) &  (player_cursor_y_reg == 1))
//							begin
//								color <= player_missile_color;
//								x = 256;
//								y = 105;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 256;
//								y = 105;
//							end
//					
//			
//					
//						if( (player_cursor_x_reg == 3) &  (player_cursor_y_reg == 2))
//							begin
//								color <= player_missile_color;
//								x = 256;
//								y = 158;
//							end
//						else
//							begin
//							color <= back_color;
//								x = 256;
//								y = 158;
//							end
					
					
				end
				PLAYER_FIRE_CONTROL:
				begin
				
				end
				MISSILE_SPAWN:
			begin
				
					//Missile Spawning
					//====================================================================
					
					
					//missile spawn 1
					//-------------------------------------------------------------------
					if(( missile_1_hot_reg == 1) & (missile_1_target_reg == 0))
						begin
							em1_active <= 1'b1;
							color <= enemy_missile_color;
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
					//---------------------------------------------------------------
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
					//---------------------------------------------------------------
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
					//----------------------------------------------------------------
					
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
