module pwm_notes (
    input wire clk,              // Ρολόι 25MHz
    input wire reset,            // Σήμα reset
    input wire [3:0] current_note,  // Επιλεγμένη νότα: 0=C, 1=D, 2=E, 3=F, 4=G, 5=A, 6=B
    output reg pwm_out           // Έξοδος PWM για τον buzzer
);

    // Ορισμός της συχνότητας του ρολογιού
    parameter CLOCK_FREQ = 25000000; // 25MHz

    // Ορισμός περιόδου για κάθε νότα.
    // Χρησιμοποιούμε τον τύπο: period = CLOCK_FREQ / (2 * frequency)
    // για να δημιουργήσουμε ένα 50% duty cycle (η έξοδος αναστρέφεται κάθε "half period").
    reg [31:0] period;
    always @(*) begin
        case (current_note)
            4'd0: period = CLOCK_FREQ / (2 * 262);  // C4 (Ντο) περίπου 262 Hz
            4'd1: period = CLOCK_FREQ / (2 * 294);  // D4 (Ρε) περίπου 294 Hz
            4'd2: period = CLOCK_FREQ / (2 * 330);  // E4 (Μι) περίπου 330 Hz
            4'd3: period = CLOCK_FREQ / (2 * 349);  // F4 (Φα) περίπου 349 Hz
            4'd4: period = CLOCK_FREQ / (2 * 392);  // G4 (Σολ) περίπου 392 Hz
            4'd5: period = CLOCK_FREQ / (2 * 440);  // A4 (Λα) 440 Hz
            4'd6: period = CLOCK_FREQ / (2 * 494);  // B4 (Σι) περίπου 494 Hz
            default: period = CLOCK_FREQ / (2 * 262); // Προεπιλογή: C4
        endcase
    end

    // Μετρητής για τη δημιουργία του PWM σήματος
    reg [31:0] counter;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            pwm_out <= 0;
        end else begin
            if (counter >= period) begin
                counter <= 0;
                pwm_out <= ~pwm_out;  // Αναστροφή του PWM για 50% duty cycle
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
