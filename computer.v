// computer.v  -- ISA 7+8 (15 bits) | A/B de 8 bits | Básicas completas
module computer(
  input  wire clk,
  input  wire rst
);
  // ===== PC & Fetch =====
  wire [15:0] pc_curr;
  wire [15:0] pc_next = pc_curr + 16'd1;
  wire [14:0] ir15;

  pc U_PC(.clk(clk), .rst(rst), .next_pc(pc_next), .pc(pc_curr));
  instruction_memory U_IM(.address(pc_curr), .out(ir15));

  // Campos
  wire [6:0] opcode = ir15[14:8];
  wire [7:0] imm    = ir15[7:0];

  // ===== Registros A/B =====
  wire [7:0] A_q, B_q;
  wire        weA, weB;
  wire [7:0] Y;

  register #(8) U_RA(.clk(clk), .rst(rst), .we(weA), .d(Y), .q(A_q));
  register #(8) U_RB(.clk(clk), .rst(rst), .we(weB), .d(Y), .q(B_q));

  // ===== Control =====
  // selX: 00->A, 01->B, 10->IMM (para alimentar 'a' o 'b' según operación)
  wire [1:0] selA, selB;
  wire [3:0] alu_op;

control_unit CU (
  .opcode(opcode),
  .weA(weA), .weB(weB),
  .selA(selA), .selB(selB),
  .alu_op(alu_op)
);

  // Banderas
  wire Z, N, C_from_alu, V_from_alu;
  reg  Zf, Nf, Cf, Vf;

  // Evita 'x' iniciales en flags
  initial begin Zf=1'b0; Nf=1'b0; Cf=1'b0; Vf=1'b0; end

  // Operandos a la ALU
  wire [7:0] opA = (selA==2'b00) ? A_q : (selA==2'b01 ? B_q : imm);
  wire [7:0] opB = (selB==2'b00) ? A_q : (selB==2'b01 ? B_q : imm);

  alu U_ALU(.a(opA), .b(opB), .op(alu_op), .y(Y), .z(Z), .n(N), .c(C_from_alu), .v(V_from_alu));

  // Latch de banderas al escribir A o B
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      {Zf,Nf,Cf,Vf} <= 4'b0000;
    end else if (weA || weB) begin
      Zf <= Z; Nf <= N; Cf <= C_from_alu; Vf <= V_from_alu;
    end
  end

  // ===== Señales de debug para GTKWave =====
  // synthesis translate_off
  wire [6:0]  opcode_dbg = opcode;
  wire [7:0]  imm_dbg    = imm;
  wire [7:0]  A_dbg      = A_q;
  wire [7:0]  B_dbg      = B_q;
  wire [7:0]  Y_dbg      = Y;
  wire        Z_dbg      = Zf, N_dbg = Nf, C_dbg = Cf, V_dbg = Vf;
  wire [15:0] pc_dbg     = pc_curr;
  // synthesis translate_on
endmodule
