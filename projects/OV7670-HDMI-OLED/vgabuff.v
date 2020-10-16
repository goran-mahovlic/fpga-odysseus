module vgabuff(
  input clk,
  input [14:0] raddr,
  input [14:0] hdmiraddr,
  input [14:0] waddr,
  input we,
  input [15:0] pixout,
  output reg  [15:0] pixin,
  output reg  [15:0] hdmipixin
);

  //(16 * 640 * 480) / 96  -- do not know if this is correct
  reg [15:0] mem [0:51200];

  always @(posedge clk) begin
    if (we) begin
      mem[waddr] <= pixout;
    end
    pixin <= mem[raddr];
    hdmipixin <= mem[hdmiraddr];
  end

endmodule
