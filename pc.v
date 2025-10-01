// pc.v
module pc(
  input  wire        clk,
  input  wire        rst,
  input  wire [15:0] next_pc,
  output reg  [15:0] pc
);
  // Evita PC='x' al inicio de la simulación
  initial pc = 16'h0000;

  always @(posedge clk or posedge rst) begin
    if (rst) pc <= 16'h0000;
    else     pc <= next_pc;
  end
endmodule
