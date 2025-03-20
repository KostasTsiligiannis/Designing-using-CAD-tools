module vga_controller(
    input clk_100MHz,   // from Basys 3
    input reset,        // system reset
    input [7:0] scan,
	input [7:0] prevscan,
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
	parameter Y_C5 = 230;
	parameter Y_D5 = 220;
	parameter Y_E5 = 210;
	parameter Y_F5 = 200;
	parameter Y_G5 = 190;
	parameter Y_A5 = 180;
	parameter Y_B5 = 170;

	// *** ÓõíôåôáãìÝíåò êõêëéêïý óõìâüëïõ (íüôáò) ***
	parameter NOTE_X = 320; // Óôáèåñü X óôï êÝíôñï ôçò ïèüíçò
	parameter NOTE_RADIUS = 10; // Áêôßíá êýêëïõ
	parameter STEM_HEIGHT = 25; // ¾øïò ôïõ êïôóáíéïý
	parameter FLAG_WIDTH = 10; // ÐëÜôïò ôçò óçìáßáò ôïõ üãäïïõ
	parameter FLAG_HEIGHT = 5; // ¾øïò ôçò óçìáßáò ôïõ üãäïïõ
	parameter LEDGER_LINE_WIDTH = 20;
	// Õðïëïãéóìüò èÝóçò íüôáò
	wire [9:0] note_y;
	assign note_y = (scan == 8'h23 && prevscan != 8'h12) ? Y_C :	//Nto
	                (scan == 8'h2D && prevscan != 8'h12) ? Y_D :	//re
	                (scan == 8'h3A && prevscan != 8'h12) ? Y_E :	//mi
	                (scan == 8'h2B && prevscan != 8'h12) ? Y_F :	//fa
	                (scan == 8'h1B && prevscan != 8'h12) ? Y_G :	//sol
	                (scan == 8'h4B && prevscan != 8'h12) ? Y_A :	//la
	                (scan == 8'h21 && prevscan != 8'h12) ? Y_B :	//ci 
					(scan == 8'h23 && prevscan == 8'h12) ? Y_C5 :	//nto5
	                (scan == 8'h2D && prevscan == 8'h12) ? Y_D5 :	//re5
	                (scan == 8'h3A && prevscan == 8'h12) ? Y_E5 :	//mi5
	                (scan == 8'h2B && prevscan == 8'h12) ? Y_F5 :	//fa5
	                (scan == 8'h1B && prevscan == 8'h12) ? Y_G5 :	//sol5
	                (scan == 8'h4B && prevscan == 8'h12) ? Y_A5 :	//la5
	                (scan == 8'h21 && prevscan == 8'h12) ? Y_B5 :
					((scan == 8'h76 || scan == 8'h12) || scan == 8'h0D) ? 10'd630 : 10'd650; 
					

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
			else if (video_on && (note_y != 10'd650)) begin
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
				((scan == 8'h23 && prevscan != 8'h12) && (h_count_reg >= (NOTE_X - LEDGER_LINE_WIDTH)) && 
				 (h_count_reg <= (NOTE_X + LEDGER_LINE_WIDTH)) && 
				 (v_count_reg == Y_C)) ||
				 //ledger line for A5
				 (((scan == 8'h4B && prevscan == 8'h12) ||(scan == 8'h21 && prevscan == 8'h12)) && (h_count_reg >= (NOTE_X - LEDGER_LINE_WIDTH)) && 
				 (h_count_reg <= (NOTE_X + LEDGER_LINE_WIDTH)) && 
				 (v_count_reg == Y_A5))
				 //|| (scan == 8'h0D)
				) 
				begin	            // Ó÷åäßáóç íüôáò (ëåõêüò êýêëïò)
		            case (note_y)
	                Y_C: begin  // Ντο (C) - Κόκκινο
	                    red   <= 3'd7;
	                    green <= 3'd0;
	                    blue  <= 3'd0;
	                end
	                Y_D: begin  // Ρε (D) - Πορτοκαλί
	                    red   <= 3'd7;
	                    green <= 3'd3;
	                    blue  <= 3'd0;
	                end
	                Y_E: begin  // Μι (E) - Κίτρινο
	                    red   <= 3'd7;
	                    green <= 3'd7;
	                    blue  <= 3'd0;
	                end
	                Y_F: begin  // Φα (F) - Πράσινο
	                    red   <= 3'd0;
	                    green <= 3'd7;
	                    blue  <= 3'd0;
	                end
	                Y_G: begin  // Σολ (G) - Μπλε
	                    red   <= 3'd0;
	                    green <= 3'd0;
	                    blue  <= 3'd7;
	                end
	                Y_A: begin  // Λα (A) - Μωβ
	                    red   <= 3'd4;
	                    green <= 3'd0;
	                    blue  <= 3'd7;
	                end
	                Y_B: begin  // Σι (B) - Ροζ
	                    red   <= 3'd7;
	                    green <= 3'd2;
	                    blue  <= 3'd5;
	                end
					Y_C5: begin  // Ντο5 (C) 
	                    red   <= 3'd4;
	                    green <= 3'd1;
	                    blue  <= 3'd3;
	                end
	                Y_D5: begin  // Ρε5 (D)
	                    red   <= 3'd3;
	                    green <= 3'd6;
	                    blue  <= 3'd4;
	                end
	                Y_E5: begin  // Μι5 (E)
	                    red   <= 3'd2;
	                    green <= 3'd7;
	                    blue  <= 3'd6;
	                end
	                Y_F5: begin  // Φα5 (F)
	                    red   <= 3'd1;
	                    green <= 3'd3;
	                    blue  <= 3'd2;
	                end
	                Y_G5: begin  // Σολ5 (G)
	                    red   <= 3'd3;
	                    green <= 3'd5;
	                    blue  <= 3'd2;
	                end
	                Y_A5: begin  // Λα5 (A)
	                    red   <= 3'd4;
	                    green <= 3'd3;
	                    blue  <= 3'd3;
	                end
	                Y_B5: begin  // Σι5 (B)
	                    red   <= 3'd2;
	                    green <= 3'd1;
	                    blue  <= 3'd4;
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

            
endmodule