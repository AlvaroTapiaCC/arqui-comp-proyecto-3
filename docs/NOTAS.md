# Apuntes sobre el Funcionamiento de un Computador y este Proyecto 8-bit

## 1. Computador simple (visión general sin adornos)
Un computador digital básico ejecuta una secuencia de instrucciones almacenadas en memoria. Cada ciclo sigue (idealmente) este flujo:
1. Fetch: Obtener la instrucción desde memoria de instrucciones usando el Contador de Programa (PC) como dirección.
2. Decode: Interpretar el campo de opcode y decidir qué operación hacer y qué registros o datos usar.
3. Execute: La ALU (Unidad Aritmético‑Lógica) o algún otro bloque realiza la operación (suma, AND, desplazamiento, etc.).
4. Write‑back: El resultado (si corresponde) se escribe de vuelta en un registro o memoria.
5. Update PC: Normalmente PC = PC + 1 (o salta a otra dirección para ramas/llamadas futuras).

Componentes típicos:
- PC (Program Counter): Lleva la dirección de la próxima instrucción.
- Memoria de instrucciones: Almacena programa (código). Es de solo lectura en este modelo simple.
- Registros: Pequeño almacenamiento rápido (A, B, etc.) para operandos y resultados.
- ALU: Realiza operaciones aritméticas y lógicas sobre operandos.
- Unidad de Control: A partir del opcode genera señales (qué escribir, qué multiplexor seleccionar, qué operación ALU, etc.).
- Flags/Status: Bits que describen el resultado (Zero, Negativo, Carry, Overflow). Permiten decisiones en instrucciones de control (saltos condicionales, aún no implementados aquí).
- Memoria de datos: Guarda datos manipulados por el programa (en este proyecto todavía es placeholder para LOAD/STORE futuros).
- Multiplexores (Mux): Seleccionan entre varias fuentes quién alimenta a la ALU o quién escribe a un registro.

Este ciclo es “single‑cycle” en el sentido de que en cada flanco de reloj se completa una instrucción (en este proyecto la idea es esa simplificación). No hay tuberías (pipeline) ni etapas superpuestas.

## 2. Arquitectura de tu computador 8-bit (directorio `proyecto2_repo`)
Formato de instrucción actual: 15 bits usados (un vector de 16 donde se ignora el bit 15 por ahora).
- [14:8] Opcode (7 bits)
- [7:0]  Inmediato / literal (8 bits)

Registros principales:
- A (8 bits)
- B (8 bits)
No hay más registros generales por ahora.

Flags almacenados: Z (Zero), N (Negativo, bit más alto = 1), C (Carry), V (Overflow aritmético). También se registra el último opcode ejecutado.

Camino de datos (resumen):
Instruction Memory → (ir15) → separación opcode + inmediato → Unidad de Control genera selectores y enables → muxA/muxB eligen operandos para la ALU (desde A, B o literal) → ALU produce resultado y flags crudas → mux_data selecciona la fuente de escritura (por ahora siempre ALU) → registros A y/o B se actualizan → status_register captura flags y opcode cuando hay escritura.

### Archivos y su función (visión macro, sin listar cada línea interna)

`computer.v`
Módulo top-level. Integra: PC, memoria de instrucciones, decodificación (a través de `control_unit`), registros A/B, ALU, multiplexores de operandos (`muxA`, `muxB`), multiplexor de datos (`mux_data`), status register, y (placeholder) data memory. Expone señales de debug y salidas para síntesis.

`pc.v`
Contador de programa de 16 bits. Incrementa cada ciclo (PC + 1). Su salida direcciona la memoria de instrucciones. No implementa saltos todavía.

`instruction_memory.v`
Memoria de sólo lectura inicializada desde `im.dat`. Devuelve 15 bits útiles (opcode + inmediato). Simulación: muestra mensajes (protegidos para síntesis con `ifndef SYNTHESIS`).

