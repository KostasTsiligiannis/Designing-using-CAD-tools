module cnt25 (reset, clk, enable, clkdiv25);
     input reset, clk, enable;
     output clkdiv25;
     reg [5:0] cnt;

     assign clkdiv25 = (cnt==5'd24);
     always @(posedge reset or posedge clk)
          if (reset) cnt <= 0;
          else if (enable)
               if (clkdiv25) cnt <= 0;
               else cnt <= cnt + 1;

endmodule

module cnt2b (reset, clk, enable, clkdiv4);
input reset, clk, enable;
output clkdiv4;
reg [1:0] cnt;
assign clkdiv2 = (cnt==2'd3);
always @(posedge reset or posedge clk)
if (reset) cnt <= 0;
else if (enable) cnt <= cnt + 1;
endmodule 

module TwentyFiveMHertz(reset, clk, en_nxt);
input clk, reset;
output en_nxt;
wire clk25MHz;
cnt2b i0 (reset, clk, 1'b1, clk25MHz);
assign en_nxt = clk25MHz;
endmodule
