// File edge_enhance.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2017 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

//--------------------------------------------------------------------------------
// Engineer: Mike Field <hasmter@snap.net.nz> 
// 
// Module Name: edge_enhance - Behavioral
//
// Description: Video edge enhancement 
//
//----------------------------------------------------------------------------------
// The MIT License (MIT)
// 
// Copyright (c) 2015 Michael Alan Field
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//----------------------------------------------------------------------------------
//--- Want to say thanks? ----------------------------------------------------------
//----------------------------------------------------------------------------------
//
// This design has taken many hours - with the industry metric of 30 lines
// per day, it is equivalent to about 6 months of work. I'm more than happy
// to share it if you can make use of it. It is released under the MIT license,
// so you are not under any onus to say thanks, but....
// 
// If you what to say thanks for this design how about trying PayPal?
//  Educational use - Enough for a beer
//  Hobbyist use    - Enough for a pizza
//  Research use    - Enough to take the family out to dinner
//  Commercial use  - A weeks pay for an engineer (I wish!)
//
//--------------------------------------------------------------------------------
// no timescale needed

module edge_enhance(
input wire Edge_clk,
input wire enable_feature,
input wire in_blank,
input wire in_hsync,
input wire in_vsync,
input wire [7:0] in_red,
input wire [7:0] in_green,
input wire [7:0] in_blue,
output reg out_blank,
output reg out_hsync,
output reg out_vsync,
output reg [7:0] out_red,
output reg [7:0] out_green,
output reg [7:0] out_blue
);

//-----------------------------
// VGA data recovered from HDMI
//-----------------------------
//---------------------------------
// VGA data to be converted to HDMI
//---------------------------------





