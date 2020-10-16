module top_OV7640
(
  input clk_25mhz,
  output [7:0] led,
  output [3:0] gpdi_dp, gpdi_dn,
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

parameter C_ddr = 1'b1; // 0:SDR 1:DDR
// You do not need to connect PWON and RESET pins, but if you do you need this
assign cam_PWON = 1'b0;  // constant camera Power ON
assign cam_RESET = 1'b1; // camera reset to HIGH
assign cam_PWON2 = 1'b0;  // constant camera Power ON
assign cam_RESET2 = 1'b1; // camera reset to HIGH

// wifi_gpio0=1 keeps board from rebooting (if it is onboard)
// hold btn0 to let ESP32 take control over the board
assign wifi_gpio0 = btn[0];

// Generate 100MHz clock needed for camera
wire clk_250MHz, clk_125MHz, clk_25MHz, clk_100MHz;

clk_25_250_125_25_100 clks_25_250_125_25_100
(
  .clki(clk_25mhz),
  .clko(clk_250MHz),
  .clks1(clk_125MHz),
  .clks2(clk_25MHz),
  .clks3(clk_100MHz)
);

// shift clock choice SDR/DDR
wire clk_pixel, clk_shift;
//assign clk_pixel = clk_25MHz;
assign clk_pixel = clk_25MHz;

generate
  if(C_ddr == 1'b1)
    assign clk_shift = clk_125MHz;
  else
    assign clk_shift = clk_250MHz;
endgenerate

wire inDisplayArea;
wire [9:0] CounterX;
wire [8:0] CounterY;
reg [4:0] fudge = 31;
wire vga_hsync, vga_vsync, vga_blank,frame_done;
reg [7:0] vga_R,vga_G,vga_B;

assign vga_blank = (~inDisplayArea); // vga is blank if pixel is not in Display area

hvsync_generator hvsync_gen(
  .clk(clk_25MHz), //Input
  .vga_h_sync(vga_hsync), //Output
  .vga_v_sync(vga_vsync),//Output
  .inDisplayArea(inDisplayArea), //Output
  .CounterX(CounterX), //Output
  .CounterY(CounterY) //Output
);

wire [15:0] pixin;
wire [15:0] hdmipixin;

//wire [7:0] R = { pixin[3:7], 3'b000};
//wire [7:0] G = { pixin[15:13], pixin[0:2], 2'b00};
//wire [7:0] B = { pixin[8:12] , 2'b00};

wire [7:0] R = { hdmipixin[15:11], 3'b000};
wire [7:0] G = { hdmipixin[10:5], 2'b00};
wire [7:0] B = { hdmipixin[4:0] , 3'b000};

reg [15:0] pixout;
reg [7:0] xout;
reg [6:0] yout;
reg realwe,we,we2;

assign vga_R = inDisplayArea?R:0;
assign vga_G = inDisplayArea?G:0;
assign vga_B = inDisplayArea?B:0;

wire [7:0] xin = (inDisplayArea ? (CounterX[9:2]) : 0);
wire [6:0] yin = (inDisplayArea ? (CounterY[8:2]) : 0);

wire [14:0] raddr = (y << 7) + (y << 5) - x - 8;
wire [14:0] hdmiraddr = (yin << 7) + (yin << 5) + xin;
wire [14:0] waddr = (yout << 7) + (yout << 5) + xout;

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
        .hdmiraddr(hdmiraddr),   // Input
        .pixin(pixin),  // Output
        .hdmipixin(hdmipixin), // Output
        .we(realwe),        // Input
        .waddr(waddr),  // Input
        .pixout(pixout) // Input
        );

wire [15:0] pixel_data,pixel_data2;
wire [9:0] realrow, realcol, row, row2, col, col2;


assign realrow = btn[3] ? row:row2;
assign realcol = btn[3] ? col:col2;

assign yout = 119 - realrow[8:2] + fudge;
assign xout = 150 - realcol[9:2];

assign pixout = btn[2] ? pixel_data:pixel_data2;//{pixel_data[13:15] , pixel_data[0:2]};
//{pixel_data[13:12],pixel_data[9:8], pixel_data[3:2]};

assign led[7:0] = hdmipixin[7:0]; //Just to see live data on LEDS

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
    .frame_done(frame_done),
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
    .frame_done(frame_done),
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

wire [7:0] x;
wire [7:0] y;
wire [7:0] color;

spi_video video(
    .clk(clk_25MHz),
    .oled_csn(oled_csn),
    .oled_clk(oled_clk),
    .oled_mosi(oled_mosi),
    .oled_dc(oled_dc),
    .oled_resn(oled_resn),
    .x(y),
    .y(x),
    .color(color)
);

//assign color = (x > xout && x < xout + 64 && y > yout && y < yout + 64) ? pixin : 8'hff;
assign color = (x >= 0 && x < 64 && y >= 0 && y < 96) ? { pixin[15:13], pixin[10:8], pixin[4:3] } : 8'hff;
//assign color = { pixin[15:13], pixin[10:8], pixin[4:3] };

// VGA to digital video converter
wire [1:0] tmds[3:0];
vga2dvid
#(
  .C_ddr(C_ddr)
)
vga2dvid_instance
(
  .clk_pixel(clk_pixel),
  .clk_shift(clk_shift),
  .in_red(vga_R),
  .in_green(vga_G),
  .in_blue(vga_B),
  .in_hsync(vga_hsync),
  .in_vsync(vga_vsync),
  .in_blank(vga_blank),
  .out_clock(tmds[3]),
  .out_red(tmds[2]),
  .out_green(tmds[1]),
  .out_blue(tmds[0])
);

// output TMDS SDR/DDR data to fake differential lanes
fake_differential
#(
  .C_ddr(C_ddr)
)
fake_differential_instance
(
  .clk_shift(clk_shift),
  .in_clock(tmds[3]),
  .in_red(tmds[2]),
  .in_green(tmds[1]),
  .in_blue(tmds[0]),
  .out_p(gpdi_dp),
  .out_n(gpdi_dn)
);

reg [15:0] data_reg;
reg [18:0] address;
reg [1:0] line;
reg [6:0] href_last;
reg write_en_reg;

endmodule