`im.dat`
Archivo de texto con las palabras de instrucción (formato binario) cargadas al inicio de la simulación/síntesis para la memoria de instrucciones.

`control_unit.v`
Decodifica el opcode (7 bits) y produce: señales de escritura a registros (weA, weB), selectores de operandos (selA, selB) y código de operación de la ALU (alu_op). Implementa actualmente MOV, ADD, SUB, AND, OR, XOR, NOT, desplazamientos, incrementos, etc. Preparado para ampliación futura.

`alu.v`
Unidad aritmético-lógica de 8 bits. Hace pases directos, suma, resta, AND, OR, XOR, NOT, desplazamientos (SHL/SHR), incremento. Calcula flags crudas (Z, N, C, V) según la operación.

`muxA.v` / `muxB.v`
Multiplexores (3 a 1) que eligen el operando A o B para la ALU. Fuentes posibles: registro A, registro B, inmediato.

`mux_data.v`
Multiplexor (3 a 1) para la fuente de datos que se escribirá en los registros A/B. Actualmente fijo a la salida de la ALU, pero ya conectado al placeholder de memoria y al literal para futuras instrucciones (LOAD, MOV literal directo sin pasar por ALU, etc.).

`mux2.v`
Multiplexor genérico 2 a 1 (parametrizable). Puede reutilizarse si en el futuro se necesitan selecciones binarias simples.

`register.v`
Registro genérico con escritura habilitada (we) y reset asíncrono. Se instancia para A y B.

`status_register.v`
Captura y mantiene (latch) las flags Z,N,C,V y el último opcode cuando ocurre una escritura válida a A o B. Aísla la lógica de estado del resto del diseño y permite ampliaciones (ej. agregar más flags) sin modificar el top.

`data_memory.v`
Memoria de datos (RAM) de 256 x 8 bits (placeholder). Sólo lectura efectiva por ahora (we conectado a 0). Cargada desde `mem.dat`. Preparada para LOAD/STORE futuros.

`mem.dat`
Inicialización de la memoria de datos. Actualmente ceros (o datos triviales). Cambiará cuando se agreguen instrucciones que la modifiquen.

`yosys.tcl`
Script de síntesis (Tcl) para Yosys: lee los módulos, establece `computer` como tope, sintetiza y genera netlist (`build/netlist.v`) y estadísticas. Incluye guardas para crear el directorio de salida.

`testbench.v`
Banco de pruebas para simular: instancia `computer`, aplica reloj y reset, y finaliza tras cierto número de ciclos. Puede ampliarse para hacer aserciones en el futuro.

`Makefile`
Automatiza:
- `make run` (compilar + simular con Icarus Verilog)
- `make wave` (abrir GTKWave tras simulación generando `dump.vcd`)
- `make synth` (ejecutar Yosys con `yosys.tcl`)

`README.md`
Documento de usuario (aún pendiente de actualización completa) donde se debe reflejar la arquitectura, lista de instrucciones implementadas y pasos de uso.

### Flujo temporal de una instrucción (en tu diseño actual)
1. El PC coloca su valor en la dirección de la memoria de instrucciones.
2. `instruction_memory` entrega `ir15` (opcode + inmediato).
3. Se separan campos: `opcode`, `imm`.
4. `control_unit` interpreta el opcode y decide:
   - ¿Se escribe A? (weA)
   - ¿Se escribe B? (weB)
   - ¿Qué fuente para los operando(s)? (selA, selB)
   - ¿Qué operación ejecuta la ALU? (alu_op)
5. `muxA` y `muxB` forman los operandos `opA`, `opB` para la ALU.
6. La ALU produce resultado y flags crudas.
7. `mux_data` (por ahora) selecciona siempre la salida de la ALU como `write_bus`.
8. En el flanco de reloj, si weA o weB están activos, A y/o B se actualizan con `write_bus`.
9. Ese mismo evento habilita `status_register` a capturar flags y último opcode.
10. El PC incrementa para la siguiente instrucción.
