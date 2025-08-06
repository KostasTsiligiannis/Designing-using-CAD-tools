module counter (clear, clock, load, start_stop, count, data);
  input [3:0] data;
  output [3:0] count;
  input start_stop;
  input load;
  input clock;
  input clear;
  reg [3:0] count;
  
  always @(posedge clock or posedge clear)
   if (clear) count <= 0;
    else if (load) count <= data;
              else if (start_stop) count <= count + 1;
endmodule 