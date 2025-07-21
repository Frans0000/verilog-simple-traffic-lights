module traffic_light(
	input wire clk,
	input wire rst,
	input wire button,
	
	output reg car_green,
	output reg car_yellow,
	output reg car_red,
	
	output reg ped_green,
	output reg ped_red
);

reg [31:0] counter;
reg [2:0] current_state;
reg	[2:0] next_state;

//debouncing
reg [19:0] debounce_counter;
reg button_stable;

//blinking green pedestrians
reg blink_clk;
reg [31:0] blink_counter;

//states
parameter CARS_GREEN 		= 3'b000;	 	
parameter CARS_GREEN_CHANGE = 3'b001;
parameter CARS_YELLOW 		= 3'b010;	
parameter ALL_RED_BE		= 3'b011;	
parameter PED_GREEN			= 3'b100;	
parameter PED_BLINK			= 3'b101;
parameter ALL_RED_AF		= 3'b110;
parameter CARS_RED_YELLOW 	= 3'b111;	

parameter clock_time_1s 	= 50_000_000; 
parameter debounce_time     = 20'd1000000;  
parameter blink_time        = 32'd25_000_000;

parameter green_time_cars		= clock_time_1s * 15; 
parameter green_time_change 	= clock_time_1s * 5;
parameter yellow_time_cars		= clock_time_1s * 3;
parameter all_red_time			= clock_time_1s * 3;
parameter green_time_ped		= clock_time_1s * 5;
parameter green_time_blink		= clock_time_1s * 3;
parameter red_yellow_time_cars 	= clock_time_1s * 2;


always @(posedge clk or posedge rst) begin
  if (rst) begin
    counter <= 32'd0;
  end else begin
    if (current_state != next_state) begin
      counter <= 32'd0;
    end else begin
      counter <= counter + 1;
    end
  end
end


always @(posedge clk or posedge rst) begin
  if (rst) begin
    blink_counter <= 32'd0;
    blink_clk <= 1'b0;
  end else if (current_state == PED_BLINK) begin
    if (blink_counter >= blink_time) begin 
      blink_clk <= ~blink_clk;
      blink_counter <= 32'd0;
    end else begin
      blink_counter <= blink_counter + 1;
    end
  end else begin
    blink_counter <= 32'd0;
    blink_clk <= 1'b0;
  end
end


always @(posedge clk or posedge rst) begin
	if(rst) begin
		debounce_counter <= 0;
		button_stable <= 0;
	end
    else if (button != button_stable) begin
        debounce_counter <= debounce_counter + 1;
        if (debounce_counter >= debounce_time)
            button_stable <= button;
    end else
        debounce_counter <= 0;
end


always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= CARS_GREEN;
	end else begin
        current_state <= next_state;
    end
end


always @(*) begin
	case (current_state)
		CARS_GREEN: begin
			if(counter >= green_time_cars || button_stable) begin
				next_state = CARS_GREEN_CHANGE;
			end else begin
				next_state = CARS_GREEN;
			end
		end
		
		CARS_GREEN_CHANGE: begin
			if(counter >= green_time_change) begin
				next_state = CARS_YELLOW;
			end else begin
			   next_state = CARS_GREEN_CHANGE;
			end
		end
		
		CARS_YELLOW: begin
			if(counter >= yellow_time_cars) begin
				next_state = ALL_RED_BE;
			end else begin
			   next_state = CARS_YELLOW;
			end
		end
		
		ALL_RED_BE: begin
			if(counter >= all_red_time) begin
				next_state = PED_GREEN;
			end else begin
			   next_state = ALL_RED_BE;
			end
		end
		
		PED_GREEN: begin
			if(counter >= green_time_ped) begin
				next_state = PED_BLINK;
			end else begin
			   next_state = PED_GREEN;
			end
		end
		
		PED_BLINK: begin
			if(counter >= green_time_blink) begin
				next_state = ALL_RED_AF;
			end else begin
			   next_state = PED_BLINK;
			end
		end
		
		ALL_RED_AF: begin
			if(counter >= all_red_time) begin
				next_state = CARS_RED_YELLOW;
			end else begin
			   next_state = ALL_RED_AF;
			end
		end
		
		CARS_RED_YELLOW: begin
			if(counter >= red_yellow_time_cars) begin
				next_state = CARS_GREEN;
			end else begin
			   next_state = CARS_RED_YELLOW;
			end
		end
		
		default: begin
			next_state = CARS_GREEN;
		end
	endcase
end

always @(*) begin
	case (current_state)
		CARS_GREEN: begin
			car_green = 1'b1;
			car_yellow = 1'b0;
			car_red = 1'b0;
			
			ped_green = 1'b0;
			ped_red = 1'b1;
		end
		
		CARS_GREEN_CHANGE: begin
			car_green = 1'b1;
			car_yellow = 1'b0;
			car_red = 1'b0;
			
			ped_green = 1'b0;
			ped_red = 1'b1;
		end
		
		CARS_YELLOW: begin
			car_green = 1'b0;
			car_yellow = 1'b1;
			car_red = 1'b0;
			
			ped_green = 1'b0;
			ped_red = 1'b1;
		end
		
		ALL_RED_BE: begin
			car_green = 1'b0;
			car_yellow = 1'b0;
			car_red = 1'b1;
			
			ped_green = 1'b0;
			ped_red = 1'b1;
		end
		
		PED_GREEN: begin
			car_green = 1'b0;
			car_yellow = 1'b0;
			car_red = 1'b1;
			
			ped_green = 1'b1;
			ped_red = 1'b0;
		end
		
		PED_BLINK: begin
			car_green = 1'b0;
			car_yellow = 1'b0;
			car_red = 1'b1;
			
			ped_green = blink_clk;
			ped_red = ~blink_clk; 
		end
		
		ALL_RED_AF: begin
			car_green = 1'b0;
			car_yellow = 1'b0;
			car_red = 1'b1;
			
			ped_green = 1'b0;
			ped_red = 1'b1;
		end
		
		CARS_RED_YELLOW: begin
			car_green = 1'b0;
			car_yellow = 1'b1;
			car_red = 1'b1;
			
			ped_green = 1'b0;
			ped_red = 1'b1;
		end
		
		default: begin
			car_green = 1'b0;
			car_yellow = 1'b1;
			car_red = 1'b1;
			
			ped_green = 1'b0;
			ped_red = 1'b1;		
		end
	endcase
end

endmodule