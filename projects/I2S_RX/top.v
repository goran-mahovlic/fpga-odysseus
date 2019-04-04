module top (
    input clk_25mhz,
    output [7:0] led,
    input [6:0] btn,
    input mic_data,
    output mic_clk,
    output mic_select,
    output reg [3:0] audio_l,
    output reg [3:0] audio_r,
    output wifi_gpio0
);
    assign wifi_gpio0 = 1'b1;
    assign mic_select = 1'b1;

wire clk2MHz;  // Standard clock for microphone
wire clk4MHz;  // Ultrasonic clock for microphone

pll
pll_inst
(
  .clki(clk_25mhz),
  .clks1(clk4MHz),
  .clko(clk2MHz)
);

wire data_is_ready; //not used

reg [3:0] audio_data_out;

assign audio_r = audio_data_out;
assign audio_l = audio_data_out;

i2s_mic
#(
  .size(4)
)
i2s_mic_inst(
  .standard_clk(clk2MHz),
  .ultrasonic_clk(clk4MHz),
  .mic_clk_out(mic_clk),
  .btn(btn),
  .data_in(mic_data),
  .data_ready(data_is_ready),
  .data_out(audio_data_out)
  );

endmodule
