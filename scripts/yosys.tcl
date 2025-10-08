#!/usr/bin/env yosys
# yosys.tcl - Flujo para conteo "real" (memorias mapeadas a FF+MUX) usado por 'make synth'
# Uso: yosys -c scripts/yosys.tcl

yosys -import
exec mkdir -p out

# 1. Leer fuentes
read_verilog \
  src/computer/alu.v \
  src/computer/instruction_memory.v \
  src/computer/data_memory.v \
  src/computer/mux2.v \
  src/computer/mux_data.v \
  src/computer/muxA.v \
  src/computer/muxB.v \
  src/computer/pc.v \
  src/computer/register.v \
  src/computer/status_register.v \
  src/computer/control_unit.v \
  src/computer/computer.v

# 2. Jerarquía y top
hierarchy -top computer -check

# 3. Transformaciones completas (memoria se mapeará a FF + MUX)
proc; opt
fsm; opt
memory  # aquí se expande mem/instruction en FF+MUX
opt
techmap; opt
simplemap; opt_clean
opt_muxtree; opt_reduce; opt_merge; opt_clean; opt

# 4. Estadísticas
stat -top computer
tee -o out/computer.rpt stat -top computer

# 5. Netlist resultante
write_verilog -noattr out/netlist_flat.v

log "\n[INFO] Síntesis completa (memorias mapeadas). Reporte: out/computer.rpt\n"
