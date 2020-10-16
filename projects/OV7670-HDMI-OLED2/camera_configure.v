`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/07/2015 10:20:20 AM
// Design Name:
// Module Name: camera_configure
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module camera_configure
    #(
    parameter CLK_FREQ=100000000
    )
    (
    input wire clk,
    input wire start,
    output wire sioc,
    output wire siod,
    output wire done,
    output wire x_clock
    );

    wire [7:0] rom_addr;
    wire [15:0] rom_dout;
    wire [7:0] SCCB_addr;
    wire [7:0] SCCB_data;
    wire SCCB_start;
    wire SCCB_ready;
    wire SCCB_SIOC_oe;
    wire SCCB_SIOD_oe;

    wire siod_in, siod_out, sioc_in, sioc_out;

    assign x_clock = clk;

  //  assign x_clock = clk_25MHz;

    /*
    reg [1:0] clkpre = 2'b00;

    always @(posedge clk)
    begin
      clkpre <= clkpre + 1;
    end

    assign x_clock = clkpre[1];
*/


TRELLIS_IO #(.DIR("BIDIR")) sioc_out_bidir (.B(sioc), .I(sioc_out), .O(sioc_in), .T(!SCCB_SIOC_oe));
TRELLIS_IO #(.DIR("BIDIR")) siod_out_bidir (.B(siod), .I(siod_out), .O(siod_in), .T(!SCCB_SIOD_oe));

//    SB_IO #(
//	.PIN_TYPE(6'b 1010_01),
//	.PULLUP(1'b 1)
//    ) siod_io (
//	.PACKAGE_PIN(siod),
//	.OUTPUT_ENABLE(SCCB_SIOD_oe),
//	.D_OUT_0(siod_out),
//	.D_IN_0(siod_in)
//    );

//    SB_IO #(
//	.PIN_TYPE(6'b 1010_01),
//	.PULLUP(1'b 1)
//    ) sioc_io (
//	.PACKAGE_PIN(sioc),
//	.OUTPUT_ENABLE(SCCB_SIOC_oe),
//	.D_OUT_0(sioc_out),
//	.D_IN_0(sioc_in)
//    );

    assign sioc_out = !SCCB_SIOC_oe;
    assign siod_out = !SCCB_SIOD_oe;

    OV7670_config_rom rom1(
        .clk(clk),
        .addr(rom_addr),
        .dout(rom_dout)
        );

    OV7670_config #(.CLK_FREQ(CLK_FREQ)) config_1(
        .clk(clk),
        .SCCB_interface_ready(SCCB_ready),
        .rom_data(rom_dout),
        .start(!start),
        .rom_addr(rom_addr),
        .done(done),
        .SCCB_interface_addr(SCCB_addr),
        .SCCB_interface_data(SCCB_data),
        .SCCB_interface_start(SCCB_start)
        );

    SCCB_interface #( .CLK_FREQ(CLK_FREQ)) SCCB1(
        .clk(clk),
        .start(SCCB_start),
        .address(SCCB_addr),
        .data(SCCB_data),
        .ready(SCCB_ready),
        .SIOC_oe(SCCB_SIOC_oe),
        .SIOD_oe(SCCB_SIOD_oe)
        );

endmodule
