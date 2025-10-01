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
  reg        weA, weB;
  wire [7:0] Y;

  register #(8) U_RA(.clk(clk), .rst(rst), .we(weA), .d(Y), .q(A_q));
  register #(8) U_RB(.clk(clk), .rst(rst), .we(weB), .d(Y), .q(B_q));

  // ===== Control =====
  // selX: 00->A, 01->B, 10->IMM (para alimentar 'a' o 'b' según operación)
  reg [1:0] selA, selB;
  reg [3:0] alu_op;

  // Banderas
  wire Z, N, C_from_alu, V_from_alu;
  reg  Zf, Nf, Cf, Vf;

  // Evita 'x' iniciales en flags
  initial begin Zf=1'b0; Nf=1'b0; Cf=1'b0; Vf=1'b0; end

  // Operandos a la ALU
  wire [7:0] opA = (selA==2'b00) ? A_q : (selA==2'b01 ? B_q : imm);
  wire [7:0] opB = (selB==2'b00) ? A_q : (selB==2'b01 ? B_q : imm);

  alu U_ALU(.a(opA), .b(opB), .op(alu_op), .y(Y), .z(Z), .n(N), .c(C_from_alu), .v(V_from_alu));

  // Decodificación (TODAS las básicas)
  always @* begin
    // defaults
    weA=0; weB=0;
    selA=2'b00; selB=2'b01; // por defecto: a=A, b=B
    alu_op=4'h0;            // PASSA

    case (opcode)
      // MOV
      7'h00: begin // MOV A,B
        alu_op=4'h1; selA=2'b01; weA=1;
      end
      7'h01: begin // MOV B,A
        alu_op=4'h0; selB=2'b00; weB=1;
      end
      7'h02: begin // MOV A, lit
        selA=2'b10; weA=1;      // Y = imm
      end
      7'h03: begin // MOV B, lit
        selB=2'b10; weB=1;      // Y = imm (vía PASSB si quisieras, aquí sirve PASSA con a=imm)
      end

      // ADD
      7'h04: begin // ADD A,B
        alu_op=4'h2; selA=2'b00; selB=2'b01; weA=1;
      end
      7'h05: begin // ADD B,A
        alu_op=4'h2; selA=2'b01; selB=2'b00; weB=1;
      end
      7'h06: begin // ADD A, lit
        alu_op=4'h2; selA=2'b00; selB=2'b10; weA=1;
      end
      7'h07: begin // ADD B, lit
        alu_op=4'h2; selA=2'b01; selB=2'b10; weB=1;
      end

      // SUB
      7'h08: begin // SUB A,B
        alu_op=4'h3; selA=2'b00; selB=2'b01; weA=1;
      end
      7'h09: begin // SUB B,A
        alu_op=4'h3; selA=2'b01; selB=2'b00; weB=1;
      end
      7'h0A: begin // SUB A, lit
        alu_op=4'h3; selA=2'b00; selB=2'b10; weA=1;
      end
      7'h0B: begin // SUB B, lit
        alu_op=4'h3; selA=2'b01; selB=2'b10; weB=1;
      end

      // AND
      7'h0C: begin // AND A,B
        alu_op=4'h4; selA=2'b00; selB=2'b01; weA=1;
      end
      7'h0D: begin // AND B,A
        alu_op=4'h4; selA=2'b01; selB=2'b00; weB=1;
      end
      7'h0E: begin // AND A, lit
        alu_op=4'h4; selA=2'b00; selB=2'b10; weA=1;
      end
      7'h0F: begin // AND B, lit
        alu_op=4'h4; selA=2'b01; selB=2'b10; weB=1;
      end

      // OR
      7'h10: begin // OR A,B
        alu_op=4'h5; selA=2'b00; selB=2'b01; weA=1;
      end
      7'h11: begin // OR B,A
        alu_op=4'h5; selA=2'b01; selB=2'b00; weB=1;
      end
      7'h12: begin // OR A, lit
        alu_op=4'h5; selA=2'b00; selB=2'b10; weA=1;
      end
      7'h13: begin // OR B, lit
        alu_op=4'h5; selA=2'b01; selB=2'b10; weB=1;
      end

      // NOT
      7'h14: begin // NOT A,A  -> A = ~A
        alu_op=4'h7; selA=2'b00; weA=1;
      end
      7'h15: begin // NOT A,B  -> A = ~B
        alu_op=4'h7; selA=2'b01; weA=1;
      end
      7'h16: begin // NOT B,A  -> B = ~A
        alu_op=4'h7; selA=2'b00; weB=1;
      end
      7'h17: begin // NOT B,B  -> B = ~B
        alu_op=4'h7; selA=2'b01; weB=1;
      end

      // XOR
      7'h18: begin // XOR A,B
        alu_op=4'h6; selA=2'b00; selB=2'b01; weA=1;
      end
      7'h19: begin // XOR B,A
        alu_op=4'h6; selA=2'b01; selB=2'b00; weB=1;
      end
      7'h1A: begin // XOR A, lit
        alu_op=4'h6; selA=2'b00; selB=2'b10; weA=1;
      end
      7'h1B: begin // XOR B, lit
        alu_op=4'h6; selA=2'b01; selB=2'b10; weB=1;
      end

      // SHL (ALU desplaza 'a')
      7'h1C: begin // SHL A,A
        alu_op=4'h8; selA=2'b00; weA=1;
      end
      7'h1D: begin // SHL A,B  -> A = B<<1
        alu_op=4'h8; selA=2'b01; weA=1;
      end
      7'h1E: begin // SHL B,A  -> B = A<<1
        alu_op=4'h8; selA=2'b00; weB=1;
      end
      7'h1F: begin // SHL B,B
        alu_op=4'h8; selA=2'b01; weB=1;
      end

      // SHR (ALU desplaza 'a' lógico)
      7'h20: begin // SHR A,A
        alu_op=4'h9; selA=2'b00; weA=1;
      end
      7'h21: begin // SHR A,B  -> A = B>>1
        alu_op=4'h9; selA=2'b01; weA=1;
      end
      7'h22: begin // SHR B,A  -> B = A>>1
        alu_op=4'h9; selA=2'b00; weB=1;
      end
      7'h23: begin // SHR B,B
        alu_op=4'h9; selA=2'b01; weB=1;
      end

      // INC
      7'h24: begin // INC B
        alu_op=4'hA; selA=2'b00; selB=2'b01; weB=1;
      end

      default: ; // NOP
    endcase
  end

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
