// control_unit.v
module control_unit(
  input wire [6:0] opcode,
  // flags
  input wire       zf,
  input wire       nf,
  input wire       cf,
  input wire       vf,

  output reg       weA,
  output reg       weB,
  output reg [1:0] selA,
  output reg [1:0] selB,
  output reg [3:0] alu_op,
  // wb/mem
  output reg [1:0] sel_data,    // 00=ALU,01=DataMem,10=Literal,11=reservado
  output reg       we_mem,      // write enable Data Memory (STORE / futuras ALU->Mem)
  output reg       addr_sel,    // 0=imm (directo), 1=B (indirecto)
  // cmp/branch
  output reg       latch_flags, // fuerza latch de flags sin escribir registros (CMP)
  output reg       branch_taken // salto tomado
);

  // (sin enumeración extendida)

  always @* begin
  // defaults
    weA = 0;
    weB = 0;
    selA = 2'b00;
  selB = 2'b01;
    alu_op = 4'h0;            
    sel_data = 2'b00;
    we_mem = 1'b0;
    addr_sel = 1'b0;
  latch_flags = 1'b0;
  branch_taken = 1'b0;
    
  // decode
    case (opcode)
      // MOV
  7'h00: begin
        alu_op = 4'h1;
        selA = 2'b01;
        weA = 1;
      end
  7'h01: begin
        alu_op = 4'h0;
        selB = 2'b00;
        weB = 1;
      end
  7'h02: begin
        selA = 2'b10;
        weA = 1;      // Y = imm
      end
  7'h03: begin
        alu_op = 4'h1;
        selB = 2'b10;
        weB = 1;
      end

      // ADD
  7'h04: begin
        alu_op = 4'h2;
        selA = 2'b00;
        selB = 2'b01;
        weA = 1;
      end
  7'h05: begin
        alu_op = 4'h2;
        selA = 2'b01;
        selB = 2'b00;
        weB = 1;
      end
  7'h06: begin
        alu_op = 4'h2;
        selA = 2'b00;
        selB = 2'b10;
        weA = 1;
      end
  7'h07: begin
        alu_op = 4'h2;
        selA = 2'b01;
        selB = 2'b10;
        weB = 1;
      end
      // 0x29 MOV A,(B)  -> A = M[B]
  7'h29: begin
        sel_data = 2'b01; weA = 1; addr_sel = 1'b1; // indirecto
      end
      // 0x2A MOV B,(B)  -> B = M[B]
  7'h2A: begin
        sel_data = 2'b01; weB = 1; addr_sel = 1'b1;
      end
      // 0x2B (B),A -> M[B] = A
  7'h2B: begin
        we_mem = 1'b1; addr_sel = 1'b1; alu_op = 4'h0; selA = 2'b00; // PASSA a memoria
      end
      // 0x2C ADD A,(Dir)
  7'h2C: begin
        alu_op = 4'h2; selA=2'b00; selB=2'b11; weA=1; // M[imm] en B
      end
      // 0x2D ADD B,(Dir)
  7'h2D: begin
        alu_op = 4'h2; selA=2'b01; selB=2'b11; weB=1;
      end
      // 0x2E ADD A,(B)
  7'h2E: begin
        alu_op = 4'h2; selA=2'b00; selB=2'b11; weA=1; addr_sel=1'b1;
      end
      // 0x2F (Dir) Mem[Lit]=A+B
  7'h2F: begin
        alu_op = 4'h2; selA=2'b00; selB=2'b01; we_mem=1; // suma regs
      end
      // 0x30 SUB A,(Dir)
  7'h30: begin
        alu_op = 4'h3; selA=2'b00; selB=2'b11; weA=1;
      end
      // 0x31 SUB B,(Dir)
  7'h31: begin
        alu_op = 4'h3; selA=2'b01; selB=2'b11; weB=1;
      end
      // 0x32 SUB A,(B)
  7'h32: begin
        alu_op = 4'h3; selA=2'b00; selB=2'b11; weA=1; addr_sel=1'b1;
      end
      // 0x33 (Dir) Mem[Lit]=A-B
  7'h33: begin
        alu_op = 4'h3; selA=2'b00; selB=2'b01; we_mem=1;
      end
      // 0x34 AND A,(Dir)
  7'h34: begin
        alu_op = 4'h4; selA=2'b00; selB=2'b11; weA=1;
      end
      // 0x35 AND B,(Dir)
  7'h35: begin
        alu_op = 4'h4; selA=2'b01; selB=2'b11; weB=1;
      end
      // 0x36 AND A,(B)
  7'h36: begin
        alu_op = 4'h4; selA=2'b00; selB=2'b11; weA=1; addr_sel=1'b1;
      end
      // 0x37 (Dir) Mem[Lit]=A and B
  7'h37: begin
        alu_op = 4'h4; selA=2'b00; selB=2'b01; we_mem=1;
      end
      // 0x38 OR A,(Dir)
  7'h38: begin
        alu_op = 4'h5; selA=2'b00; selB=2'b11; weA=1;
      end
      // 0x39 OR B,(Dir)
  7'h39: begin
        alu_op = 4'h5; selA=2'b01; selB=2'b11; weB=1;
      end
      // 0x3A OR A,(B)
  7'h3A: begin
        alu_op = 4'h5; selA=2'b00; selB=2'b11; weA=1; addr_sel=1'b1;
      end
      // 0x3B (Dir) Mem[Lit]=A or B
  7'h3B: begin
        alu_op = 4'h5; selA=2'b00; selB=2'b01; we_mem=1;
      end
      // 0x3C NOT (Dir),A  Mem[Lit]=~A
  7'h3C: begin
        alu_op = 4'h7; selA=2'b00; we_mem=1; // NOT A
      end
      // 0x3D NOT (Dir),B  Mem[Lit]=~B
  7'h3D: begin
        alu_op = 4'h7; selA=2'b01; we_mem=1; // NOT B
      end
      // 0x3E NOT (B) Mem[B]=~A
  7'h3E: begin
        alu_op = 4'h7; selA=2'b00; we_mem=1; addr_sel=1'b1;
      end
      // 0x3F XOR A,(Dir)
  7'h3F: begin
        alu_op = 4'h6; selA=2'b00; selB=2'b11; weA=1;
      end
      // 0x40 XOR B,(Dir)
  7'h40: begin
        alu_op = 4'h6; selA=2'b01; selB=2'b11; weB=1;
      end
      // 0x41 XOR A,(B)
  7'h41: begin
        alu_op = 4'h6; selA=2'b00; selB=2'b11; weA=1; addr_sel=1'b1;
      end
      // 0x42 (Dir) Mem[Lit]=A xor B
  7'h42: begin
        alu_op = 4'h6; selA=2'b00; selB=2'b01; we_mem=1;
      end
      // 0x43 SHL (Dir),A Mem[Lit]=A<<1
  7'h43: begin
        alu_op = 4'h8; selA=2'b00; we_mem=1;
      end
      // 0x44 SHL (Dir),B Mem[Lit]=B<<1
  7'h44: begin
        alu_op = 4'h8; selA=2'b01; we_mem=1;
      end
      // 0x45 SHL (B) Mem[B]=A<<1
  7'h45: begin
        alu_op = 4'h8; selA=2'b00; we_mem=1; addr_sel=1'b1;
      end
      // 0x46 SHR (Dir),A Mem[Lit]=A>>1
  7'h46: begin
        alu_op = 4'h9; selA=2'b00; we_mem=1;
      end
      // 0x47 SHR (Dir),B Mem[Lit]=B>>1
  7'h47: begin
        alu_op = 4'h9; selA=2'b01; we_mem=1;
      end
      // 0x48 SHR (B) Mem[B]=A>>1
  7'h48: begin
        alu_op = 4'h9; selA=2'b00; we_mem=1; addr_sel=1'b1;
      end
      // 0x49 INC (Dir) Mem[Lit]=Mem[Lit]+1 (usa b=Mem)
  7'h49: begin
        alu_op = 4'hA; selB=2'b11; we_mem=1; // INC sobre memoria directa
      end
      // 0x4A INC (B) Mem[B]=Mem[B]+1
  7'h4A: begin
        alu_op = 4'hA; selB=2'b11; we_mem=1; addr_sel=1'b1;
      end
      // 0x4B RST (Dir) Mem[Lit]=0 (usar XOR A,A)
  7'h4B: begin
        alu_op = 4'h6; selA=2'b00; selB=2'b00; we_mem=1;
      end
      // 0x4C RST (B) Mem[B]=0
  7'h4C: begin
        alu_op = 4'h6; selA=2'b00; selB=2'b00; we_mem=1; addr_sel=1'b1;
      end
      // ===== CMP (solo flags) =====
      // 0x4D CMP A,B
  7'h4D: begin
        alu_op = 4'h3; selA=2'b00; selB=2'b01; latch_flags=1'b1; end
      // 0x4E CMP A,Lit
  7'h4E: begin
        alu_op = 4'h3; selA=2'b00; selB=2'b10; latch_flags=1'b1; end
      // 0x4F CMP B,Lit (B-Lit) usamos A= B? Necesitamos B-Lit: a=B b=Lit
  7'h4F: begin
        alu_op = 4'h3; selA=2'b01; selB=2'b10; latch_flags=1'b1; end
      // 0x50 CMP A,(Dir)
  7'h50: begin
        alu_op = 4'h3; selA=2'b00; selB=2'b11; latch_flags=1'b1; end
      // 0x51 CMP B,(Dir)
  7'h51: begin
        alu_op = 4'h3; selA=2'b01; selB=2'b11; latch_flags=1'b1; end
      // 0x52 CMP A,(B)
  7'h52: begin
        alu_op = 4'h3; selA=2'b00; selB=2'b11; latch_flags=1'b1; addr_sel=1'b1; end
      // ===== Saltos =====
      // 0x53 JMP
  7'h53: begin branch_taken = 1'b1; end
      // 0x54 JEQ (Z=1)
  7'h54: begin branch_taken = zf; end
      // 0x55 JNE (Z=0)
  7'h55: begin branch_taken = ~zf; end
      // 0x56 JGT (N=0 y Z=0)
  7'h56: begin branch_taken = (~nf) & (~zf); end
      // 0x57 JLT (N=1)
  7'h57: begin branch_taken = nf; end
      // 0x58 JGE (N=0)
  7'h58: begin branch_taken = (~nf); end
      // 0x59 JLE (N=1 o Z=1)
  7'h59: begin branch_taken = nf | zf; end
      // 0x5A JCR (C=1)
  7'h5A: begin branch_taken = cf; end
      // 0x5B JOV (V=1)
  7'h5B: begin branch_taken = vf; end

      // SUB
      7'h08: begin // SUB A,B
        alu_op = 4'h3;
        selA = 2'b00;
        selB = 2'b01;
        weA = 1;
      end
      7'h09: begin // SUB B,A
        alu_op = 4'h3;
        // Necesitamos A - B (no B - A): 'a' debe ser A y 'b' debe ser B
        selA = 2'b00; // A
        selB = 2'b01; // B
        weB = 1;
      end
      7'h0A: begin // SUB A, lit
        alu_op = 4'h3;
        selA = 2'b00;
        selB = 2'b10;
        weA = 1;
      end
      7'h0B: begin // SUB B, lit
        alu_op = 4'h3;
        selA = 2'b01;
        selB = 2'b10;
        weB = 1;
      end

      // AND
      7'h0C: begin // AND A,B
        alu_op = 4'h4;
        selA = 2'b00;
        selB = 2'b01;
        weA = 1;
      end
      7'h0D: begin // AND B,A
        alu_op = 4'h4;
        selA = 2'b01;
        selB = 2'b00;
        weB = 1;
      end
      7'h0E: begin // AND A, lit
        alu_op = 4'h4;
        selA = 2'b00;
        selB = 2'b10;
        weA = 1;
      end
      7'h0F: begin // AND B, lit
        alu_op = 4'h4;
        selA = 2'b01;
        selB = 2'b10;
        weB = 1;
      end

      // OR
      7'h10: begin // OR A,B
        alu_op = 4'h5;
        selA = 2'b00;
        selB = 2'b01;
        weA = 1;
      end
      7'h11: begin // OR B,A
        alu_op = 4'h5;
        selA = 2'b01;
        selB = 2'b00;
        weB = 1;
      end
      7'h12: begin // OR A, lit
        alu_op = 4'h5;
        selA = 2'b00;
        selB = 2'b10;
        weA = 1;
      end
      7'h13: begin // OR B, lit
        alu_op = 4'h5;
        selA = 2'b01;
        selB = 2'b10;
        weB = 1;
      end

      // NOT
      7'h14: begin // NOT A,A  -> A = ~A
        alu_op = 4'h7;
        selA = 2'b00;
        weA = 1;
      end
      7'h15: begin // NOT A,B  -> A = ~B
        alu_op = 4'h7;
        selA = 2'b01;
        weA = 1;
      end
      7'h16: begin // NOT B,A  -> B = ~A
        alu_op = 4'h7;
        selA = 2'b00;
        weB = 1;
      end
      7'h17: begin // NOT B,B  -> B = ~B
        alu_op = 4'h7;
        selA = 2'b01;
        weB = 1;
      end

      // XOR
      7'h18: begin // XOR A,B
        alu_op = 4'h6;
        selA = 2'b00;
        selB = 2'b01;
        weA = 1;
      end
      7'h19: begin // XOR B,A
        alu_op = 4'h6;
        selA = 2'b01;
        selB = 2'b00;
        weB = 1;
      end
      7'h1A: begin // XOR A, lit
        alu_op = 4'h6;
        selA = 2'b00;
        selB = 2'b10;
        weA = 1;
      end
      7'h1B: begin // XOR B, lit
        alu_op = 4'h6;
        selA = 2'b01;
        selB = 2'b10;
        weB = 1;
      end

      // SHL (ALU desplaza 'a')
      7'h1C: begin // SHL A,A
        alu_op = 4'h8;
        selA = 2'b00;
        weA = 1;
      end
      7'h1D: begin // SHL A,B  -> A = B<<1
        alu_op = 4'h8;
        selA = 2'b01;
        weA = 1;
      end
      7'h1E: begin // SHL B,A  -> B = A<<1
        alu_op = 4'h8;
        selA = 2'b00;
        weB = 1;
      end
      7'h1F: begin // SHL B,B
        alu_op = 4'h8;
        selA = 2'b01;
        weB = 1;
      end

      // SHR (ALU desplaza 'a' lógico)
      7'h20: begin // SHR A,A
        alu_op = 4'h9;
        selA = 2'b00;
        weA = 1;
      end
      7'h21: begin // SHR A,B  -> A = B>>1
        alu_op = 4'h9;
        selA = 2'b01;
        weA = 1;
      end
      7'h22: begin // SHR B,A  -> B = A>>1
        alu_op = 4'h9;
        selA = 2'b00;
        weB = 1;
      end
      7'h23: begin // SHR B,B
        alu_op = 4'h9;
        selA = 2'b01;
        weB = 1;
      end

      // INC
      7'h24: begin // INC B
        alu_op = 4'hA;
        selA = 2'b00;
        selB = 2'b01;
        weB = 1;
      end

      // ===== LOAD / STORE (memoria) =====
      // 0x25 LOAD A,[imm]  -> A = M[imm]
      7'h25: begin
        // Fuente write-back: Data Memory
        sel_data = 2'b01; // DataMem -> write_bus
        weA = 1;          // escribimos A
      end
      // 0x26 LOAD B,[imm]  -> B = M[imm]
      7'h26: begin
        sel_data = 2'b01;
        weB = 1;          // escribimos B
      end
      // 0x27 STORE A,[imm] -> M[imm] = A
      7'h27: begin // STORE A,[imm]
        we_mem = 1'b1;    // dato = A (PASSA por defecto)
        alu_op = 4'h0;    // explícito PASSA
        selA = 2'b00;
      end
      7'h28: begin // STORE B,[imm]
        we_mem = 1'b1;    // dato = B (usaremos PASSB)
        alu_op = 4'h1;    // PASSB
        selB = 2'b01;     // asegurar B en puerto 'b'
      end

      // ===== Operaciones con operando en memoria (directo / indirecto) =====
      // ADD con memoria
      // (Se volverán a añadir casos de memoria extendida, CMP y saltos una vez
      // se integre la tabla oficial completa del profesor con un mapeo estable.)

      default: ; // NOP
    endcase
  end
endmodule