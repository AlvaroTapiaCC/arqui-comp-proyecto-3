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
  output reg [1:0] sel_data,       // 00=ALU,01=DataMem,10=Literal
  output reg       we_mem,         // write enable Data Memory
  output reg       addr_sel,       // 0=imm, 1=B
  output reg [1:0] mem_wdata_sel,  // 00=ALU,01=A,02=B
  // cmp/branch
  output reg       latch_flags,
  output reg       branch_taken
);

  // (sin enumeración extendida)

  always @* begin
    // defaults
    weA = 1'b0; weB = 1'b0;
    selA = 2'b00; selB = 2'b01; // opA=A, opB=B
    alu_op = 4'h0;              // PASSA
    sel_data = 2'b00;           // ALU -> write_bus
    we_mem = 1'b0; addr_sel = 1'b0;
    mem_wdata_sel = 2'b00;      // ALU by default
    latch_flags = 1'b0; branch_taken = 1'b0;

    // -------- Grupo compacto MOV/ALU básicos (rangos contiguos) --------
    // Rango familia: opcode[6:2]
    // 00000 MOV (00-03)
    // 00001 ADD (04-07)
    // 00010 SUB (08-0B)
    // 00011 AND (0C-0F)
    // 00100 OR  (10-13)
    // 00101 NOT (14-17) (usa sólo 'a')
    // 00110 XOR (18-1B)
    // 00111 SHL (1C-1F) (usa sólo 'a')
    // 01000 SHR (20-23) (usa sólo 'a')
    // 01001 INC (24)

    case (opcode[6:2])
      5'b00000: begin // MOV variantes
        // variantes en opcode[1:0]
        case (opcode[1:0])
          2'b00: begin // MOV A,B
            alu_op = 4'h1; // PASSB
            weA = 1'b1;
          end
          2'b01: begin // MOV B,A
            // PASSA ya por defecto
            weB = 1'b1;
          end
          2'b10: begin // MOV A,lit
            selA = 2'b10; // imm
            weA = 1'b1;
          end
          2'b11: begin // MOV B,lit
            selA = 2'b10; // imm en 'a'
            weB = 1'b1;
          end
        endcase
      end
      5'b00001: begin // ADD
        alu_op = 4'h2;
        case (opcode[1:0])
          2'b00: begin selA=2'b00; selB=2'b01; weA=1; end // A+=B
          2'b01: begin selA=2'b01; selB=2'b00; weB=1; end // B+=A
          2'b10: begin selA=2'b00; selB=2'b10; weA=1; end // A+=lit
          2'b11: begin selA=2'b01; selB=2'b10; weB=1; end // B+=lit
        endcase
      end
      5'b00010: begin // SUB
        alu_op = 4'h3;
        case (opcode[1:0])
          2'b00: begin selA=2'b00; selB=2'b01; weA=1; end // A-=B
          2'b01: begin selA=2'b00; selB=2'b01; weB=1; end // B=A-B
          2'b10: begin selA=2'b00; selB=2'b10; weA=1; end // A-=lit
          2'b11: begin selA=2'b01; selB=2'b10; weB=1; end // B-=lit
        endcase
      end
      5'b00011: begin // AND
        alu_op = 4'h4;
        case (opcode[1:0])
          2'b00: begin selA=2'b00; selB=2'b01; weA=1; end
          2'b01: begin selA=2'b01; selB=2'b00; weB=1; end
          2'b10: begin selA=2'b00; selB=2'b10; weA=1; end
          2'b11: begin selA=2'b01; selB=2'b10; weB=1; end
        endcase
      end
      5'b00100: begin // OR
        alu_op = 4'h5;
        case (opcode[1:0])
          2'b00: begin selA=2'b00; selB=2'b01; weA=1; end
          2'b01: begin selA=2'b01; selB=2'b00; weB=1; end
          2'b10: begin selA=2'b00; selB=2'b10; weA=1; end
          2'b11: begin selA=2'b01; selB=2'b10; weB=1; end
        endcase
      end
      5'b00101: begin // NOT (usa sólo selA; b ignorado)
        alu_op = 4'h7;
        case (opcode[1:0])
          2'b00: begin selA=2'b00; weA=1; end // A=~A
          2'b01: begin selA=2'b01; weA=1; end // A=~B
          2'b10: begin selA=2'b00; weB=1; end // B=~A
          2'b11: begin selA=2'b01; weB=1; end // B=~B
        endcase
      end
      5'b00110: begin // XOR
        alu_op = 4'h6;
        case (opcode[1:0])
          2'b00: begin selA=2'b00; selB=2'b01; weA=1; end
          2'b01: begin selA=2'b01; selB=2'b00; weB=1; end
          2'b10: begin selA=2'b00; selB=2'b10; weA=1; end
          2'b11: begin selA=2'b01; selB=2'b10; weB=1; end
        endcase
      end
      5'b00111: begin // SHL
        alu_op = 4'h8;
        case (opcode[1:0])
          2'b00: begin selA=2'b00; weA=1; end // A=A<<1
          2'b01: begin selA=2'b01; weA=1; end // A=B<<1
          2'b10: begin selA=2'b00; weB=1; end // B=A<<1
          2'b11: begin selA=2'b01; weB=1; end // B=B<<1
        endcase
      end
      5'b01000: begin // SHR
        alu_op = 4'h9;
        case (opcode[1:0])
          2'b00: begin selA=2'b00; weA=1; end // A=A>>1
          2'b01: begin selA=2'b01; weA=1; end // A=B>>1
          2'b10: begin selA=2'b00; weB=1; end // B=A>>1
          2'b11: begin selA=2'b01; weB=1; end // B=B>>1
        endcase
      end
      5'b01001: begin // 0x24 INC B
        if (opcode[1:0]==2'b00) begin
          alu_op = 4'hA; selA=2'b00; selB=2'b01; weB=1; // coincide con diseño previo
        end
      end
      default: ; // otros rangos fuera de básicos
    endcase

    // -------- Instrucciones fuera de los rangos compactados --------
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
  // 0x29 MOV A,(B)
  7'h29: begin sel_data=2'b01; weA=1; addr_sel=1'b1; end
  // 0x2A MOV B,(B)
  7'h2A: begin sel_data=2'b01; weB=1; addr_sel=1'b1; end
  // 0x2B (B),A
  7'h2B: begin we_mem=1'b1; addr_sel=1'b1; mem_wdata_sel=2'b01; end
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
      7'h2F: begin alu_op = 4'h2; selA=2'b00; selB=2'b01; we_mem=1; end
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
      7'h33: begin alu_op = 4'h3; selA=2'b00; selB=2'b01; we_mem=1; end
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
      7'h37: begin alu_op = 4'h4; selA=2'b00; selB=2'b01; we_mem=1; end
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
      7'h3B: begin alu_op = 4'h5; selA=2'b00; selB=2'b01; we_mem=1; end
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
      7'h42: begin alu_op = 4'h6; selA=2'b00; selB=2'b01; we_mem=1; end
      // 0x43 SHL (Dir),A Mem[Lit]=A<<1
      7'h43: begin alu_op = 4'h8; selA=2'b00; we_mem=1; end
      // 0x44 SHL (Dir),B Mem[Lit]=B<<1
      7'h44: begin alu_op = 4'h8; selA=2'b01; we_mem=1; end
      // 0x45 SHL (B) Mem[B]=A<<1
      7'h45: begin alu_op = 4'h8; selA=2'b00; we_mem=1; addr_sel=1'b1; end
      // 0x46 SHR (Dir),A Mem[Lit]=A>>1
      7'h46: begin alu_op = 4'h9; selA=2'b00; we_mem=1; end
      // 0x47 SHR (Dir),B Mem[Lit]=B>>1
      7'h47: begin alu_op = 4'h9; selA=2'b01; we_mem=1; end
      // 0x48 SHR (B) Mem[B]=A>>1
      7'h48: begin alu_op = 4'h9; selA=2'b00; we_mem=1; addr_sel=1'b1; end
      // 0x49 INC (Dir) Mem[Lit]=Mem[Lit]+1 (usa b=Mem)
      7'h49: begin alu_op = 4'hA; selB=2'b11; we_mem=1; end
      // 0x4A INC (B) Mem[B]=Mem[B]+1
      7'h4A: begin alu_op = 4'hA; selB=2'b11; we_mem=1; addr_sel=1'b1; end
      // 0x4B RST (Dir) Mem[Lit]=0 (usar XOR A,A)
      7'h4B: begin alu_op = 4'h6; selA=2'b00; selB=2'b00; we_mem=1; end
      // 0x4C RST (B) Mem[B]=0
      7'h4C: begin alu_op = 4'h6; selA=2'b00; selB=2'b00; we_mem=1; addr_sel=1'b1; end
      // ===== CMP (solo flags) =====
      // 0x4D CMP A,B
      7'h4D: begin alu_op = 4'h3; selA=2'b00; selB=2'b01; latch_flags=1'b1; end
      // 0x4E CMP A,Lit
      7'h4E: begin alu_op = 4'h3; selA=2'b00; selB=2'b10; latch_flags=1'b1; end
      // 0x4F CMP B,Lit (B-Lit) usamos A= B? Necesitamos B-Lit: a=B b=Lit
      7'h4F: begin alu_op = 4'h3; selA=2'b01; selB=2'b10; latch_flags=1'b1; end
      // 0x50 CMP A,(Dir)
      7'h50: begin alu_op = 4'h3; selA=2'b00; selB=2'b11; latch_flags=1'b1; end
      // 0x51 CMP B,(Dir)
      7'h51: begin alu_op = 4'h3; selA=2'b01; selB=2'b11; latch_flags=1'b1; end
      // 0x52 CMP A,(B)
      7'h52: begin alu_op = 4'h3; selA=2'b00; selB=2'b11; latch_flags=1'b1; addr_sel=1'b1; end
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
      // LOAD / STORE
      7'h25: begin sel_data=2'b01; weA=1; end        // LOAD A,[imm]
      7'h26: begin sel_data=2'b01; weB=1; end        // LOAD B,[imm]
      7'h27: begin we_mem=1'b1; mem_wdata_sel=2'b01; end // STORE A,[imm]
      7'h28: begin we_mem=1'b1; mem_wdata_sel=2'b10; end // STORE B,[imm]
      default: ;
    endcase
  end
endmodule