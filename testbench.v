// testbench.v
`timescale 1ns/1ps
module testbench;
  reg clk = 0, rst = 1;

  computer DUT(.clk(clk), .rst(rst));

  // clock 10 ns (100 MHz)
  always #5 clk = ~clk;

  initial begin
    $dumpfile("out/dump.vcd");
    $dumpvars(0, testbench);

    // Reset firme por ~5 ciclos
    rst = 1;
    repeat (10) @(posedge clk);  // ~100 ns
    rst = 0;

    // Corre un rato y termina
    repeat (400) @(posedge clk);
    $finish;
  end
endmodule