reg blanks[0:8];
reg hsyncs[0:8];
reg vsyncs[0:8];
reg [7:0] reds[0:8];
reg [7:0] greens[0:8];
reg [7:0] blues[0:8];
reg bypass_1_blank = 1'b0;
reg bypass_1_hsync = 1'b0;
reg bypass_1_vsync = 1'b0;
reg [7:0] bypass_1_red = 1'b0;
reg [7:0] bypass_1_blue = 1'b0;
reg [7:0] bypass_1_green = 1'b0;
reg bypass_2_blank = 1'b0;
reg bypass_2_hsync = 1'b0;
reg bypass_2_vsync = 1'b0;
reg [7:0] bypass_2_red = 1'b0;
reg [7:0] bypass_2_blue = 1'b0;
reg [7:0] bypass_2_green = 1'b0;
reg bypass_3_blank = 1'b0;
reg bypass_3_hsync = 1'b0;
reg bypass_3_vsync = 1'b0;
reg [7:0] bypass_3_red = 1'b0;
reg [7:0] bypass_3_blue = 1'b0;
reg [7:0] bypass_3_green = 1'b0;
reg sobel_3_hsync = 1'b0;
reg sobel_3_blank = 1'b0;
reg sobel_3_vsync = 1'b0;
reg [12:0] sobel_3_red = 1'b0;
reg [12:0] sobel_3_green = 1'b0;
reg [12:0] sobel_3_blue = 1'b0;
reg sobel_2_hsync = 1'b0;
reg sobel_2_blank = 1'b0;
reg sobel_2_vsync = 1'b0;
reg [11:0] sobel_2_red_x = 1'b0;
reg [11:0] sobel_2_red_y = 1'b0;
reg [11:0] sobel_2_green_x = 1'b0;
reg [11:0] sobel_2_green_y = 1'b0;
reg [11:0] sobel_2_blue_x = 1'b0;
reg [11:0] sobel_2_blue_y = 1'b0;
reg sobel_1_hsync = 1'b0;
reg sobel_1_blank = 1'b0;
reg sobel_1_vsync = 1'b0;
reg [11:0] sobel_1_red_left = 1'b0;
reg [11:0] sobel_1_red_right = 1'b0;
reg [11:0] sobel_1_red_top = 1'b0;
reg [11:0] sobel_1_red_bottom = 1'b0;
reg [11:0] sobel_1_green_left = 1'b0;
reg [11:0] sobel_1_green_right = 1'b0;
reg [11:0] sobel_1_green_top = 1'b0;
reg [11:0] sobel_1_green_bottom = 1'b0;
reg [11:0] sobel_1_blue_left = 1'b0;
reg [11:0] sobel_1_blue_right = 1'b0;
reg [11:0] sobel_1_blue_top = 1'b0;
reg [11:0] sobel_1_blue_bottom = 1'b0;

  assign blanks[0] = in_blank;
  assign hsyncs[0] = in_hsync;
  assign vsyncs[0] = in_vsync;
  assign reds[0] = in_red;
  assign greens[0] = in_green;
  assign blues[0] = in_blue;
  line_delay i_line_delay_1(
      .Edge_clk(Edge_clk),
    .in_blank(blanks[0]),
    .in_hsync(hsyncs[0]),
    .in_vsync(vsyncs[0]),
    .in_red(reds[0]),
    .in_green(greens[0]),
    .in_blue(blues[0]),
    .out_blank(blanks[3]),
    .out_hsync(hsyncs[3]),
    .out_vsync(vsyncs[3]),
    .out_red(reds[3]),
    .out_green(greens[3]),
    .out_blue(blues[3]));

  line_delay i_line_delay_2(
      .Edge_clk(Edge_clk),
    .in_blank(blanks[3]),
    .in_hsync(hsyncs[3]),
    .in_vsync(vsyncs[3]),
    .in_red(reds[3]),
    .in_green(greens[3]),
    .in_blue(blues[3]),
    .out_blank(blanks[6]),
    .out_hsync(hsyncs[6]),
    .out_vsync(vsyncs[6]),
    .out_red(reds[6]),
    .out_green(greens[6]),
    .out_blue(blues[6]));

  always @(posedge Edge_clk) begin
    if(enable_feature == 1'b1) begin
      out_hsync <= sobel_3_hsync;
      out_blank <= sobel_3_blank;
      out_vsync <= sobel_3_vsync;
      if(sobel_3_red[12:12] == 1'b0) begin
        out_red <= sobel_3_red[11:4];
      end
      else begin
        out_red <= {8{1'b1}};
      end
      if(sobel_3_green[12:12] == 1'b0) begin
        out_green <= sobel_3_green[11:4];
      end
      else begin
        out_green <= {8{1'b1}};
      end
      if(sobel_3_blue[12:12] == 1'b0) begin
        out_blue <= sobel_3_blue[11:4];
      end
      else begin
        out_blue <= {8{1'b1}};
      end
    end
    else begin
      out_hsync <= bypass_3_hsync;
      out_blank <= bypass_3_blank;
      out_vsync <= bypass_3_vsync;
      out_red <= bypass_3_red;
      out_blue <= bypass_3_blue;
      out_green <= bypass_3_green;
    end
    //------------------------------------
    // For if we eed to bypass the feature
    //------------------------------------
    bypass_3_blank <= bypass_2_blank;
    bypass_3_hsync <= bypass_2_hsync;
    bypass_3_vsync <= bypass_2_vsync;
    bypass_3_red <= bypass_2_red;
    bypass_3_blue <= bypass_2_blue;
    bypass_3_green <= bypass_2_green;
    bypass_2_blank <= bypass_1_blank;
    bypass_2_hsync <= bypass_1_hsync;
    bypass_2_vsync <= bypass_1_vsync;
    bypass_2_red <= bypass_1_red;
    bypass_2_blue <= bypass_1_blue;
    bypass_2_green <= bypass_1_green;
    bypass_1_blank <= blanks[4];
    bypass_1_hsync <= hsyncs[4];
    bypass_1_vsync <= vsyncs[4];
    bypass_1_red <= reds[4];
    bypass_1_blue <= blues[4];
    bypass_1_green <= greens[4];
    //--------------------------------
    //- Calculating the Sobel operator
    //--------------------------------
    sobel_3_blank <= sobel_2_blank;
    sobel_3_hsync <= sobel_2_hsync;
    sobel_3_vsync <= sobel_2_vsync;
    sobel_3_red <= ({1'b0,sobel_2_red_x}) + sobel_2_red_y;
    sobel_3_green <= ({1'b0,sobel_2_green_x}) + sobel_2_green_y;
    sobel_3_blue <= ({1'b0,sobel_2_blue_x}) + sobel_2_blue_y;
    // For the red channel
    sobel_2_blank <= sobel_1_blank;
    sobel_2_hsync <= sobel_1_hsync;
    sobel_2_vsync <= sobel_1_vsync;
    if(sobel_1_red_left > sobel_1_red_right) begin
      sobel_2_red_x <= sobel_1_red_left - sobel_1_red_right;
    end
    else begin
      sobel_2_red_x <= sobel_1_red_right - sobel_1_red_left;
    end
    if(sobel_1_red_top > sobel_1_red_bottom) begin
      sobel_2_red_y <= sobel_1_red_top - sobel_1_red_bottom;
    end
    else begin
      sobel_2_red_y <= sobel_1_red_bottom - sobel_1_red_top;
    end
    // For the green channel
    if(sobel_1_green_left > sobel_1_green_right) begin
      sobel_2_green_x <= sobel_1_green_left - sobel_1_green_right;
    end
    else begin
      sobel_2_green_x <= sobel_1_green_right - sobel_1_green_left;
    end
    if(sobel_1_green_top > sobel_1_green_bottom) begin
      sobel_2_green_y <= sobel_1_green_top - sobel_1_green_bottom;
    end
    else begin
      sobel_2_green_y <= sobel_1_green_bottom - sobel_1_green_top;
    end
    // For the blue channel
    if(sobel_1_blue_left > sobel_1_blue_right) begin
      sobel_2_blue_x <= sobel_1_blue_left - sobel_1_blue_right;
    end
    else begin
      sobel_2_blue_x <= sobel_1_blue_right - sobel_1_blue_left;
    end
    if(sobel_1_blue_top > sobel_1_blue_bottom) begin
      sobel_2_blue_y <= sobel_1_blue_top - sobel_1_blue_bottom;
    end
    else begin
      sobel_2_blue_y <= sobel_1_blue_bottom - sobel_1_blue_top;
    end
    // Now for the first stage;            
    sobel_1_blank <= blanks[4];
    sobel_1_hsync <= hsyncs[4];
    sobel_1_vsync <= vsyncs[4];
    // For the red channel
    sobel_1_red_left <= ({3'b000,reds[ + 1],1'b0}) + ({4'b0000,reds[ + 1]}) + ({3'b000,reds[ + 1],1'b0}) + ({1'b0,reds[3],3'b000}) + ({3'b000,reds[6],1'b0}) + ({4'b0000,reds[6]});
    sobel_1_red_right <= ({3'b000,reds[2],1'b0}) + ({4'b0000,reds[2]}) + ({3'b000,reds[5],1'b0}) + ({1'b0,reds[5],3'b000}) + ({3'b000,reds[8],1'b0}) + ({4'b0000,reds[8]});
    sobel_1_red_top <= ({3'b000,reds[2],1'b0}) + ({4'b0000,reds[2]}) + ({3'b000,reds[1],1'b0}) + ({1'b0,reds[1],3'b000}) + ({3'b000,reds[0],1'b0}) + ({4'b0000,reds[0]});
    sobel_1_red_bottom <= ({3'b000,reds[6],1'b0}) + ({4'b0000,reds[6]}) + ({3'b000,reds[7],1'b0}) + ({1'b0,reds[7],3'b000}) + ({3'b000,reds[8],1'b0}) + ({4'b0000,reds[8]});
    // For the green channel
    sobel_1_green_left <= ({3'b000,greens[0],1'b0}) + ({4'b0000,greens[0]}) + ({3'b000,greens[3],1'b0}) + ({1'b0,greens[3],3'b000}) + ({3'b000,greens[6],1'b0}) + ({4'b0000,greens[6]});
    sobel_1_green_right <= ({3'b000,greens[2],1'b0}) + ({4'b0000,greens[2]}) + ({3'b000,greens[5],1'b0}) + ({1'b0,greens[5],3'b000}) + ({3'b000,greens[8],1'b0}) + ({4'b0000,greens[8]});
    sobel_1_green_top <= ({3'b000,greens[2],1'b0}) + ({4'b0000,greens[2]}) + ({3'b000,greens[1],1'b0}) + ({1'b0,greens[1],3'b000}) + ({3'b000,greens[0],1'b0}) + ({4'b0000,greens[0]});
    sobel_1_green_bottom <= ({3'b000,greens[6],1'b0}) + ({4'b0000,greens[6]}) + ({3'b000,greens[7],1'b0}) + ({1'b0,greens[7],3'b000}) + ({3'b000,greens[8],1'b0}) + ({4'b0000,greens[8]});
    // For the blue channel
    sobel_1_blue_left <= ({3'b000,blues[0],1'b0}) + ({4'b0000,blues[0]}) + ({3'b000,blues[3],1'b0}) + ({1'b0,blues[3],3'b000}) + ({3'b000,blues[6],1'b0}) + ({4'b0000,blues[6]});
    sobel_1_blue_right <= ({3'b000,blues[2],1'b0}) + ({4'b0000,blues[2]}) + ({3'b000,blues[5],1'b0}) + ({1'b0,blues[5],3'b000}) + ({3'b000,blues[8],1'b0}) + ({4'b0000,blues[8]});
    sobel_1_blue_top <= ({3'b000,blues[2],1'b0}) + ({4'b0000,blues[2]}) + ({3'b000,blues[1],1'b0}) + ({1'b0,blues[1],3'b000}) + ({3'b000,blues[0],1'b0}) + ({4'b0000,blues[0]});
    sobel_1_blue_bottom <= ({3'b000,blues[6],1'b0}) + ({4'b0000,blues[6]}) + ({3'b000,blues[7],1'b0}) + ({1'b0,blues[7],3'b000}) + ({3'b000,blues[8],1'b0}) + ({4'b0000,blues[8]});
    //------------------------------------------------------------------
    // Copy over the short chains that gives us a 3x3 matrix to work with
    //-------------------------------------------------------------------
    // The bottom row
    blanks[1] <= blanks[0];
    hsyncs[1] <= hsyncs[0];
    vsyncs[1] <= vsyncs[0];
    reds[1] <= reds[0];
    greens[1] <= greens[0];
    blues[1] <= blues[0];
    blanks[2] <= blanks[1];
    hsyncs[2] <= hsyncs[1];
    vsyncs[2] <= vsyncs[1];
    reds[2] <= reds[1];
    greens[2] <= greens[1];
    blues[2] <= blues[1];
    // The middle row
    blanks[4] <= blanks[3];
    hsyncs[4] <= hsyncs[3];
    vsyncs[4] <= vsyncs[3];
    reds[4] <= reds[3];
    greens[4] <= greens[3];
    blues[4] <= blues[3];
    blanks[5] <= blanks[4];
    hsyncs[5] <= hsyncs[4];
    vsyncs[5] <= vsyncs[4];
    reds[5] <= reds[4];
    greens[5] <= greens[4];
    blues[5] <= blues[4];
    // The top row
    blanks[7] <= blanks[6];
    hsyncs[7] <= hsyncs[6];
    vsyncs[7] <= vsyncs[6];
    reds[7] <= reds[6];
    greens[7] <= greens[6];
    blues[7] <= blues[6];
    blanks[8] <= blanks[7];
    hsyncs[8] <= hsyncs[7];
    vsyncs[8] <= vsyncs[7];
    reds[8] <= reds[7];
    greens[8] <= greens[7];
    blues[8] <= blues[7];
  end


endmodule
