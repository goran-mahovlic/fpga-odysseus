module top (
    input clk_25mhz,
    output [7:0] led,
    input [6:0] btn,
    input mic_data,
	  output ftdi_rxd,
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

wire data_is_ready; // samples are ready

reg [7:0] audio_data_out;
reg [3:0] audio_data_buff_out;
reg [31:0] cnt = 0;

// If button 3 is pressed get data from buffer else just stream data from mic to headphones
assign audio_l = btn[1] ? audio_data_buff_out:audio_data_out;
assign audio_r = btn[1] ? audio_data_buff_out:audio_data_out;

// If button 3 is pressed send 4MHz to microphone look in i2s_rx.v

// read one sample before current
reg [31:0] samplecount;
wire buffer_clk;

wire [31:0] raddr;
assign raddr = samplecount;
wire [31:0] waddr;
assign waddr = samplecount;
assign buffer_clk = cnt[2];

databuff
#(
  // sample size for buffer -- 4bit is what we can send to headphones to it is OK
  .size(4)
)
databuff_inst(
  .clk(buffer_clk),             // needs to be double of data is ready
  .raddr(raddr),                // read samplecount
  .waddr(waddr),                // write samplecount
  .we(data_is_ready),           //write only if data is ready
  .datain(audio_data_out[7:4]),
  .dataout(audio_data_buff_out)
);

i2s_mic
#(
  // How many samples we will collect before data ready
  .size(8)
)
i2s_mic_inst(
  .standard_clk(clk2MHz),
  .ultrasonic_clk(clk4MHz),
  .mic_clk_out(mic_clk),  //returns inverted clock that is used (standard/ultrasonic)
  .btn(btn),
  .data_in(mic_data),
  .data_ready(data_is_ready),
  .data_out(audio_data_out)
  );

assign led[7] = cnt[2];

always @ (posedge mic_clk)
  begin
    cnt <= cnt + 1;
    if(data_is_ready) // when mic_clk counter is 4 and data_is_ready sample next sample is ready
    begin
      if (cnt[2])
      begin
        samplecount <= samplecount + 1;
      end
    end
  end

endmodule
