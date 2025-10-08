// computer.v  -- ISA 7+8 (15 bits) | A/B de 8 bits | Básicas completas
module computer(
  input  wire clk,
  input  wire rst,
  output wire [7:0] A_out,
  output wire [7:0] B_out,
  output wire [6:0] last_opcode_out,
  output wire [3:0] flags_out
);
  // Fetch/PC
  wire [15:0] pc_curr;
  wire [15:0] pc_seq_next = pc_curr + 16'd1;
  reg  [15:0] pc_next;
  wire [14:0] ir15;

  pc U_PC(.clk(clk), .rst(rst), .next_pc(pc_next), .pc(pc_curr));
  instruction_memory U_IM(.address(pc_curr), .out(ir15));

  // Campos instrucción
  wire [6:0] opcode = ir15[14:8];
  wire [7:0] imm    = ir15[7:0];

  // Registros A/B y bus
  wire [7:0] A_q, B_q;
  wire       weA, weB;
  wire [7:0] alu_y;                // alu_y salida cruda ALU
  wire [7:0] write_bus;            // wb_data

  register #(8) U_RA(.clk(clk), .rst(rst), .we(weA), .d(write_bus), .q(A_q));
  register #(8) U_RB(.clk(clk), .rst(rst), .we(weB), .d(write_bus), .q(B_q));

  // Control
  wire [1:0] selA, selB;
  wire [3:0] alu_op;
  wire [1:0] sel_data;
  wire       we_mem;
  wire       addr_sel;
  wire       latch_flags;
  wire       branch_taken;
  wire [1:0] mem_wdata_sel; // 00=ALU 01=A 10=B

  control_unit CU (
    .opcode(opcode),
    .zf(Zf), .nf(Nf), .cf(Cf), .vf(Vf),
    .weA(weA), .weB(weB),
    .selA(selA), .selB(selB),
    .alu_op(alu_op),
    .sel_data(sel_data),
    .we_mem(we_mem),
    .addr_sel(addr_sel),
    .mem_wdata_sel(mem_wdata_sel),
    .latch_flags(latch_flags),
    .branch_taken(branch_taken)
  );

  wire Z, N, C_from_alu, V_from_alu;  // flags ALU
  wire Zf, Nf, Cf, Vf;                // flags latched
  wire [6:0] last_opcode;

  wire [7:0] opA;
  wire [7:0] opB;

  muxA U_MUXA(
    .A_q(A_q), .B_q(B_q), .imm(imm),
    .sel(selA), .out(opA)
  );
  muxB U_MUXB(
    .A_q(A_q), .B_q(B_q), .imm(imm), .dmem_rdata(dmem_rdata),
    .sel(selB), .out(opB)
  );

  alu U_ALU(
    .a(opA), .b(opB),
    .op(alu_op),
    .y(alu_y), .z(Z), .n(N),
    .c(C_from_alu), .v(V_from_alu)
  );

  // Data Memory
  wire [7:0] dmem_rdata;
  wire [7:0] mem_addr = (addr_sel) ? B_q : imm;
  reg  [7:0] mem_wdata;
  always @* begin
    case (mem_wdata_sel)
      2'b01: mem_wdata = A_q;
      2'b10: mem_wdata = B_q;
      default: mem_wdata = alu_y; // 00 ALU (suma, AND, etc hacia memoria)
    endcase
  end

  data_memory DM(
    .clk(clk),
    .we(we_mem),
    .addr(mem_addr),
    .wdata(mem_wdata),
    .rdata(dmem_rdata)
  );

  wire [7:0] data_mem_y = dmem_rdata;
  wire [7:0] literal_y  = imm;
  mux_data U_MUXD(
    .alu_y(alu_y),
    .data_mem_y(data_mem_y),
    .literal_y(literal_y),
    .sel(sel_data),
    .out(write_bus)
  );

  // Status register
  wire [3:0] flags_packed;
  status_register U_SR(
    .clk(clk), .rst(rst),
    .latch_en((weA || weB) || latch_flags),
    .opcode_in(opcode),
    .z_in(Z), .n_in(N), .c_in(C_from_alu), .v_in(V_from_alu),
    .last_opcode(last_opcode),
    .z(Zf), .n(Nf), .c(Cf), .v(Vf),
    .flags_packed(flags_packed)
  );

  wire [15:0] branch_target = {8'h00, imm};
  always @* begin
    if (branch_taken) pc_next = branch_target; else pc_next = pc_seq_next;
  end

  // Salidas
  assign A_out = A_q;
  assign B_out = B_q;
  assign last_opcode_out = last_opcode;
  assign flags_out = {Zf, Nf, Cf, Vf}; // mismo orden (Z,N,C,V)
  // (sin señales de debug internas)
endmodule
