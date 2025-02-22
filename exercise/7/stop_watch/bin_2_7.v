module bin_2_7 (x, pause, clk,  s);
input [3:0] x;
input pause,clk;
output [6:0] s;
reg  [3:0] paused_counter;

assign s = (paused_counter == 4'd0 ) ? 7'b1111110 : 
			(paused_counter == 4'd1 ) ? 7'b0110000 :
			(paused_counter == 4'd2 ) ? 7'b1101101 :
			(paused_counter == 4'd3 ) ? 7'b1111001 :
			(paused_counter == 4'd4 ) ? 7'b0110011 : 
			(paused_counter == 4'd5 ) ? 7'b1011011 :
			(paused_counter == 4'd6 ) ? 7'b1011111 : 
			(paused_counter == 4'd7 ) ? 7'b1110010 :
			(paused_counter == 4'd8 ) ? 7'b1111111 : 
			(paused_counter == 4'd9 ) ? 7'b1111011 :
			(paused_counter == 4'd10) ? 7'b1110111 : 
			(paused_counter == 4'd11) ? 7'b0011111 :
			(paused_counter == 4'd12) ? 7'b1001110 : 
			(paused_counter == 4'd13) ? 7'b0111101 :
			(paused_counter == 4'd14) ? 7'b1001111 : 7'b1000111 ;
			
always@(posedge clk)	begin		
		if(pause) paused_counter <= x;
		else paused_counter <= paused_counter;
		end	
endmodule	