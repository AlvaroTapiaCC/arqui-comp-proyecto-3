// muxA.v (A_q/B_q/imm)
module muxA(
  input  wire [7:0] A_q,
  input  wire [7:0] B_q,
  input  wire [7:0] imm,
  input  wire [1:0] sel,
  output reg  [7:0] out
);
  always @* begin
    case (sel)
      2'b00: out = A_q;
      2'b01: out = B_q;
      2'b10: out = imm;
      default: out = 8'h00;
    endcase
  end
endmodule
