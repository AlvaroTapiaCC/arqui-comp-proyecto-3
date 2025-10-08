#!/usr/bin/env yosys
# Script Tcl que usa comandos de Yosys. Mantiene extensión .tcl pero
# se asegura de importar el namespace de Yosys para poder llamar
# 'read_verilog', 'synth', etc. sin el error "invalid command name".

# Importa los comandos de Yosys al intérprete Tcl
yosys -import

# Asegura directorio de salida
exec mkdir -p out

# Lee todos los módulos necesarios (ajusta la lista si cambias archivos)
read_verilog \
	src/computer/alu.v \
	src/computer/control_unit.v \
	src/computer/status_register.v \
	src/computer/muxA.v src/computer/muxB.v src/computer/mux_data.v src/computer/mux2.v \
	src/computer/data_memory.v \
	src/computer/pc.v src/computer/register.v \
	src/computer/instruction_memory.v \
	src/computer/computer.v

# Establece y verifica jerarquía
hierarchy -top computer
check

# Síntesis genérica
synth -top computer

# Netlist resultante sin atributos de simulación
write_verilog -noattr out/netlist.v

# Estadísticas
stat

# Reporte a archivo
tee -o out/computer.rpt stat

# (Opcional) estadísticas a nivel plano (descomenta si quieres ver recursos totales)
# flatten
# stat

puts {YOSYS TCL: Síntesis finalizada. Netlist en out/netlist.v, reporte en out/computer.rpt}