module i2s_mic
#(
	parameter size		= 32
)
(
    input wire standard_clk, // 2MHz (standard mode)
	input wire ultrasonic_clk, // 4MHz (ultrasonic mode)
		input wire [6:0] btn,
		input wire data_in,  // data from microphone
		output wire mic_clk_out,
		output wire data_ready,
    output reg [size-1:0] data_out // data stored into buffer
    );

wire audio_clk;

// currently used instead of switch case statement
// if button is hold ultrasonic clock will be send to microphone
assign audio_clk = btn[3] ? ultrasonic_clk:standard_clk;

// return curently used clock - so we can send it to microphone
assign mic_clk_out = ~audio_clk;

wire neg_clk;
assign neg_clk = audio_clk;
reg [size-1:0] data;
reg [size-1:0] smplcnt = 0;

assign data_ready = &smplcnt;
// switch case for different modes of microphone
// for now we can just use slower clock and standard mode (2MHz)

always @ (posedge audio_clk)
	begin
		// collect data when CLK is high
		data <= {data[size-2:0], data_in};
		smplcnt <= smplcnt + 1;
  end

always @ (posedge neg_clk)
	begin
		// if we got all samples data send data
		//if(smplcnt[size-1])
		//	begin
				data_out <= data;
	 //		end
	end
endmodule
