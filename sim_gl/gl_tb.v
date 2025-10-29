`timescale 1ns/1ps

module gl_tb;
  // Power supplies
  supply0 VGND;
  supply1 VPWR;

  // Clock and reset
  reg clk = 0;
  reg rst = 1;

  // Outputs
  wire [7:0] A_out;
  wire [7:0] B_out;
  wire [6:0] last_opcode_out;
  wire [3:0] flags_out;

  // Clock generation: 50 MHz => 20 ns period
  always #10 clk = ~clk;

  // DUT (gate-level netlist has explicit power pins)
  computer dut (
    .VGND(VGND),
    .VPWR(VPWR),
    .clk(clk),
    .rst(rst),
    .A_out(A_out),
    .B_out(B_out),
    .last_opcode_out(last_opcode_out),
    .flags_out(flags_out)
  );

  initial begin
    $dumpfile("gl_wave.vcd");
    $dumpvars(0, gl_tb);

    // Reset pulse
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;

    // Run for some cycles
    repeat (200) @(posedge clk);
    $display("[GL] Done. A_out=%0d (0x%0h) B_out=%0d (0x%0h) flags=%b opcode=%0d",
             A_out, A_out, B_out, B_out, flags_out, last_opcode_out);
    $finish;
  end
endmodule
