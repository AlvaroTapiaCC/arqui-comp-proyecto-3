# Archivos del proyecto
VERILOG_FILES = alu.v instruction_memory.v data_memory.v mux2.v mux_data.v muxA.v muxB.v pc.v register.v status_register.v control_unit.v computer.v
TESTBENCH_FILE = testbench.v
YOSYS_SCRIPT = yosys.tcl

# Rutas de salida
OUT_DIR = out
OUT_FILE = computer
WAVEFORM_FILE = $(OUT_DIR)/dump.vcd

# Target por defecto
all: build run

# Crear directorio de salida
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

# Construcción
build: $(OUT_DIR)
	@echo "Construyendo ejecutable de simulación..."
	iverilog -g2012 -o $(OUT_DIR)/$(OUT_FILE) $(VERILOG_FILES) $(TESTBENCH_FILE)
	@echo "Construcción exitosa. Ejecutable creado en $(OUT_DIR)/$(OUT_FILE)"

# Simulación
run:
	@echo "Ejecutando simulación..."
	vvp $(OUT_DIR)/$(OUT_FILE)

# Formas de onda
wave:
	@echo "Abriendo formas de onda con GTKWave..."
	gtkwave $(WAVEFORM_FILE)

# Síntesis (opcional)
synth: $(OUT_DIR)
	@echo "Iniciando síntesis lógica con Yosys..."
	yosys -c $(YOSYS_SCRIPT)
	@echo "Síntesis completa."

# Limpieza
clean:
	@echo "Limpiando archivos generados..."
	@rm -rf $(OUT_DIR)
	@rm -f yosys.log
	@echo "Limpieza completa."

.PHONY: all build run wave synth clean
