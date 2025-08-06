module tops (reset, pause, clk, left, right);
input reset, clk, pause;
output [6:0] left, right;
wire [2:0] ts;
wire [3:0] ss;
OneHertz i0 (reset, clk, en_nxt);
secondcounter i1 (reset, clk, en_nxt, ts, ss);
bin_2_7 lt ({1'b0,ts}, pause, clk, left);
bin_2_7 rt (ss, pause, clk, right);
endmodule
