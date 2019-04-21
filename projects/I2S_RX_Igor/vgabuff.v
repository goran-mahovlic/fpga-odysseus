module databuff
  #(
  	parameter size		= 8
  )
  (
  input clk,
  input [15:0] raddr,
  input [15:0] waddr,
  input we,
  input [size-1:0] datain,
  output reg  [size-1:0] dataout
);

  reg [7:0] mem [0:(51200)];

  always @(posedge clk) begin
    if (we) begin
      mem[waddr] <= datain;
    end
    dataout <= mem[raddr];
  end

endmodule
