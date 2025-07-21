
module top
(  
  input  wire       CLK_PCB,
  input  wire       nRST_PCB, 
  
  input  wire       ROAD_DET,
  output wire       ROAD_RED,
  output wire       ROAD_YELLOW,
  output wire       ROAD_GREEN,
  
  input  wire       PED_BUTT,
  output wire       PED_RED,
  output wire       PED_GREEN,

  output wire [3:0] LED
);    
//-------------------------------------------------------------------------------
  parameter SIM = "FALSE";
//-------------------------------------------------------------------------------
  wire CLK = CLK_PCB;
  wire RST_PCB = ~nRST_PCB;
  wire RST_async, RST_sync, RST;         
//-------------------------------------------------------------------------------  
  assign RST_async = RST_PCB ;
  assign RST_sync = RST_async;
  assign RST = RST_sync;

  
  traffic_light traffic_lights(
    .clk(CLK),
    .rst(RST),
    .button(PED_BUTT),
    .car_green(ROAD_GREEN),
    .car_yellow(ROAD_YELLOW),
    .car_red(ROAD_RED),
    .ped_green(PED_GREEN),
    .ped_red(PED_RED)
  );



endmodule
