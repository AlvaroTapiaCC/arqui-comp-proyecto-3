// instruction_memory.v  -- Formato 7+8 en 15 bits (bit 15 no usado)
// Lee BINARIO puro (16 bits por línea) desde im.dat
module instruction_memory(
  input  wire [15:0] address,
  output wire [14:0] out
);
  reg [15:0] mem [0:65535];

  initial begin
    $readmemb("data/im.dat", mem);   // <--- BINARIO (ruta actualizada)
`ifndef SYNTHESIS
    // Log para verificar carga (solo en simulación)
    $display("[IMEM] mem[0]=%b mem[1]=%b", mem[0], mem[1]);
`endif
  end

  // Entregamos los 15 bits válidos: [14:8]=opcode (7b), [7:0]=imm (8b)
  assign out = mem[address][14:0];
endmodule
