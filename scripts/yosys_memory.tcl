#!/usr/bin/env yosys
# yosys_memory.tcl - Flujo simple solicitado
# Objetivo: síntesis mínima del top 'computer' y reporte, preservando memorias (sin convertir a FF+MUX).
# Uso: yosys -c scripts/yosys_memory.tcl

yosys -import
exec mkdir -p out

# Prefijamos con 'yosys' para que Tcl no confunda 'proc' (builtin) con el pass.
yosys read_verilog \
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

yosys hierarchy -check -top computer

yosys proc
yosys opt

# Conservar memories como $mem primitivos
yosys memory -nomap
yosys opt_clean

# Reducción de anchos
yosys wreduce
yosys opt

# Compartir lógica
yosys share -aggressive
yosys opt

# Optimización de árboles de multiplexores
yosys opt_muxtree
yosys opt_reduce
yosys opt_merge
yosys opt

# Mapeo genérico + limpieza
yosys techmap
yosys opt

# Optimización booleana
yosys abc -fast
yosys opt_clean
yosys opt

# Estadísticas (dos veces: directa y con tee a archivo)
yosys stat -top computer
yosys tee -o out/yosys_memory_stat.rpt stat -top computer

# Netlist con memories preservadas
yosys write_verilog -noattr out/computer_memory_preserved.v

yosys log "\nINFO: Flujo simple completado. Reporte: out/yosys_memory_stat.rpt\n"
