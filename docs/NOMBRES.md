## Señales clave (versión simplificada)

| Señal | Significado |
|-------|-------------|
| pc_curr | PC actual |
| ir15 | Instrucción (15 bits) |
| opcode | Código de operación (7) |
| imm | Inmediato (8) |
| A_q / B_q | Registros A y B |
| weA / weB | Enables de escritura A/B |
| selA / selB | Selección operandos ALU (00=A 01=B 10=IMM 11=Mem) |
| alu_op | Operación ALU |
| opA / opB | Operandos efectivos ALU |
| alu_y | Resultado ALU |
| sel_data | Fuente write-back (00 ALU / 01 Mem / 10 Lit) |
| write_bus | Dato a escribir en registro |
| mem_addr | Dirección memoria datos |
| mem_wdata | Dato a memoria |
| dmem_rdata | Lectura memoria datos |
| we_mem | Escritura memoria datos |
| last_opcode | Último opcode latched |
| Zf Nf Cf Vf | Flags latched |
| flags_packed | {Z,N,C,V} |

Resumen flujo: PC -> IMEM -> opcode/imm -> control -> muxes -> ALU -> write_bus -> registros -> status.

