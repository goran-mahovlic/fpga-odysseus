module i2s_mic
#(
    // Not used
    parameter size = 16
)
(
    input wire clk, // 1.66MHz
    input wire data_in,  // data from microphone
    input wire rst,
    input [3:0] led,
    output wire data_ready,
    output reg [7:0] data_out // data stored into buffer
    );


reg [7:0] PCMcounter = 0;
reg [7:0] PCM = 8'h80;
reg [0:0] reset = 1;

always @ (posedge clk)
	begin

      if (reset) begin
        if (data_in)
          PCM <= 8'h81;
        else
          PCM <= 8'h7f;
      	reset = 0;
      end
      else begin
			// If current bit is positive
        if (data_in)
	        PCM <= PCM + 1;
	    else
	        PCM <= PCM - 1;
  	end

      // Count bits in PCM
    PCMcounter <= PCMcounter + 1;
    if(&PCMcounter) begin
        data_ready <= 1'b1;
        data_out <= PCM;
        reset <= 1;
        PCMCounter <= 0;
    end
    // PCM counter is not full
    else
      begin
        data_ready <= 1'b0;
      end
    end

endmodule
