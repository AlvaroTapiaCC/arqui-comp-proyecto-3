# Nombres de Señales / Variables Clave del Proyecto

Este documento sirve como referencia rápida para entender qué representa cada señal en el diseño actual del computador 8‑bit (ISA 7+8). Se divide en:

1. Lista corta esencial (lo mínimo que debes recordar).
2. Listado ampliado agrupado por módulo / función.
3. Aliases de debug y futuras señales planificadas.

---

## 1. Esenciales (memorización rápida)

| Señal | Dónde | Ancho | Significado breve |
|-------|-------|-------|-------------------|
| `pc_curr` | computer | 16 | Program Counter actual |
| `pc_next` | computer | 16 | PC + 1 (siguiente instrucción) |
| `ir15` | computer | 15 | Palabra leída de memoria de instrucciones (bit 15 no usado) |
| `opcode` | computer | 7 | Código de operación (bits [14:8] de `ir15`) |
| `imm` | computer | 8 | Inmediato literal (bits [7:0] de `ir15`) |
| `A_q` / `B_q` | computer | 8 | Registros generales A y B |
| `weA` / `weB` | control_unit -> computer | 1 | Enables de escritura para A / B |
| `selA` / `selB` | control_unit -> muxA/muxB | 2 | Selección operandos ALU (00=A,01=B,10=IMM,11=DMEM futuro) |
| `alu_op` | control_unit -> alu | 4 | Selección de operación ALU |
| `opA` / `opB` | computer | 8 | Operandos efectivos que entran a la ALU |
| `alu_y` | alu -> computer | 8 | Resultado de la ALU antes de write‑back |
| `write_bus` | computer | 8 | Dato que se escribe en A o B (salida de `mux_data`) |
| `sel_data` | control_unit -> mux_data | 2 | Fuente write-back (00=ALU,01=DMEM,10=Literal,11=reservado) |
| `we_mem` | control_unit -> data_memory | 1 | Habilita escritura en Data Memory |
| `mem_addr` | computer | 8 | Dirección efectiva a Data Memory (hoy = `imm`) |
| `mem_wdata` | computer | 8 | Dato que se escribe en memoria (A o B / futuro ALU) |
| `dmem_rdata` | data_memory -> computer | 8 | Lectura desde Data Memory |
| `last_opcode` | status_register | 7 | Último opcode que generó escritura en A o B |
| `Zf Nf Cf Vf` | status_register | 1 cada | Flags latched (Zero, Negative, Carry, Overflow) |
| `flags_packed` | status_register | 4 | Empaquetado `{Z,N,C,V}` |

---

## 2. Listado ampliado por categoría

### 2.1 Fetch / Decode
- `pc_curr` : Contador de programa actual.
- `pc_next` : Valor incrementado (suma 1) usado para alimentar al PC.
- `ir15` : 15 bits significativos de la instrucción (bit 15 no utilizado actualmente).
- `opcode` : Bits [14:8] de `ir15`.
- `imm` : Bits [7:0] de `ir15` (literal inmediato o dirección futura para LOAD/STORE).

### 2.2 Registros y Write-Back
- `A_q`, `B_q` : Contenido actual de los registros A y B.
- `weA`, `weB` : Enables de escritura sobre A y B.
- `write_bus` : Bus común de escritura hacia A o B (selección posterior de ALU / memoria / literal).

### 2.3 Control
- `selA`, `selB` : Mux selects para operandos ALU (00=A, 01=B, 10=IMM, 11=DMEM planeado).
- `alu_op` : Código de operación interno de la ALU.
- `sel_data` : Fuente de `write_bus` (implementado).
- `we_mem` : Enable de escritura a Data Memory (implementado).
- (Futuro) `addr_sel` : 0=usar `imm` como dirección, 1=usar registro B (indirecto).
- (Futuro) `latch_flags` : Habilita captura de flags incluso sin escritura de registros (para CMP / test).
- (Futuro) `branch_taken` : Indica que próximo PC será un target de salto.
- (Futuro) `branch_target` : Dirección (zero-extend `imm`) para actualizar PC en saltos.

### 2.4 Operandos / Muxes
- `opA`, `opB` : Salidas de `muxA` y `muxB` que entran a la ALU.
- `literal_y` : Alias interno que representa el inmediato preparado para el mux de datos.
- `data_mem_y` : Dato leído desde memoria de datos re-enrutable a `write_bus`.

### 2.5 ALU
- Entradas: `a`, `b`, `op`.
- Salidas combinacionales: `y` (resultado), `z` (y==0), `n` (bit 7 de y), `c`, `v` (según operación).
- Interno: `tmp` (9 bits para detectar carry / overflow en ADD/SUB/INC).
- Operaciones actuales (op):
	- 0 PASSA, 1 PASSB, 2 ADD, 3 SUB, 4 AND, 5 OR, 6 XOR, 7 NOT(A), 8 SHL(A), 9 SHR(A), A INC(B).

