`default_nettype none
`timescale 1ns / 1ps
//=============================================================================
// tt_um_cordic_sc
//
// Single-clock, iterative (sequential) CORDIC sine/cosine core for
// TinyTapeout. Rotation-mode CORDIC, 8 iterations, quadrant range 0-90 deg.
//
//   ui_in[7:0]  : angle input. 0 .. 255 maps to 0 .. ~89.65 degrees
//                 (256 codes = 90 degrees)
//   uio_in[0]   : start (pulse high for >=1 clk to begin a computation)
//   uio_in[1]   : result select -> 0 = cosine, 1 = sine
//   uo_out[7:0] : signed result, scale 128 = 1.0 (e.g. cos(0) = 128,
//                 sin(0) = 0, cos(45) ~ 90, sin(90) ~ 128)
//   uio_out[2]  : done flag (1 while a valid result is held in uo_out)
//   uio_oe[2]   : driven high (output); all other uio bits are inputs
//                 and unused
//
// Only one clock in the design: clk.
//=============================================================================

module tt_um_cordic_sc (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe
);

    localparam integer NITER = 8;

    wire start   = uio_in[0];
    wire sel_sin = uio_in[1];

    reg signed [9:0] x_reg, y_reg, z_reg;
    reg [3:0]        iter_cnt;
    reg              busy;
    reg              done;
    reg              sel_sin_r;

    // atan(2^-i) lookup, scale: 256 units = 90 degrees
    function signed [9:0] atan_lut;
        input [2:0] idx;
        begin
            case (idx)
                3'd0: atan_lut = 10'sd128;
                3'd1: atan_lut = 10'sd76;
                3'd2: atan_lut = 10'sd40;
                3'd3: atan_lut = 10'sd20;
                3'd4: atan_lut = 10'sd10;
                3'd5: atan_lut = 10'sd5;
                3'd6: atan_lut = 10'sd3;
                default: atan_lut = 10'sd1;
            endcase
        end
    endfunction

    wire signed [9:0] x_shift = y_reg >>> iter_cnt[2:0];
    wire signed [9:0] y_shift = x_reg >>> iter_cnt[2:0];
    wire               dir    = z_reg[9];              // 1 = z negative
    wire signed [9:0] atan_c  = atan_lut(iter_cnt[2:0]);

    wire signed [9:0] x_next = dir ? (x_reg + x_shift) : (x_reg - x_shift);
    wire signed [9:0] y_next = dir ? (y_reg - y_shift) : (y_reg + y_shift);
    wire signed [9:0] z_next = dir ? (z_reg + atan_c)  : (z_reg - atan_c);

    always @(posedge clk) begin
        if (!rst_n) begin
            x_reg     <= 10'sd0;
            y_reg     <= 10'sd0;
            z_reg     <= 10'sd0;
            iter_cnt  <= 4'd0;
            busy      <= 1'b0;
            done      <= 1'b0;
            sel_sin_r <= 1'b0;
        end else if (ena) begin
            if (start && !busy) begin
                x_reg     <= 10'sd78;                // K*128, K = CORDIC gain
                y_reg     <= 10'sd0;
                z_reg     <= {2'b00, ui_in};
                iter_cnt  <= 4'd0;
                busy      <= 1'b1;
                done      <= 1'b0;
                sel_sin_r <= sel_sin;
            end else if (busy) begin
                x_reg    <= x_next;
                y_reg    <= y_next;
                z_reg    <= z_next;
                iter_cnt <= iter_cnt + 4'd1;
                if (iter_cnt == 4'd7) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end else begin
                done <= 1'b0;
            end
        end
    end

    assign uo_out  = sel_sin_r ? y_reg[7:0] : x_reg[7:0];
    assign uio_out = {5'b00000, done, 2'b00};
    assign uio_oe  = 8'b0000_0100;

endmodule
