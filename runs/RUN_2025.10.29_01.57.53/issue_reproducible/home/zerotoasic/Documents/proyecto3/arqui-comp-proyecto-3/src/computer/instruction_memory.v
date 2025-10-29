// instruction_memory.v (15 bits: 7 opcode + 8 imm)
// Interfaz idéntica a la original.
// - Modo normal (sim/FPGA): usa $readmemb("data/im.dat", ...)
// - Modo ASIC: ROM sintetizable por case sobre los bits bajos de 'address'.
//
// Para activar el modo ASIC (OpenLane):
//   define la macro ASIC (p. ej., SYNTH_DEFINES="SYNTHESIS ASIC")
// Ajusta ROM_AW para la profundidad (2**ROM_AW palabras).

module instruction_memory(
  input  wire [15:0] address,
  output wire [14:0] out
);

`ifdef ASIC
  // ========== MODO ASIC: ROM sintetizable ==========
  // Profundidad de la ROM (2**ROM_AW palabras)
  parameter ROM_AW = 6;  // 64 palabras por defecto (ajustable a 5..8 típicamente)
  wire [ROM_AW-1:0] a = address[ROM_AW-1:0];

  // Salida registrada-combinacional interna
  reg [14:0] rom_q;
  assign out = rom_q;

  // Ayudante para empaquetar {opcode[6:0], imm[7:0]}
  function [14:0] PACK;
    input [6:0] opcode;
    input [7:0] imm;
    begin
      PACK = {opcode, imm};
    end
  endfunction

  always @* begin
    // Valor por defecto si la dirección no está listada
    rom_q = 15'h0000;

    // Programa (ejemplos en cero). Edítalo según tu ISA.
    // Usa: rom_q = PACK(7'hOP, 8'hIMM);
    case (a)
      // Dirección 0
      0: rom_q = PACK(7'h00, 8'h00); // NOP (ejemplo)
      // Dirección 1
      1: rom_q = PACK(7'h00, 8'h00);
      // Dirección 2
      2: rom_q = PACK(7'h00, 8'h00);
      // Dirección 3
      3: rom_q = PACK(7'h00, 8'h00);

      // Agrega aquí tus instrucciones...
      // 4: rom_q = PACK(7'hXX, 8'hYY);
      // 5: rom_q = PACK(7'hXX, 8'hYY);
      // ...

      default: /* rom_q ya es 0 */ ;
    endcase
  end

`else
  // ========== MODO NORMAL: igual a la original ==========
  reg [14:0] mem [0:65535];

  // Carga de programa para simulación/FPGA (ignorada por síntesis ASIC)
  initial $readmemb("data/im.dat", mem);

  // Salida combinacional, como en tu versión original
  assign out = mem[address];
`endif

endmodule