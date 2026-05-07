`default_nettype none

module tt_um_bytebeat (
    input  wire [7:0] ui_in,    // ui_in[2:0] shift, [3] mask enable, [7:5] pattern select
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    reg [15:0] t;
    reg [7:0]  pattern;   // output buffer (for combinational logic clarity)

    // Common control fields
    wire [2:0] shift_amt = ui_in[2:0];
    wire       mask_en   = ui_in[3];
    wire [2:0] pat_sel   = ui_in[7:5];

    // Mask for low byte
    wire [7:0] mask = {8{mask_en}};

    // Pattern generation – selected by pat_sel
    always @* begin
        case (pat_sel)
            // 0: Original mode – shift + XOR masked low byte
            3'd0: pattern = (t[15:8] >> shift_amt) ^ (t[7:0] & mask);

            // 1: Classic bytebeat “t * (t>>8)” with shift control
            3'd1: pattern = t[7:0] + ((t[15:8] >> shift_amt) & mask) ^ (t[15:8] << 1);

            // 2: Metallic bell – (t * (t>>8)) XOR (t>>(shift+4))
            3'd2: pattern = (t[7:0] * (t[15:8] >> shift_amt)) ^ (t[15:8] >> (shift_amt+1));

            // 3: Sierpinski-like fractal – t & (t>>8) XOR t>>shift
            3'd3: pattern = (t[7:0] & (t[15:8] >> shift_amt)) ^ (t[15:8] >> (shift_amt+2));

            // 4: Hollow drone – alternating hi/lo slices
            3'd4: pattern = (t[15:8] >> shift_amt) | (t[7:0] & mask);

            // 5: Square‑wave mash – multiple XORS with shifted copies
            3'd5: pattern = (t[15:8] ^ (t[15:8] >> shift_amt)) + (t[7:0] & mask);

            // 6: Reverse saw – subtract shifted high byte from low byte
            3'd6: pattern = t[7:0] - (t[15:8] >> shift_amt);

            // 7: Chaotic mixer – triple XOR
            default: pattern = t[15:8] ^ (t[7:0] >> shift_amt) ^ (t[15:8] << 3) ^ (t[7:0] & mask);
        endcase
    end

    assign uo_out = pattern;

    // Bidirectional pins
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // 16‑bit counter
    always @(posedge clk) begin
        if (!rst_n)
            t <= 16'd0;
        else
            t <= t + 1'd1;
    end

endmodule
