module i2s_mic
#(
	parameter size		= 32
)
(
    input wire clk, // 2MHz (standard mode)
	input wire data_in,  // data from microphone
	output wire mic_clk_out,
	output wire data_ready,
    output reg [size-1:0] data_out // data stored into buffer
    );

// return curently used clock - so we can send it to microphone
assign mic_clk_out = clk;

reg [size-1:0] data;
reg [size/8:0] smplcnt = 0;

assign data_ready = &smplcnt;
// switch case for different modes of microphone
// for now we can just use slower clock and standard mode (2MHz)

always @ (posedge clk)
	begin
		// collect data when CLK is high
		data <= {data[size-2:0], data_in};
		smplcnt <= smplcnt + 1;
	//	if(data_ready)
			data_out <= data;
  end

endmodule