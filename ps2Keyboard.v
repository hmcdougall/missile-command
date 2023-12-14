// resource: https://github.com/alecamaracm/Verilog-Game-Engine-with-PowerPoint-designer/blob/master/VerilogExample/keyboard.v
module ps2Keyboard(CLOCK,ps2ck,ps2dt,enter,space,arrows,wasd);

	inout ps2ck,ps2dt;	
	
	output reg [3:0]arrows;
	output reg [3:0]wasd;
	output reg enter,space;
	input CLOCK;
	reg releasex;
	reg releaseCK;
	reg [3:0]position;
	reg [5:0]skipCycles;	
	reg [2:0]e0;
	reg [55:0]nonActivity; //On a timeout, the data bytes reset.
	wire[7:0]ps2_data;
	reg	[7:0]last_ps2_data;
	wire ps2_newData;
	mouse_Inner_controller innerMouse (   //Don't touch anything in this declaration. It deals with the data adquisition and basic commands to the mouse.
	.CLOCK_50			(CLOCK),
	.reset				(1'b0),
	.PS2_CLK			(ps2ck),
 	.PS2_DAT			(ps2dt),
	.received_data		(ps2_data),
	.received_data_en	(ps2_newData)
	);
	always @(posedge ps2_newData)
	begin
				case (ps2_data)
					8'hF0: 
					begin //releasex will be 1 when the key has been released.
						releasex=1'b1;
						releaseCK=1'b0;		
					end
					8'hE0:
					begin
						e0=3'd3;
					end
				endcase
				if(e0<=0) //Certain keys have a pre-code
				begin
					case (ps2_data)
					//arrow keys
						8'h75: arrows[0]<=!releasex;   //up
						8'h6B: arrows[1]<=!releasex;   //down
						8'h72: arrows[2]<=!releasex;   //left
						8'h74: arrows[3]<=!releasex;   //right
						8'h29: space<=!releasex;		//spacebar
						8'h5A: enter<=!releasex;		  // enter
						/* WASD keys
						8'h1D: wasd[0]<=!releasex;//w
						8'h1B: wasd[2]<=!releasex;//s
						8'h1C: wasd[1]<=!releasex;//a
						8'h23: wasd[3]<=!releasex;//d
						*/
					endcase
				end
				//else if(e0>0)
				//	if (ps2_data == 8'h71)
					//	delete<=!releasex; // delete

			if(releaseCK==1'b1)
			begin
				releasex=0;
				releaseCK=0;
			end
			else
			begin
				if(releasex==1'b1)
				begin
					releaseCK=1'b1;
				end
			end
			
			if(e0>3'b0)
			begin
				e0=e0-3'b1;			
			end
	end
endmodule
