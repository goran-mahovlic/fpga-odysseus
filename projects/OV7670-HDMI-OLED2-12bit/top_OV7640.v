module top_OV7640
(
  input clk_25mhz,
  output [7:0] led,
//  output [3:0] gpdi_dp, gpdi_dn,
  input [6:0] btn,
  input [7:0] cam_data,
  input cam_PCLK,
  input cam_HREF,
  input cam_VSYNC,
  output cam_RESET,
  output cam_XCLK,
  output cam_PWON,
  output cam_SOIC,
  inout  cam_SOID,
  input [7:0] cam_data2,
  input cam_PCLK2,
  input cam_HREF2,
  input cam_VSYNC2,
  output cam_RESET2,
  output cam_XCLK2,
  output cam_PWON2,
  output cam_SOIC2,
  inout  cam_SOID2,
  output wire oled_csn,
  output wire oled_clk,
  output wire oled_mosi,
  output wire oled_dc,
  output wire oled_resn,
  output wifi_gpio0
);

// You do not need to connect PWON and RESET pins, but if you do you need this
assign cam_PWON = 1'b0;  // constant camera Power ON
assign cam_RESET = 1'b1; // camera reset to HIGH
assign cam_PWON2 = 1'b0;  // constant camera Power ON
assign cam_RESET2 = 1'b1; // camera reset to HIGH

// wifi_gpio0=1 keeps board from rebooting (if it is onboard)
// hold btn0 to let ESP32 take control over the board
assign wifi_gpio0 = btn[0];

// Generate 100MHz clock needed for camera
wire clk_25MHz, clk_100MHz;

pll clks_25_250_125_25_100(
  .clki(clk_25mhz),
  .clks1(clk_25MHz),
  .clko(clk_100MHz)
  );

/*
clk_25_250_125_25_100 clks_25_250_125_25_100
(
  .clki(clk_25mhz),
//  .clko(clk_250MHz),
//  .clks1(clk_125MHz),
  .clks2(clk_25MHz),
  .clks3(clk_100MHz)
);
*/
reg [4:0] fudge = 15;

wire [15:0] pixin;
reg [15:0] pixout;
reg [7:0] xout;
reg [6:0] yout;
reg realwe,we,we2;

//wire [14:0] raddr = (x << 6) + (x << 4) - y;
//wire [14:0] waddr = (xout << 6) + (xout << 4) + yout;

wire [14:0] raddr = (y << 7) + (y << 5) + x + 34;
wire [14:0] waddr = (xout << 7) + (xout << 5) + yout;

// Work in progress
//edge_enhance edge_enhance(
  //.Edge_clk(clk_25MHz),
  //.enable_feature(btn[2]),
  //.in_blank(),
  //.in_hsync(),
  //.in_vsync(),
  //.in_red(),
  //.in_green(),
  //.in_blue(),
  //.out_blank(),
  //.out_hsync(),
  //.out_vsync(),
  //.out_red(),
  //.out_green(),
  //.out_blue()
  //);

assign realwe = btn[3] ? pixel_data:pixel_data2;

vgabuff vgab (
        .clk(clk_25MHz), // Input
        .raddr(raddr),   // Input
        //.hdmiraddr(),   // Input
        .pixin(pixin),  // Output
        //.hdmipixin(), // Output
        .we(realwe),        // Input
        .waddr(waddr),  // Input
        .pixout(pixout) // Input
        );

wire [15:0] pixel_data,pixel_data2;
wire [9:0] realrow, realcol, row, row2, col, col2;

assign led[7:0] = pixin;
assign realrow = btn[3] ? row:row2;
assign realcol = btn[3] ? col:col2;

assign xout = 119 - realrow[8:2] + fudge;
assign yout = 150 - realcol[9:2];

assign pixout = btn[3] ? pixel_data:pixel_data2;

assign cam_XCLK =  clk_25MHz;  // From 10MHz to 48MHz
assign cam_XCLK2 =  clk_25MHz;  // From 10MHz to 48MHz

camera_read cam_read(
    .clk(clk_100MHz),          // 100MHz INPUT
    .x_clock(),                // OUTPUT
    .p_clock(cam_PCLK),        // Input
    .vsync(cam_VSYNC),         // Input
    .href(cam_HREF),           // Input
    .p_data(cam_data),         // Input
    .pixel_data(pixel_data),   // Output
    .pixel_valid(we),          // Input
    .frame_done(),
    .row(row),
    .col(col)
);

camera_read cam_read2(
    .clk(clk_100MHz),          // 100MHz INPUT
    .x_clock(),                // OUTPUT
    .p_clock(cam_PCLK2),        // Input
    .vsync(cam_VSYNC2),         // Input
    .href(cam_HREF2),           // Input
    .p_data(cam_data2),         // Input
    .pixel_data(pixel_data2),   // Output
    .pixel_valid(we2),          // Input
    .frame_done(),
    .row(row2),
    .col(col2)
);

wire invertBTN1 = (~btn[1]);
wire invertBTN2 = (~btn[2]);

camera_configure cam_configure
(
    .clk(clk_100MHz),   //100MHz
    .start(invertBTN1), // Input
    .sioc(cam_SOIC),    // Output
    .siod(cam_SOID),    // Output
    .done(),            // Output
    .x_clock()          // (cam_XCLK) // Output
);

camera_configure cam_configure2
(
    .clk(clk_100MHz),   //100MHz
    .start(invertBTN2), // Input
    .sioc(cam_SOIC2),    // Output
    .siod(cam_SOID2),    // Output
    .done(),            // Output
    .x_clock()          // (cam_XCLK) // Output
);

wire [6:0] x;
wire [5:0] y;
wire [15:0] color;

    oled_video
    #(
        .C_init_file("oled_init_xflip_16bit.mem"),
        .C_color_bits(16)
    )
    oled_video_inst
    (
        .clk(clk_25mhz),
        .x(x),
        .y(y),
        .next_pixel(),
        .color(color),
        .oled_csn(oled_csn),
        .oled_clk(oled_clk),
        .oled_mosi(oled_mosi),
        .oled_dc(oled_dc),
        .oled_resn(oled_resn)
    );

//8 bit
//assign color = (x >= 0 && x < 64 && y >= 0 && y < 96) ? { pixin[15:13], pixin[10:8], pixin[4:3] } : 8'hff;
//16 bit
assign color = (x >= 0 && x < 96 && y >= 0 && y < 64) ? pixin : 16'haa;

endmodule
