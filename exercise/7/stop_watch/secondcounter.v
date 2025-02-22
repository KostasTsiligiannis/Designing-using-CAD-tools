module singleseconds (reset, clk, enable, ss, nxt);
input reset, clk, enable;
output [3:0] ss;
output nxt;
reg [3:0] ss;
assign nxt= (ss == 4'd9);
always @(posedge clk or posedge reset)
if (reset) ss <= 4'd0;
else if (enable)
if (nxt) ss <= 0;
else ss <= ss + 1;
endmodule
module tenthsofseconds (reset, clk, enable, ts);
input reset, clk, enable;
output [2:0] ts;
wire again;
reg [2:0] ts;
assign again = (ts == 3'd5);
always @(posedge clk or posedge reset)
if (reset) ts <= 4'd0;
else if (enable)
if (again) ts <= 0;
else ts <= ts + 1;
endmodule
module secondcounter (reset, clk, enable, ts, ss);
input reset, clk, enable;
output [2:0] ts;
output [3:0] ss;
wire ent;
singleseconds i0 (reset, clk, enable, ss, ent);
tenthsofseconds i1 (reset, clk, enable & ent, ts);
endmodule