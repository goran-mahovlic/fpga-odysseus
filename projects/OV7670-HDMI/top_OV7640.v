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
  output wifi_gpio0
);

parameter C_ddr = 1'b1; // 0:SDR 1:DDR
// You do not need to connect PWON and RESET pins, but if you do you need this
assign cam_PWON = 1'b0;  // constant camera Power ON
assign cam_RESET = 1'b1; // camera reset to HIGH

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

//wire [7:0] R = { pixin[3:7], 3'b000};
//wire [7:0] G = { pixin[15:13], pixin[0:2], 2'b00};
//wire [7:0] B = { pixin[8:12] , 2'b00};

wire [7:0] R = { pixin[15:11], 3'b000};
wire [7:0] G = { pixin[10:5], 2'b00};
wire [7:0] B = { pixin[4:0] , 3'b000};

reg [15:0] pixout;
reg [7:0] xout;
reg [6:0] yout;
reg we;

assign vga_R = inDisplayArea?R:0;
assign vga_G = inDisplayArea?G:0;
assign vga_B = inDisplayArea?B:0;

wire [7:0] xin = (inDisplayArea ? (CounterX[9:2]) : 0);
wire [6:0] yin = (inDisplayArea ? (CounterY[8:2]) : 0);

wire [14:0] raddr = (yin << 7) + (yin << 5) + xin;
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

vgabuff vgab (
        .clk(clk_25MHz), // Input
        .raddr(raddr),   // Input
        .pixin(pixin),  // Output
        .we(we),        // Input
        .waddr(waddr),  // Input
        .pixout(pixout) // Input
        );

wire [15:0] pixel_data;
wire [9:0] row, col;

assign yout = 119 - row[8:2] + fudge;
assign xout = 150 - col[9:2];

assign pixout = pixel_data;//{pixel_data[13:15] , pixel_data[0:2]};
//{pixel_data[13:12],pixel_data[9:8], pixel_data[3:2]};

assign led[7:0] = pixin[7:0]; //Just to see live data on LEDS

assign cam_XCLK =  clk_25MHz;  // From 10MHz to 48MHz

camera_read cam_read(
    .clk(clk_100MHz),          // 100MHz INPUT
    .x_clock(),                // OUTPUT
    .p_clock(cam_PCLK),        // Input
    .vsync(cam_VSYNC),         // Input
    .href(cam_HREF),           // Input
    .p_data(cam_data),         // Input
    .pixel_data(pixel_data),   // Input
    .pixel_valid(we),          // Input
    .frame_done(frame_done),
    .row(row),
    .col(col)
);

wire invertBTN1 = (~btn[1]);

camera_configure cam_configure
(
    .clk(clk_100MHz),   //100MHz
    .start(invertBTN1), // Input
    .sioc(cam_SOIC),    // Output
    .siod(cam_SOID),    // Output
    .done(),            // Output
    .x_clock()          // (cam_XCLK) // Output
);

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
