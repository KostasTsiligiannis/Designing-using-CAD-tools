module kbd_protocol (reset, clk, ps2clk, ps2data, scancode, prevscancode, mdscancode);
  input        reset, clk, ps2clk, ps2data;
  output [7:0] scancode, prevscancode, mdscancode;
  reg    [7:0] scancode, prevscancode, mdscancode;
  
  // Synchronize ps2clk to local clock and check for falling edge;
  reg    [7:0] ps2clksamples; // Stores last 8 ps2clk samples

  always @(posedge clk or posedge reset)
    if (reset) ps2clksamples <= 8'd0;
      else ps2clksamples <= {ps2clksamples[7:0], ps2clk};

  wire fall_edge; // indicates a falling_edge at ps2clk
  assign fall_edge = (ps2clksamples[7:4] == 4'hF) & (ps2clksamples[3:0] == 4'h0);

  reg    [9:0] shift;   // Stores a serial package, excluding the stop bit;
  reg    [3:0] cnt;     // Used to count the ps2data samples stored so far
  reg          f0;      // Used to indicate that f0 was encountered earlier
  
  // A simple FSM is implemented here. Grab a whole package,
  // check its parity validity and output it in the scancode
  // only if the previous read value of the package was F0
  // that is, we only trace when a button is released, NOT when it is
  // pressed.
  
  always @(posedge clk or posedge reset)
    if (reset) 
      begin
        cnt    <= 4'd0;
        scancode <= 8'd0;
		prevscancode <= 8'd0;
		mdscancode <= 8'd0;
        shift    <= 10'd0;
        f0       <= 1'b0;
      end  
     else if (fall_edge)
         begin
           if (cnt == 4'd10) // we just received what should be the stop bit
             begin
               cnt <= 0;
               if ((shift[0] == 0) && (ps2data == 1) && (^shift[9:1]==1)) // A well received serial packet
                 begin
                   if (f0) // following a scancode of f0. So a key is released ! 
                     begin
					   prevscancode <= mdscancode;
					   mdscancode <= scancode;
                       scancode <= shift[8:1];
                       f0 <= 0;
                     end
                    else if (shift[8:1] == 8'hF0) f0 <= 1'b1;
                 end // All other packets have to do with key presses and are ignored
             end
            else
             begin
               shift <= {ps2data, shift[9:1]}; // Shift right since LSB first is transmitted
               cnt <= cnt+1;
             end
         end
endmodule



module scan_2_7seg (scan, ss);
  input  [7:0] scan;
  output [7:0] ss;

  
  assign ss = (scan == 8'h45) ? 8'b01111110 :
              (scan == 8'h16) ? 8'b00110000 :
              (scan == 8'h1E) ? 8'b01101101 :
              (scan == 8'h26) ? 8'b01111001 :
              (scan == 8'h25) ? 8'b00110011 :
              (scan == 8'h2E) ? 8'b01011011 :
              (scan == 8'h36) ? 8'b01011111 :
              (scan == 8'h3D) ? 8'b01110010 :
              (scan == 8'h3E) ? 8'b01111111 :
              (scan == 8'h46) ? 8'b01111011 : 8'b10000000 ;
endmodule 

module result_2_7seg (result, ss);
  input  [6:0] result;
  wire [6:0] res;
  output [6:0] ss;
  
  assign res = (result >= 7'd10 && result<7'd20) ? result - 7'd10 :
				(result >= 7'd20 && result<7'd30) ? result - 7'd20 :
				(result >= 7'd30 && result<7'd40) ? result - 7'd30 :
				(result >= 7'd40 && result<7'd50) ? result - 7'd40 :
				(result >= 7'd50 && result<7'd60) ? result - 7'd50 :
				(result >= 7'd60 && result<7'd70) ? result - 7'd60 :
				(result >= 7'd70 && result<7'd80) ? result - 7'd70 :
				(result >= 7'd80 && result<7'd90) ? result - 7'd80 : result ;
  
  assign ss = (res == 7'd0 ) ? 7'b1110111 : 
			(res == 7'd1 ) ? 7'b0010010 :
			(res == 7'd2 ) ? 7'b1011101 :
			(res == 7'd3 ) ? 7'b1011011 :
			(res == 7'd4 ) ? 7'b0111010 : 
			(res == 7'd5 ) ? 7'b1101011 :
			(res == 7'd6 ) ? 7'b1101111 : 
			(res == 7'd7 ) ? 7'b1011010 :
			(res == 7'd8 ) ? 7'b1111111 : 
			(res == 7'd9 ) ? 7'b1111010 : 7'b1000000;
endmodule

module calculator (scan, prevscan, mdscan, result);
	input [7:0] scan, prevscan, mdscan;
	wire [3:0] first, second, quotient, remainder ;
	//reg [3:0] temp_div, shifted_div, q, quotient, remainder;
	//reg [3:0] quotient, remainder;
	//integer i;
	output [6:0] result;
	
	assign first = (prevscan == 8'h45) ? 4'd0:
              (prevscan == 8'h16) ? 4'd1 :
              (prevscan == 8'h1E) ? 4'd2 :
              (prevscan == 8'h26) ? 4'd3 :
              (prevscan == 8'h25) ? 4'd4 :
              (prevscan == 8'h2E) ? 4'd5 :
              (prevscan == 8'h36) ? 4'd6 :
              (prevscan == 8'h3D) ? 4'd7 :
              (prevscan == 8'h3E) ? 4'd8 :
              (prevscan == 8'h46) ? 4'd9 : 4'd0 ;
	
	assign second = (scan == 8'h45) ? 4'd0:
              (scan == 8'h16) ? 4'd1 :
              (scan == 8'h1E) ? 4'd2 :
              (scan == 8'h26) ? 4'd3 :
              (scan == 8'h25) ? 4'd4 :
              (scan == 8'h2E) ? 4'd5 :
              (scan == 8'h36) ? 4'd6 :
              (scan == 8'h3D) ? 4'd7 :
              (scan == 8'h3E) ? 4'd8 :
              (scan == 8'h46) ? 4'd9 : 4'd0 ;
	
	/*always@(first or second or temp_div or shifted_div) begin
		if (second == 4'd0) begin
			quotient <= 0;
			//remainder <= first; 
		end
		else begin
			temp_div <= first;
			q <= 0;
			for(i=3; i>=0; i=i-1) begin
				shifted_div <= second << i;
				if (temp_div >= shifted_div) begin
					temp_div <= temp_div - shifted_div;
					q <= q | (1<<i);
				end
				else begin
					temp_div <= temp_div;
					q <= q;
				end	
			end
			quotient <= q;
			//remainder <= temp_div;
		end
	end */
	divider d(first, second, quotient, remainder);
	
	assign result = (mdscan == 8'h79) ? first + second : //2'b00 
				  (mdscan == 8'h7B) ? first - second : //2'b01 :
				  (mdscan == 8'h22) ? first * second : //2'b10 : 2'b11;
				  (mdscan == 8'h4A) ? quotient : 7'd0 ; //2'b11 ;
	
	/*always @(mode or first or second)
	case (mode)
		00: result <= first + second ;
		01: result <= first - second ;
		10: result <= first * second ;
		11: result <= first / second ;
	endcase*/

endmodule

module divider(Q, M, Quo, Rem);
	input [3:0] Q;
	input [3:0] M;
	output[3:0] Quo;
	output [3:0] Rem;
	reg [3:0] Quo = 0;
	reg [3:0] Rem = 0;
	reg [3:0] a1, b1, p1;
	integer i;
	
	always@(Q or M) 
	begin
		a1 = Q;
		b1 = M;
		p1 = 0;
		for(i=0; i<4; i = i+1)
		begin
			p1 = {p1[3:0],a1[3]};
			a1[3:1] = a1[2:0];
			p1 = p1 - b1;
			if(M == 0) a1 = 0;
			else if(p1[3] == 1) 
			begin
				a1[0] = 0;
				p1 = p1 + b1;
			end
			else a1[0] = 1;
		end
		Quo = a1;
		Rem = p1;
	end		
	

endmodule

module eight (reset, clk, ps2clk, ps2data, left, right, s);
  input        reset, clk;
  input        ps2clk, ps2data;
  output [7:0] left, right, s;
  wire   [7:0] scan, prevscan, mdscan;
  wire	[6:0] result;
  
  kbd_protocol kbd (reset, clk, ps2clk, ps2data, scan, prevscan, mdscan);
  calculator calc (scan, prevscan, mdscan, result);
  result_2_7seg sseg (result, s);
  scan_2_7seg  lt (scan, left);
  scan_2_7seg  rt (prevscan, right);
endmodule
