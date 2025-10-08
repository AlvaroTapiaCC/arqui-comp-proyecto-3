SRC_DIR       = src/computer
TESTS_DIR     = src/tests
DATA_DIR      = data
SCRIPT_DIR    = scripts

RTL_FILES = $(SRC_DIR)/alu.v \
            $(SRC_DIR)/instruction_memory.v \
            $(SRC_DIR)/data_memory.v \
            $(SRC_DIR)/mux2.v \
            $(SRC_DIR)/mux_data.v \
            $(SRC_DIR)/muxA.v \
            $(SRC_DIR)/muxB.v \
            $(SRC_DIR)/pc.v \
            $(SRC_DIR)/register.v \
            $(SRC_DIR)/status_register.v \
            $(SRC_DIR)/control_unit.v \
            $(SRC_DIR)/computer.v

# Elegir testbench: make TEST=testbench_memory o deja por defecto testbench
TEST ?= testbench_memory
TESTBENCH_FILE = $(TESTS_DIR)/$(TEST).v

YOSYS_SCRIPT = $(SCRIPT_DIR)/yosys_memory.tcl

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
	@echo "Construyendo ejecutable de simulación con testbench: $(TEST) ..."
	iverilog -g2012 -o $(OUT_DIR)/$(OUT_FILE) $(RTL_FILES) $(TESTBENCH_FILE)
	@echo "Construcción exitosa. Ejecutable creado en $(OUT_DIR)/$(OUT_FILE)"

# Simulación
run:
	@echo "Ejecutando simulación (testbench: $(TEST))..."
	vvp $(OUT_DIR)/$(OUT_FILE)

# Atajo: ejecutar memoria directamente
memtest: clean
	$(MAKE) TEST=testbench_memory build run

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
