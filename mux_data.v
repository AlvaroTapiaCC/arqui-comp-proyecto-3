// mux_data.v - Multiplexor de fuente de escritura hacia registros A/B
// Por ahora sólo una fuente (ALU). Se deja preparado para ampliar.
// sel: 00 -> alu_y, 01 -> data_mem, 10 -> literal (futuro), otros -> 0
module mux_data(
  input  wire [7:0] alu_y,
  input  wire [7:0] data_mem_y,   // futuro (por ahora conectar a 8'h00)
  input  wire [7:0] literal_y,    // futuro (ya llega como imm si se decide)
  input  wire [1:0] sel,
  output reg  [7:0] out
);
  always @* begin
    case (sel)
      2'b00: out = alu_y;
      2'b01: out = data_mem_y;
      2'b10: out = literal_y;
      default: out = 8'h00;
    endcase
  end
endmodule
