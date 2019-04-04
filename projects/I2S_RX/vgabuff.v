module databuff(
  input clk,
  input [127:0] raddr,
  input [127:0] waddr,
  input we,
  input [3:0] datain,
  output reg  [3:0] dataout
);

  reg [3:0] mem [0:200000];

  always @(posedge clk) begin
    if (we) begin
      mem[waddr] <= datain;
    end
    dataout <= mem[raddr];
  end

endmodule
