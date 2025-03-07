module mul (a, b, s, dp);
  input  [1:0] a; 
  input  [1:0] b;
  output [6:0] s;
  output dp;
  wire[3:0] o;
  
  assign o[0] = a[0]&b[0];
  assign o[1] = (a[1]&b[0])^(a[0]&b[1]);
  assign o[2] = (a[1]&b[0])&(a[0]&b[1])^(a[1]&b[1]);
  assign o[3] = (a[1]&b[0])&(a[0]&b[1])&(a[1]&b[1]);
  assign s[6:0] = (o==4'b0000)? 7'b1110111: (o==4'b0001 )? 7'b0010010: (o==4'b0010) ? 7'b1011101 : (o==4'b0011)? 7'b0010010: (o==4'b0100) ? 7'b0111010 : (o==4'b0101) ? 7'b1101011 : (o==4'b0110) ? 7'b1011101 : (o==4'b0111) ? 7'b0010010 : (o==4'b1000) ? 7'b1111111 : (o==4'b1001) ? 7'b1111010 : (o==4'b1010) ? 7'b1111110 : (o==4'b1011) ? 7'b0101111 : (o==4'b1100) ? 7'b1100101 : (o==4'b1101) ? 7'b0011111 : (o==4'b1110) ? 7'b1101101 : (o==4'b1111) ? 7'b1101100 : 7'b0000000;
  assign dp = (a==2'b00 | b==2'b00) ? 1'b0 :(a[1]^b[1]) ? 1'b1 : 1'b0;
 
endmodule