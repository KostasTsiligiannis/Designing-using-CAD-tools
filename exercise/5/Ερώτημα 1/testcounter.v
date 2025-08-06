module testcounter ();
reg [3:0] d;
wire [3:0] c;
reg s_s, l, clk, clr;

counter inst0 (clr, clk, l, s_s, c, d);

initial 
  begin
    # 5 clk <= 0; clr <= 0; l <= 0;  s_s <= 0;  d <= 8'hF0;
  end
always # 40 clk <= !clk;
initial 
   begin
     # 100 clr <= 1;
     #  50 clr <= 0; 
   end
initial
  begin
    #  400 s_s <= 1;
    # 3000 s_s <= 0;
  end
initial
  begin
    # 3500 s_s <= 1;
    # 3700 l <= 1;
    #  200 l <= 0;
  end
endmodule

