module tops (reset, pause, clk, left, right, y);
input reset, clk, pause;
output [6:0] left, right;
output [9:0] y;
wire [2:0] ts;
wire [3:0] ss;
wire [3:0] onets;
OneHertz i0 (reset, clk, en_nxt);
TenHertz i1 (reset, clk, en_10nxt);
secondcounter i2  (reset, clk, en_nxt, ts, ss);
div10second i3  (reset, clk, en_10nxt, onets);
bin_2_7 lt ({1'b0,ts}, pause, clk, left);
bin_2_7 rt (ss, pause, clk, right);
bin_2_10 i4(onets, pause, clk, y);
endmodule
