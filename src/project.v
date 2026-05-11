`default_nettype none

module tt_um_demoscenettsky (
    input  wire [7:0] ui_in, // 8-bit input, [2:0] shift, [3] mask , 7[:5] pattern select3
    output wire [7:0] uo_out, // 8 -bit output bus, [5:0] RGB(RRGGBB), [6] hsync, [7] vsync
    input  wire [7:0] uio_in, // bidirectional I/O input (unused)
    output wire [7:0] uio_out, //bidirectional I/O Output, 8bit audio
    output wire [7:0] uio_oe, //bidirectional I/O enable 0xFF(255) during blanking, else 0
    input  wire       ena, // always 1 when on
    input  wire       clk, // 25MHz
    input  wire       rst_n // Active-low reset
);

// VGA Timing
	reg [9:0] x; // Horizontal pixel counter 0 - 799
	reg [9:0] y;  // Vertical pixel counter 0 - 524
	
	wire hsync = (x >= 10'd656 && x < 10'd752) ? 1'b0 : 1'b1; // active low
	wire vsync = (y >= 10'd490 && y < 10'd492) ? 1'b0 : 1'b1; // active low
	wire active = (x < 10'd640 && y < 10'd480); // visible screen
	
	always @(posedge clk) begin
		if (!rst_n) begin
			x <= 10'd0;
			y <= 10'd0;
		end else begin
			if (x == 10'd799) begin
				x <= 10'd0;
				if (y == 10'd524)
					y <= 10'd0;
				else
					y <= y + 1'b1;
			end else begin
				x <= x + 1'b1;
			end
		end
	end
	
	// vsync edge detection
	reg vsync_d;
	wire vsync_edge = (vsync_d == 1'b1 && vsync == 1'b0);
	
	always @(posedge clk) begin
		vsync_d <= vsync;
	end
	
	// Frame counter
	reg [15:0] t_frame;
	wire vsync_rising = (x == 10'd799 && y == 10'd524);
	
	always @(posedge clk) begin
		if (!rst_n)
			t_frame <= 16'd0;
		else if (vsync_rising)
			t_frame <= t_frame + 1'b1;
	end
	
	// LFSR
	
	reg [15:0] lfsr;
	always @(posedge clk) begin
		if (!rst_n)
			lfsr <= 16'hACE1;
		else
			lfsr <= {lfsr[14:0], ~(lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10])};
	end
	
	// Controller 
	reg [5:0] frame_count;
	reg [15:0] confi;
	
	always @(posedge clk) begin
		if (!rst_n) begin
			frame_count <= 6'd0;
			confi <= 16'h0000;
		end else if (vsync_rising) begin
			if (frame_count == 6'd59) begin
				frame_count <= 6'd0;
				confi <= lfsr;
			end else begin
				frame_count <= frame_count + 1'b1;
			end
		end
	end
	
	//Decode cOnfi
	wire [2:0] mode = confi[2:0];
	wire [2:0] shift_amt = confi[5:3];
	wire [1:0] palette_sel = confi[7:6];
	wire [2:0] audio_shift = confi[10:8];
	wire audio_mask = confi[11];

	//Render pipeline
	reg [7:0] pixel;
	
	wire [9:0] X = x;
	wire [9:0] Y = y;
	wire [7:0] s = {5'd0, shift_amt};
	
	always @* begin
		case (mode)
        	3'd0: pixel = (X ^ Y) & (X >> shift_amt) & (Y >> shift_amt);
            3'd1: pixel = (X ^ Y ^ (Y>>1) ^ (X<<1)) + t_frame[7:0];
            3'd2: pixel = (((X<<1) + X + Y) >> 1) ^ (((X + (Y<<1) + Y) >> 2) + t_frame[7:0]);
            3'd3: pixel = (X>>1) - (Y>>1) ^ (X | Y) + t_frame[7:0];
            3'd4: pixel = (X & Y) - (X | Y) ^ t_frame[7:0];
            3'd5: pixel = (X<<1) ^ (Y<<1) ^ ((X+Y) >> shift_amt);
            3'd6: pixel = (X * Y) & 8'hFF;      // pastel swirls
            3'd7: pixel = X ^ Y ^ (X >> (Y % 5)) ^ (Y >> (X % 5)) ^ t_frame[7:0];
            default: pixel = 8'd0;
        endcase
    end
    
    
    // Pallette mapper
    reg [5:0] rgb;
    always @* begin
        case (palette_sel)
            2'b00: rgb = {pixel[7:6], pixel[5:4], pixel[3:2]};        // natural
            2'b01: rgb = {pixel[7:6], pixel[3:2], pixel[5:4]};        // channel swap
            2'b10: rgb = {pixel[7:5], 1'b0, pixel[4:3]};              // muted
            2'b11: rgb = ~{pixel[7:5], pixel[4:2]};                   // inverted
        endcase
    end
	
	// VGA Output
	assign uo_out = active ? {vsync, hsync, rgb} : {vsync, hsync, 6'h00};
	
	// Audio engine
    reg [15:0] audio_t;
    always @(posedge clk) begin
        if (!rst_n)
            audio_t <= 16'd0;
        else
            audio_t <= audio_t + 1'b1;
    end

    wire [7:0] audio_sample;
    assign audio_sample = (audio_t[15:8] >> audio_shift) ^ (audio_t[7:0] & {8{audio_mask}});	
    
    
    // Bidirectional Pins
    assign uio_out = (active == 1'b0) ? audio_sample : 8'b0;
    assign uio_oe  = (active == 1'b0) ? 8'hFF : 8'h00;
    // During active video, the bidir pins are inputs (high impedance),
    // so they don't interfere with any external circuits.

endmodule	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
			
