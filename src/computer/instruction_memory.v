// instruction_memory.v  -- Formato EXACTO 15 bits (7 opcode + 8 inmediato)
// Cada línea del archivo debe contener 15 bits binarios.
module instruction_memory(
  input  wire [15:0] address,
  output wire [14:0] out
);
  reg [14:0] mem [0:65535];

  initial begin
    $readmemb("data/im.dat", mem);   // 15 bits por línea
`ifndef SYNTHESIS
    $display("[IMEM] mem[0]=%b mem[1]=%b", mem[0], mem[1]);
`endif
  end

  // Entregamos palabra completa (15 bits): [14:8]=opcode (7b), [7:0]=imm (8b)
  assign out = mem[address];
endmodule
