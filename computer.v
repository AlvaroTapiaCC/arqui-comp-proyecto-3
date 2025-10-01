// computer.v  -- ISA 7+8 (15 bits) | A/B de 8 bits | Básicas completas
module computer(
  input  wire clk,
  input  wire rst,
  // Salidas de observabilidad para evitar que Yosys optimice todo a vacío
  output wire [7:0] A_out,
  output wire [7:0] B_out,
  output wire [6:0] last_opcode_out,
  output wire [3:0] flags_out
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

  // ===== Registros A/B y bus de escritura =====
  wire [7:0] A_q, B_q;
  wire       weA, weB;
  wire [7:0] alu_y;       // salida cruda ALU
  wire [7:0] write_bus;   // salida del mux_data (fuente final a registros)

  register #(8) U_RA(.clk(clk), .rst(rst), .we(weA), .d(write_bus), .q(A_q));
  register #(8) U_RB(.clk(clk), .rst(rst), .we(weB), .d(write_bus), .q(B_q));

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

  // Señales crudas desde la ALU
  wire Z, N, C_from_alu, V_from_alu;
  // Flags y último opcode (latched en status_register)
  wire Zf, Nf, Cf, Vf;
  wire [6:0] last_opcode;

  // Operandos a la ALU mediante muxes dedicados
  wire [7:0] opA;
  wire [7:0] opB;

  muxA U_MUXA(
    .A_q(A_q), .B_q(B_q), .imm(imm),
    .sel(selA), .out(opA)
  );
  muxB U_MUXB(
    .A_q(A_q), .B_q(B_q), .imm(imm),
    .sel(selB), .out(opB)
  );

  alu U_ALU(
    .a(opA), .b(opB),
    .op(alu_op),
    .y(alu_y), .z(Z), .n(N),
    .c(C_from_alu), .v(V_from_alu)
  );

  // Data Memory (placeholder: lectura fija de addr 0, sin escrituras)
  wire [7:0] dmem_rdata;
  data_memory U_DMEM(
    .clk(clk),
    .we(1'b0),           // sin escritura aún
    .addr(8'h00),        // dirección fija para no afectar comportamiento
    .wdata(8'h00),
    .rdata(dmem_rdata)
  );

  // Mux de datos (por ahora sólo se selecciona ALU)
  wire [7:0] data_mem_y = dmem_rdata; // conectado pero no usado todavía
  wire [7:0] literal_y  = imm;        // hook futuro
  mux_data U_MUXD(
    .alu_y(alu_y),
    .data_mem_y(data_mem_y),
    .literal_y(literal_y),
    .sel(2'b00), // siempre ALU por ahora
    .out(write_bus)
  );

  // Instancia del status register: captura flags y opcode cuando hay escritura en A o B
  status_register U_SR(
    .clk(clk), .rst(rst),
    .latch_en(weA || weB),
    .opcode_in(opcode),
    .z_in(Z), .n_in(N), .c_in(C_from_alu), .v_in(V_from_alu),
    .last_opcode(last_opcode),
    .z(Zf), .n(Nf), .c(Cf), .v(Vf)
  );

  // ===== Exposición de señales al exterior (para síntesis / integración futura) =====
  assign A_out = A_q;
  assign B_out = B_q;
  assign last_opcode_out = last_opcode;
  assign flags_out = {Zf, Nf, Cf, Vf};

  // ===== Señales de debug para GTKWave =====
  // synthesis translate_off
  wire [6:0]  opcode_dbg = opcode;
  wire [7:0]  imm_dbg    = imm;
  wire [7:0]  A_dbg      = A_q;
  wire [7:0]  B_dbg      = B_q;
  wire [7:0]  Y_dbg          = alu_y;      // salida ALU
  wire [7:0]  WRITE_dbg      = write_bus;  // dato que entra a registros
  wire [7:0]  DMEM_RD_dbg    = dmem_rdata; // lectura data memory
  wire        Z_dbg      = Zf, N_dbg = Nf, C_dbg = Cf, V_dbg = Vf;
  wire [15:0] pc_dbg     = pc_curr;
  wire [6:0]  last_opcode_dbg = last_opcode;
  // synthesis translate_on
endmodule
