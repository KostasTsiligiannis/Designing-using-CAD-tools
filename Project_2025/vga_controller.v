`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Reference Book: 
// Chu, Pong P.
// Wiley, 2008
// "FPGA Prototyping by Verilog Examples: Xilinx Spartan-3 Version" 
// 
// Adapted for the Basys 3 by David J. Marion
// Comments by David J. Marion
//
// FOR USE WITH AN FPGA THAT HAS A 100MHz CLOCK SIGNAL ONLY.
// VGA Mode
// 640x480 pixels VGA screen with 25MHz pixel rate based on 60 Hz refresh rate
// 800 pixels/line * 525 lines/screen * 60 screens/second = ~25.2M pixels/second
//
// A 25MHz signal will suffice. The Basys 3 has a 100MHz signal available, so a
// 25MHz tick is created for syncing the pixel counts, pixel tick, horiz sync, 
// vert sync, and video on signals.
//////////////////////////////////////////////////////////////////////////////////

module vga_controller(
    input clk_100MHz,   // from Basys 3
    input reset,        // system reset
    input [7:0] scan,
    output hsync,       // horizontal sync
    output vsync,       // vertical sync
    output reg [2:0] red,
	output reg [2:0] green,
	output reg [2:0] blue,
	output [9:0] x,     // pixel count/position of pixel x, max 0-799
	output p_tick,      // the 25MHz pixel/second rate signal, pixel tick
	output video_on,    // ON while pixel counts for x and y and within display area
	output [9:0] y      // pixel count/position of pixel y, max 0-524
    );
    
    // Based on VGA standards found at vesa.org for 640x480 resolution
    // Total horizontal width of screen = 800 pixels, partitioned  into sections
    parameter HD = 640;             // horizontal display area width in pixels
    parameter HF = 48;              // horizontal front porch width in pixels
    parameter HB = 16;              // horizontal back porch width in pixels
    parameter HR = 96;              // horizontal retrace width in pixels
    parameter HMAX = HD+HF+HB+HR-1; // max value of horizontal counter = 799
    // Total vertical length of screen = 525 pixels, partitioned into sections
    parameter VD = 400;             // vertical display area length in pixels 
    parameter VF = 35;              // vertical front porch length in pixels  
    parameter VB = 12;              // vertical back porch length in pixels   
    parameter VR = 2;               // vertical retrace length in pixels  
    parameter VMAX = VD+VF+VB+VR-1; // max value of vertical counter    
    
    // *** Generate 25MHz from 100MHz *********************************************************
	reg  [1:0] r_25MHz;
	wire w_25MHz;
	
	always @(posedge clk_100MHz or posedge reset)
		if(reset)
		  r_25MHz <= 0;
		else
		  r_25MHz <= r_25MHz + 1;
	
	assign w_25MHz = (r_25MHz == 0) ? 1 : 0; // assert tick 1/4 of the time
    // ****************************************************************************************
    
    // Counter Registers, two each for buffering to avoid glitches
    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;
    
    // Output Buffers
    reg v_sync_reg, h_sync_reg;
    wire v_sync_next, h_sync_next;
    
    // Register Control
    always @(posedge clk_100MHz or posedge reset)
        if(reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            v_sync_reg  <= 1'b0;
            h_sync_reg  <= 1'b0;
        end
        else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end
         
    //Logic for horizontal counter
    always @(posedge w_25MHz or posedge reset)      // pixel tick
        if(reset)
            h_count_next = 0;
        else
            if(h_count_reg == HMAX)                 // end of horizontal scan
                h_count_next = 0;
            else
                h_count_next = h_count_reg + 1;         
  
    // Logic for vertical counter
    always @(posedge w_25MHz or posedge reset)
        if(reset)
            v_count_next = 0;
        else
            if(h_count_reg == HMAX)                 // end of horizontal scan
                if((v_count_reg == VMAX))           // end of vertical scan
                    v_count_next = 0;
                else
                    v_count_next = v_count_reg + 1;
        
    // h_sync_next asserted within the horizontal retrace area
    assign h_sync_next = ~(h_count_reg >= (HD+HB) && h_count_reg <= (HD+HB+HR-1));
    
    // v_sync_next asserted within the vertical retrace area
    assign v_sync_next = (v_count_reg >= (VD+VB) && v_count_reg <= (VD+VB+VR-1));
    
    // Video ON/OFF - only ON while pixel counts are within the display area
    assign video_on = (h_count_reg < HD) && (v_count_reg < VD); // 0-639 and 0-479 respectively
    
	// *** ÈÝóåéò Y ôùí ãñáììþí ôïõ ðåíôáãñÜììïõ ***
	parameter Y_LINE1 = 280;
	parameter Y_LINE2 = 260;
	parameter Y_LINE3 = 240;
	parameter Y_LINE4 = 220;
	parameter Y_LINE5 = 200;

	// *** ÈÝóåéò Y ôùí íïôþí ***
	parameter Y_C = 300;
	parameter Y_D = 290;
	parameter Y_E = 280;
	parameter Y_F = 270;
	parameter Y_G = 260;
	parameter Y_A = 250;
	parameter Y_B = 240;
	

	// *** ÓõíôåôáãìÝíåò êõêëéêïý óõìâüëïõ (íüôáò) ***
	parameter NOTE_X = 320; // Óôáèåñü X óôï êÝíôñï ôçò ïèüíçò
	parameter NOTE_RADIUS = 10; // Áêôßíá êýêëïõ
	parameter STEM_HEIGHT = 25; // ¾øïò ôïõ êïôóáíéïý
	parameter FLAG_WIDTH = 10; // ÐëÜôïò ôçò óçìáßáò ôïõ üãäïïõ
	parameter FLAG_HEIGHT = 5; // ¾øïò ôçò óçìáßáò ôïõ üãäïïõ
	parameter LEDGER_LINE_WIDTH = 20;
	// Õðïëïãéóìüò èÝóçò íüôáò
	wire [9:0] note_y;
	assign note_y = (scan == 8'h23) ? Y_C :	//Íôï
	                (scan == 8'h2D) ? Y_D :	//Ñå
	                (scan == 8'h3A) ? Y_E :	//Ìé
	                (scan == 8'h2B) ? Y_F :	//Öá
	                (scan == 8'h1B) ? Y_G :	//Óïë
	                (scan == 8'h4B) ? Y_A :	//Ëá
	                (scan == 8'h21) ? Y_B :	/*Óé*/ 10'd650; // Åêôüò ïèüíçò áí äåí õðÜñ÷åé íüôá
					//(scan == 8'h76) ? : 10'd500; 

	// *** Õðïëïãéóìüò áðüóôáóçò ãéá ôç ó÷åäßáóç êýêëïõ (íüôáò) ***
	/*wire [9:0] draw_note;
	assign draw_note = ((hcount - NOTE_X) * (hcount - NOTE_X) + (vcount - note_y) * (vcount - note_y)) <= (NOTE_RADIUS * NOTE_RADIUS);

	// *** Õðïëïãéóìüò ãéá ó÷åäßáóç ãñáììþí ðåíôáãñÜììïõ ***
	wire draw_staff;
	assign draw_staff = (vcount == Y_LINE1) || (vcount == Y_LINE2) ||
	                    (vcount == Y_LINE3) || (vcount == Y_LINE4) || (vcount == Y_LINE5);*/
						


				   

	// *** Ñýèìéóç ÷ñùìÜôùí VGA ***
	always @(posedge w_25MHz or posedge reset) begin
			if (reset) begin
				red   <= 3'b000;
				green <= 3'b000;
				blue  <= 3'b000;
			end
			else if (video_on && (scan != 8'h76)) begin
				if ( // Ó÷åäßáóç êõêëéêïý ìÝñïõò ôçò íüôáò
				((h_count_reg - NOTE_X) * (h_count_reg - NOTE_X) + 
				 (v_count_reg - note_y) * (v_count_reg - note_y)) <= (NOTE_RADIUS * NOTE_RADIUS) ||

				// Ó÷åäßáóç ôïõ êáíïíéêïý êïôóáíéïý ãéá üëåò ôéò íüôåò åêôüò áðü ôç Óé
				((scan != 8'h21) && (h_count_reg >= (NOTE_X + 6)) && 
				 (h_count_reg <= (NOTE_X + 8)) && 
				 (v_count_reg <= note_y) && 
				 (v_count_reg >= (note_y - STEM_HEIGHT))) ||

				// Ó÷åäßáóç ôçò óçìáßáò ôïõ üãäïïõ ãéá üëåò ôéò íüôåò åêôüò áðü ôç Óé
				((scan != 8'h21) && (h_count_reg >= (NOTE_X + 8)) && 
				 (h_count_reg <= (NOTE_X + 8 + FLAG_WIDTH)) && 
				 (v_count_reg >= (note_y - STEM_HEIGHT)) && 
				 (v_count_reg <= (note_y - STEM_HEIGHT + FLAG_HEIGHT))) ||

				// Ó÷åäßáóç ôïõ áíÜðïäïõ êïôóáíéïý ãéá ôç Óé (B) óôç äåîéÜ ðëåõñÜ
				((scan == 8'h21) && (h_count_reg >= (NOTE_X + 6)) && 
				 (h_count_reg <= (NOTE_X + 8)) && 
				 (v_count_reg >= note_y) && 
				 (v_count_reg <= (note_y + STEM_HEIGHT))) ||

				// Ó÷åäßáóç ôçò óçìáßáò ôïõ üãäïïõ ãéá ôç Óé (B) óôç äåîéÜ ðëåõñÜ
				((scan == 8'h21) && (h_count_reg >= (NOTE_X + 8)) && 
				 (h_count_reg <= (NOTE_X + 8 + FLAG_WIDTH)) && 
				 (v_count_reg <= (note_y + STEM_HEIGHT)) && 
				 (v_count_reg >= (note_y + STEM_HEIGHT - FLAG_HEIGHT))) ||

				// ÐñïóèÞêç ledger line ãéá Íôï (C)
				((scan == 8'h23) && (h_count_reg >= (NOTE_X - LEDGER_LINE_WIDTH)) && 
				 (h_count_reg <= (NOTE_X + LEDGER_LINE_WIDTH)) && 
				 (v_count_reg == Y_C))
				) 
			begin	            // Ó÷åäßáóç íüôáò (ëåõêüò êýêëïò)
	             case (scan)
                8'h23: begin  // Ντο (C) - Κόκκινο
                    red   <= 3'd7;
                    green <= 3'd0;
                    blue  <= 3'd0;
                end
                8'h2D: begin  // Ρε (D) - Πορτοκαλί
                    red   <= 3'd7;
                    green <= 3'd3;
                    blue  <= 3'd0;
                end
                8'h3A: begin  // Μι (E) - Κίτρινο
                    red   <= 3'd7;
                    green <= 3'd7;
                    blue  <= 3'd0;
                end
                8'h2B: begin  // Φα (F) - Πράσινο
                    red   <= 3'd0;
                    green <= 3'd7;
                    blue  <= 3'd0;
                end
                8'h1B: begin  // Σολ (G) - Μπλε
                    red   <= 3'd0;
                    green <= 3'd0;
                    blue  <= 3'd7;
                end
                8'h4B: begin  // Λα (A) - Μωβ
                    red   <= 3'd4;
                    green <= 3'd0;
                    blue  <= 3'd7;
                end
                8'h21: begin  // Σι (B) - Ροζ
                    red   <= 3'd7;
                    green <= 3'd2;
                    blue  <= 3'd5;
                end
                default: begin
                    red   <= 3'd0;
                    green <= 3'd0;
                    blue  <= 3'd0;
                end
				endcase
	        end 
			else if ((v_count_reg == Y_LINE1) || (v_count_reg == Y_LINE2) ||
	                    (v_count_reg == Y_LINE3) || (v_count_reg == Y_LINE4) || (v_count_reg == Y_LINE5)) begin
	            // Ó÷åäßáóç ãñáììþí ðåíôáãñÜììïõ (ëåõêÝò ïñéæüíôéåò ãñáììÝò)
	            red   <= 3'd7;
	            green <= 3'd7;
	            blue  <= 3'd7;
	        end 
			else begin
	            // Ìáýñï õðüâáèñï
	            red   <= 3'd0;
	            green <= 3'd0;
	            blue  <= 3'd0;
	        end
	    end 
		else begin
	        // Ìáýñï ÷ñþìá åêôüò ïñáôÞò ðåñéï÷Þò
	        red   <= 3'd0;
	        green <= 3'd0;
	        blue  <= 3'd0;
	    end
	end
	
	
    // Outputs
    assign hsync  = h_sync_reg;
    assign vsync  = v_sync_reg;
    assign x      = h_count_reg;
    assign y      = v_count_reg;
    assign p_tick = w_25MHz;
	//assign red = (video_on) ? {x[7], x[6], x[5]} : 3'b000;
	//assign green = (video_on) ? {y[7], y[6], y[5]} : 3'b000;
	//assign blue = (video_on) ? {x[4], y[4], x[3]} : 3'b000;
            
endmodule