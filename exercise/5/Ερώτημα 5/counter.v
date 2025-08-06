module counter (clear, clock, load, start_stop, count, data, carry);
  input [3:0] data;
  output [3:0] count;
  output reg carry;
  input start_stop;
  input load;
  input clock;
  input clear;
  reg [3:0] count;
  
  always @(posedge clock)
   if (clear) begin
	count <= 0;
	carry <= 0;
	end
   else if (load) count <= data;
              else if (start_stop) begin 
				count <= count + 1;
				if(count == 4'hE) carry <= 1;
				else carry <= 0;
				end
endmodule

module counter8_bit_2_4bit(
	clr,
	clk,
	ld,
	s_s,
	d, 
	cr,
	cnt);
	
	input clk, clr, ld, s_s;
	input [7:0] d;
	output [1:0] cr;
	output [7:0] cnt;
	
	counter c1(.clear(clr), .clock(clk), .load(ld), .start_stop(s_s), .data(d[3:0]), .count(cnt[3:0]), .carry(cr[0]));
	counter c2(.clear(clr), .clock(clk), .load(ld), .start_stop(cr[0]), .data(d[7:4]), .count(cnt[7:4]), .carry(cr[1]));
		
endmodule 