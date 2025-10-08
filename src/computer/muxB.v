// muxB.v - Multiplexor para operando B de la ALU
// sel: 00 -> A_q, 01 -> B_q, 10 -> imm, otros -> 0
module muxB(
  input  wire [7:0] A_q,
  input  wire [7:0] B_q,
  input  wire [7:0] imm,
  input  wire [7:0] dmem_rdata, // nuevo: operando desde memoria
  input  wire [1:0] sel,
  output reg  [7:0] out
);
  always @* begin
    case (sel)
      2'b00: out = A_q;
      2'b01: out = B_q;
      2'b10: out = imm;
      2'b11: out = dmem_rdata; // Data Memory
      default: out = 8'h00;
    endcase
  end
endmodule
