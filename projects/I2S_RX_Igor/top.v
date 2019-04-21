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


wire mic_clk_standard;  // Standard clock for microphone
wire data_is_ready; // samples are ready

reg [7:0] audio_data_out;
reg [7:0] audio_data_buff_out;
reg [15:0] sample_counter_read;
reg [15:0] raddr = sample_counter_read;
reg [15:0] waddr = sample_counter;
reg [15:0] sample_counter;

assign sample_counter_read = sample_counter - 2000;

databuff
#(
  // sample size for buffer -- 4bit is what we can send to headphones to it is OK
  .size(8)
)
databuff_inst(
  .clk(clk_25mhz),             // needs to be double of data is ready
  .raddr(raddr),                // read samplecount
  .waddr(waddr),                // write samplecount
  .we(send_PCM_buffer),
  .datain(audio_data_out),
  .dataout(audio_data_buff_out)
);

wire send_PCM_serial;
wire send_PCM_buffer;

assign send_PCM_serial = &({btn[1],data_is_ready});
assign send_PCM_buffer = &({btn[2],data_is_ready});

uart_tx uart_transmit(
      .clk(clk_25mhz),
      .resetn(1'b1),
      .ser_tx(ftdi_rxd),
      .cfg_divider(25000000/115200),
      .data(audio_data_out),
      .data_we(send_PCM_serial)
      //.outclk(serclkdiv)
    );

i2s_mic
#(
  // How many samples we will collect before data ready
  // Not used we will use 4
  .size(16)
)
i2s_mic_inst(
  .clk(mic_clk_standard),
  .data_in(mic_data),
  .rst(1'b1),
 // .led(led[3:0]),
  .data_ready(data_is_ready),
  .data_out(audio_data_out)
  );

// analog output to classic headphones
wire [3:0] dac;
reg [7:0] audio = btn[2] ? audio_data_out:audio_data_buff_out;

dacpwm
#(
  // How many samples we will collect before data ready
  // Not used we will use 4
  .C_pcm_bits(8),
  .C_dac_bits(4)
)
dacpwm_instance
(
  .clk(clk_25mhz),
  .pcm(audio),
  .dac(dac)
);

assign audio_l = dac;
assign audio_r = dac;

reg [3:0] mic_clk_counter;

//assign led[7] = mic_clk_counter;
//assign led[6] = mic_clk_standard;
//assign led[5] = data_is_ready;
//assign led[4] = mic_data;
assign led[7:0] = audio_data_out;

always @ (posedge clk_25mhz)
  begin
    mic_clk_counter <= mic_clk_counter + 1;
    if(&mic_clk_counter)
    begin
        mic_clk_standard <= ~mic_clk_standard;
        mic_clk <= mic_clk_standard;
    end
  end


always @(posedge data_is_ready)
  begin
    sample_counter <= sample_counter +1;
  end

endmodule