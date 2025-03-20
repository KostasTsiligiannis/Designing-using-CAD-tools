module sound_ctrl (
    input clk,         // 100 MHz Clock
    input reset,
	input [7:0] scan,  // Επιλογή νότας 
    input [7:0] prevscan,
	output reg pwm_out,		//έξοδος ήχου
	output [19:0] half_period
);

    reg [19:0] counter = 0;
	reg mute;
	reg count; 
	reg [7:0] prev_char;
	//assign mute = (prev_scan == 8'h05) ? 1 : 0;
	
	assign half_period = (scan == 8'h23 && prevscan != 8'h12) ? 382233 / 2 :	//Ντο
						 (scan == 8'h2D && prevscan != 8'h12) ? 340529 / 2 :	//Ρε
						 (scan == 8'h3A && prevscan != 8'h12) ? 303379 / 2 :	//Μι
						 (scan == 8'h2B && prevscan != 8'h12) ? 286345 / 2 :	//Φα
						 (scan == 8'h1B && prevscan != 8'h12) ? 255102 / 2 :	//Σολ
						 (scan == 8'h4B && prevscan != 8'h12) ? 227273 / 2 :	//Λα
						 (scan == 8'h21 && prevscan != 8'h12) ? 202478 / 2 :	/*Σι*/ 
						 (scan == 8'h23 && prevscan == 8'h12) ? 191113 / 2 :	//nto5
						 (scan == 8'h2D && prevscan == 8'h12) ? 170265 / 2 :	//re5
						 (scan == 8'h3A && prevscan == 8'h12) ? 151690 / 2 :	//mi5
						 (scan == 8'h2B && prevscan == 8'h12) ? 143172 / 2 :	//fa5
						 (scan == 8'h1B && prevscan == 8'h12) ? 127551 / 2 :	//sol5
						 (scan == 8'h4B && prevscan == 8'h12) ? 113636 / 2 :	//la5
						 (scan == 8'h21 && prevscan == 8'h12) ? 101238 / 2 : 10'd0;

	always @(posedge clk) begin
        // Ανίχνευση πατήματος του πλήκτρου f1 (rising edge)
		if (reset) begin
			count <= 0;
			prev_char <= 8'b0;
			mute <= 1'b0;
		end	
        else if (scan == 8'h0D && prev_char == 0) begin
            count <= count + 1;
        end
		else begin
			count <= count;
		end	
        prev_char <= (scan == 8'h0D); // Ενημέρωση προηγούμενης κατάστασης
		mute <= count;
	end
	
    always @(posedge clk) begin
		if (!mute && half_period != 0) begin // Αν το mute είναι 0 και έχει επιλεγεί νότα
			if ((counter < half_period)) 
				counter <= counter + 1;
			else begin
				counter <= 0;
				pwm_out <= ~pwm_out;
			end
		end
		else begin
			pwm_out <= 0; // Αν το mute είναι 1 ή δεν έχει επιλεγεί νότα, σταματάει το σήμα
		end	
    end
	
	

endmodule
