module tops(clk_100MHz, reset, ps2clk, ps2data, blue, green, red, hsync, vsync);
	input clk_100MHz, reset, ps2clk, ps2data;
	output [2:0] blue, green, red;
	output hsync, vsync;
	wire [7:0] character;
	kbd_controller kbd (reset, clk_100MHz, ps2clk, ps2data, character);
	vga_controller vga (clk_100MHz, reset, character, hsync, vsync, red, green, blue);

endmodule
