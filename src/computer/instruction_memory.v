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
  parameter ROM_AW = 4;  // 16 palabras por defecto (suficiente para demo)
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

  // Programa de demostración: cuenta regresiva B=15..0 y refleja en A
  // Instrucciones usadas:
  //   0x03 MOV B,lit
  //   0x00 MOV A,B
  //   0x0B SUB B,lit
  //   0x54 JEQ imm
  //   0x53 JMP imm
  always @* begin
    // Valor por defecto si la dirección no está listada
    rom_q = 15'h0000;

    case (a)
      // 0: B <- 0x0F (15)
      0: rom_q = PACK(7'h03, 8'h0F);
      // 1: A <- B (mostrar 15)
      1: rom_q = PACK(7'h00, 8'h00);
      // 2: B <- B - 1
      2: rom_q = PACK(7'h0B, 8'h01);
      // 3: A <- B (reflejar en salida)
      3: rom_q = PACK(7'h00, 8'h00);
      // 4: si Z==1 (B==0) -> goto 7
      4: rom_q = PACK(7'h54, 8'h07);
      // 5: goto 2 (loop)
      5: rom_q = PACK(7'h53, 8'h02);
      // 6: (sin uso)
      6: rom_q = PACK(7'h00, 8'h00);
      // 7: bucle final (halt por salto a sí mismo)
      7: rom_q = PACK(7'h53, 8'h07);
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