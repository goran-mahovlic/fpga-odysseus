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

reg [31:0] audio_data_out;
reg [3:0] audio_data_buff_out;
reg [31:0] cnt = 0;

// If button 3 is pressed get data from buffer else just stream data from mic to headphones
assign audio_l = btn[1] ? audio_data_buff_out:audio_data_out[3:0];
assign audio_r = btn[1] ? audio_data_buff_out:audio_data_out[3:0];

wire [31:0] raddr;
assign raddr = cnt;
wire [31:0] waddr;
assign waddr = cnt;

databuff
#(
  // sample size for buffer -- 4bit is what we can send to headphones to it is OK
  .size(4)
)
databuff_inst(
  .clk(clk2MHz),             // needs to be double of data is ready
  .raddr(raddr),                // read samplecount
  .waddr(waddr),                // write samplecount
  .we(btn[2]),           
  .datain(audio_data_out[3:0]),
  .dataout(audio_data_buff_out)
);

i2s_mic
#(
  // How many samples we will collect before data ready
  .size(32)
)
i2s_mic_inst(
  .clk(clk2MHz),
  .mic_clk_out(mic_clk),  //returns clock 2MHz that is needed for microphone
  .data_in(mic_data),
  .data_ready(data_is_ready),
  .data_out(audio_data_out)
  );

assign led[7:0] = cnt[18:11];

always @ (posedge clk2MHz)
  begin
    if(data_is_ready) // if sample is ready
    begin
        cnt <= cnt + 1;
    end
  end

endmodule
