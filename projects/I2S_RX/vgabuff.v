module databuff
  #(
  	parameter size		= 32
  )
  (
  input clk,
  input [31:0] raddr,
  input [31:0] waddr,
  input we,
  input [size-1:0] datain,
  output reg  [size-1:0] dataout
);

  reg [size-1:0] mem [0:(size*4096)];

  always @(posedge clk) begin
    if (we) begin
      mem[waddr] <= datain;
    end
    dataout <= mem[raddr];
  end

endmodule
