module sound_ctrl (
    input clk,         // 100 MHz Clock
    input [7:0] scan,  // Επιλογή νότας 
    output reg pwm_out,		//έξοδος ήχου
	output [19:0] half_period,
	output mute
);

    reg [19:0] counter = 0;
    
	
	assign mute = (scan == 8'h05) ? 1 : 0;
	
	assign half_period = (scan == 8'h23 && !mute) ? 382233 / 2 :	//Ντο
						 (scan == 8'h2D && !mute) ? 340529 / 2 :	//Ρε
						 (scan == 8'h3A && !mute) ? 303379 / 2 :	//Μι
						 (scan == 8'h2B && !mute) ? 286345 / 2 :	//Φα
						 (scan == 8'h1B && !mute) ? 255102 / 2 :	//Σολ
						 (scan == 8'h4B && !mute) ? 227273 / 2 :	//Λα
						 (scan == 8'h21 && !mute) ? 202478 / 2 :	/*Σι*/ 10'd0;

	
    always @(posedge clk) begin
        if (counter < half_period)
            counter <= counter + 1;
        else begin
            counter <= 0;
            pwm_out <= ~pwm_out;
        end
    end

endmodule
