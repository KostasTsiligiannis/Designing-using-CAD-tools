module testcounter ();
reg [7:0] d;
wire [7:0] c;
reg s_s, l, clk, clr;
wire [1:0] cr;

counter8_bit_2_4bit inst0 (clr, clk, l, s_s, d, cr, c);


always # 10 clk <= !clk;
initial begin
    // Initialize all signals
    clk = 0; 
    clr = 0; 
    l = 0;
    s_s = 0;
    d = 8'h0E;
  // Reset sequence
    #10 clr = 1;  // Apply reset
    #20 clr = 0;  // Release reset

    // Start counting up
    #15 l = 1;
    #15 l = 0;
    #50 s_s = 1;
    

    // Hold counting for a while
    #500 s_s = 0;

    // Load a new value into the counter
    #700 l = 1; 
    d = 8'hE0;  // New load value
    #50 l = 0;  // Load complete

    // Switch counting direction
    #100 s_s = 1;
    #1500 s_s = 0;

    // Another load operation
    #2000 l = 1;
    d = 8'hFE;
    #60 l = 0;
    #100 s_s = 1;

    // Final test phase
    #3000 $finish;
  end
endmodule

