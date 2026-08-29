`timescale 1ns / 1ps
//=============================================================================
// tb_cordic_sc
// Testbench for tt_um_cordic_sc. Runs several angle/select combinations
// and prints the resulting cos/sin values.
//=============================================================================

module tb_cordic_sc;

    reg        clk;
    reg        rst_n;
    reg        ena;
    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_cordic_sc dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .ena     (ena),
        .ui_in   (ui_in),
        .uo_out  (uo_out),
        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe)
    );

    // 64 MHz clock -> 15.625 ns period
    initial clk = 1'b0;
    always #7.8125 clk = ~clk;

    task run_case;
        input [7:0] angle;
        input       sin_sel;
        begin
            @(negedge clk);
            ui_in     = angle;
            uio_in[1] = sin_sel;
            uio_in[0] = 1'b1;   // start pulse
            @(negedge clk);
            uio_in[0] = 1'b0;
            wait (uio_out[2] == 1'b1);
            @(negedge clk);
            $display("angle_code=%0d sel_sin=%0d result=%0d (signed=%0d)",
                       angle, sin_sel, uo_out, $signed(uo_out));
        end
    endtask

    initial begin
        rst_n  = 1'b0;
        ena    = 1'b1;
        ui_in  = 8'd0;
        uio_in = 8'd0;

        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        repeat (2) @(negedge clk);

        run_case(8'd0,   1'b0);  // cos(0)     -> ~128
        run_case(8'd0,   1'b1);  // sin(0)     -> ~0
        run_case(8'd128, 1'b0);  // cos(45deg) -> ~90
        run_case(8'd128, 1'b1);  // sin(45deg) -> ~90
        run_case(8'd255, 1'b0);  // cos(~90deg)-> ~0
        run_case(8'd255, 1'b1);  // sin(~90deg)-> ~128

        $display("All test cases completed.");
        $finish;
    end

    initial begin
        $dumpfile("tb_cordic_sc.vcd");
        $dumpvars(0, tb_cordic_sc);
    end

endmodule
