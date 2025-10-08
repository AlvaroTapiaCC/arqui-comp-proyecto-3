// instruction_memory.v (15 bits: 7 opcode + 8 imm)
module instruction_memory(
  input  wire [15:0] address,
  output wire [14:0] out
);
  reg [14:0] mem [0:65535];

  initial $readmemb("data/im.dat", mem);

  assign out = mem[address];
endmodule