### 2.6 Memoria de Datos
- `mem_addr` : Dirección efectiva (hoy inmediato; futuro: mux con B).
- `mem_wdata` : Dato a escribir (por ahora A o B seleccionados en top; futuro: salida ALU genérica).
- `dmem_rdata` : Lectura combinacional de Data Memory.
- `we_mem` : Señal global de escritura habilitada desde control.
- (Futuro) `addr_sel` : Selección de fuente de dirección (imm vs B).
- (Futuro) `mem_operand` : Valor leído usado como operando ALU cuando `selB=11`.

### 2.7 Flags y Status
- Señales crudas desde ALU: `Z`, `N`, `C_from_alu`, `V_from_alu`.
- Señales latched: `Zf`, `Nf`, `Cf`, `Vf` (salida del status_register).
- `flags_packed` / `flags_packed_dbg` : Empaquetado `{Z,N,C,V}`.
- `last_opcode` : Último opcode latched cuando ocurre escritura en A o B.
- `latch_en` (status_register) : Enable (weA || weB) que dispara captura de flags y opcode.

### 2.8 Debug (aliases dentro de `translate_off`)
- `opcode_dbg`, `imm_dbg` : Copias de opcode e inmediato.
- `A_dbg`, `B_dbg` : Contenido de registros.
- `Y_dbg` : Resultado ALU.
- `WRITE_dbg` : Bus de escritura.
- `DMEM_RD_dbg` : Lectura de memoria de datos.
- `pc_dbg` / `dbg_rPC` : Program counter.
- `dbg_im_word` : Palabra de instrucción completa (15 bits usados).
- `dbg_ir_opcode`, `dbg_ir_imm` : Campos de la instrucción.
- `dbg_rA`, `dbg_rB`, `dbg_wb_data`, `dbg_dm_rdata`, `dbg_alu_y` : Variantes uniformes prefijo `dbg_`.
- `dbg_flags_packed` : Flags empaquetados.
- `dbg_last_opcode` : Último opcode latched.

### 2.9 Puertos de Módulos (resumen)
#### `computer`
- Entradas: `clk`, `rst`.
- Salidas: `A_out`, `B_out`, `last_opcode_out`, `flags_out` (orden `{Z,N,C,V}`).

#### `control_unit`
- Entrada: `opcode`.
- Salidas: `weA`, `weB`, `selA[1:0]`, `selB[1:0]`, `alu_op[3:0]`.

#### `alu`
- Entradas: `a[7:0]`, `b[7:0]`, `op[3:0]`.
- Salidas: `y[7:0]`, `z`, `n`, `c`, `v`.

#### `status_register`
- Entradas: `clk`, `rst`, `latch_en`, `opcode_in`, `z_in`, `n_in`, `c_in`, `v_in`.
- Salidas: `last_opcode`, `z`, `n`, `c`, `v`, `flags_packed`.

#### `data_memory` (actual)
- Entradas: `clk`, `we`, `addr[7:0]`, `wdata[7:0]`.
- Salida: `rdata[7:0]`.

#### `muxA` / `muxB`
- Entradas: `A_q`, `B_q`, `imm`, `sel[1:0]`.
- Salida: `out` (operando a ALU).

#### `mux_data`
- Entradas: `alu_y`, `data_mem_y`, `literal_y`, `sel[1:0]`.
- Salida: `out` (`write_bus`).

### 2.10 Convenciones de selección
- `selA` / `selB`: 00=A, 01=B, 10=IMM, 11=DMEM (planeado para operandos desde memoria).
- `sel_data`: 00=ALU, 01=Data Memory, 10=Literal, 11=reservado.
- (Futuro) `addr_sel`: 0=imm, 1=B.
- (Futuro) `latch_flags`: 1=latch flags (instrucciones tipo CMP / test).

---

## 3. Futura expansión (placeholders)
- Modo indirecto: `addr_sel` para direccionar con B.
- Operando memoria directo: `selB=11` para inyectar `dmem_rdata` a la ALU.
- Instrucción CMP: requiere `latch_flags` sin `weA/weB`.
- Saltos: `branch_taken`, `branch_target` y multiplexor de PC.
- Mem ops avanzadas: mem write usando `alu_y` (unificar `mem_wdata` = `alu_y`).
- Op CLEAR / ZERO para RST (o reutilizar literal 0 si se fuerza a nivel de programa).

---

## 4. Notas rápidas de lectura
- Si sólo quieres seguir la ejecución: mira `pc_curr`, `opcode`, `A_q`, `B_q`, `alu_y`, `flags_packed`.
- Para depurar operandos: `opA` y `opB` muestran exactamente lo que ve la ALU.
- Para verificar control: correlaciona `opcode` con `weA/weB`, `selA/selB`, `alu_op`.
- Para futuras instrucciones de memoria: aparecerán nuevas transiciones en `write_bus` que no provienen de `alu_y`.

---

## 5. Resumen ultra-corto
PC -> Fetch (`ir15`) -> Decode (`opcode`/`imm` + control_unit) -> Operandos (`opA/opB`) -> ALU (`alu_y` + flags) -> Write-back (`write_bus` -> A/B) -> Status (`last_opcode`, flags latched).

---

Si necesitas añadir nuevas señales, sigue el patrón: prefijos `dbg_` para alias de depuración, y documenta aquí sólo si son estructurales o afectan flujo de datos.

