`timescale 1ns/1ps

module tb_countdown;
  reg clk=0, rst=1;
  wire [7:0] A_out, B_out; wire [6:0] last_opcode; wire [3:0] flags;

  // DUT
  computer dut(
    .clk(clk), .rst(rst), .A_out(A_out), .B_out(B_out), .last_opcode_out(last_opcode), .flags_out(flags)
  );

  // clock
  always #5 clk = ~clk; // 100 MHz

  integer i;
  initial begin
    // release reset after some cycles
    repeat (5) @(posedge clk);
    rst = 0;

    // run for some cycles
    for (i=0; i<64; i=i+1) begin
      @(posedge clk);
      $display("t=%0t ns | PC step %0d | A=%0d (0x%0h) B=%0d (0x%0h) op=0x%0h Z=%0b N=%0b C=%0b V=%0b", $time, i, A_out, A_out, B_out, B_out, last_opcode, flags[3],flags[2],flags[1],flags[0]);
    end
    $finish;
  end
endmodule
