module tops(clk_100MHz, reset, ps2clk, ps2data, blue, green, red, hsync, vsync, pwm_out);
	input clk_100MHz, reset, ps2clk, ps2data;
	output [2:0] blue, green, red;
	output hsync, vsync, pwm_out;
	wire [7:0] character, prev_character;
	kbd_controller kbd (reset, clk_100MHz, ps2clk, ps2data, character, prev_character);
	vga_controller vga (clk_100MHz, reset, character, prev_character, hsync, vsync, red, green, blue);
	sound_ctrl snd (clk_100MHz, reset, character, prev_character, pwm_out);
endmodule
