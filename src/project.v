`default_nettype none

module tt_um_template (
    input  wire [7:0] ui_in,    // Dedicated inputs (Controls)
    output wire [7:0] uo_out,   // Dedicated outputs (Pattern Output)
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // 16-bit counter acting as our continuous "time" variable (t)
    reg [15:0] t;

    // The Algorithmic Engine: 
    // We mix bits of the counter (t) with the user inputs to generate the pattern
    assign uo_out = (t[15:8] >> ui_in[2:0]) ^ (t[7:0] & {8{ui_in[3]}});

    // Set bidirectional pins to inputs to be safe
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    always @(posedge clk) begin
        if (!rst_n) begin
            t <= 16'b0;
        end else begin
            t <= t + 1'b1;
        end
    end

endmodule
