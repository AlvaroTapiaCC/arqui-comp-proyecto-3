// Adapted testbench for current 'computer' module.
// Original logic preserved; only hierarchical paths and ports adjusted.
// New top-level ports used: A_out, B_out, rst added. Memory/instruction memory accessed via instance names.

module test;
    reg           clk = 0;
    reg           rst = 1;
    wire [7:0]    regA_out;
    wire [7:0]    regB_out;

    reg mem_sequence_test_failed = 1'b0;
    reg add_a_dir_test_failed    = 1'b0;
    reg jeq_test_1_failed        = 1'b0;

    // ------------------------------------------------------------
    // Instancia del computador (adaptado a interfaz actual)
    // ------------------------------------------------------------
    computer Comp (
        .clk(clk),
        .rst(rst),
        .A_out(regA_out),
        .B_out(regB_out),
        .last_opcode_out(),
        .flags_out()
    );
    // ------------------------------------------------------------

    // ------------------------------------------------------------
    // Mapeos de señales originales a nuevas rutas
    // (Original referenciaba Comp.regA.out / Comp.regB.out / Comp.DM.mem / Comp.IM.mem)
    // Ahora usamos:
    //   Registros: puertos top (regA_out, regB_out)
    //   Data Memory: Comp.U_DMEM.ram[idx]
    //   Instruction Memory: Comp.U_IM.mem
    // (Debug interno removido en versión simplificada)
    // ------------------------------------------------------------

    initial begin
        $dumpfile("out/dump.vcd");
        $dumpvars(0, test);
        // Cargar programa (mantiene nombre original del testbench):
        $readmemb("data/im_memory.dat", Comp.U_IM.mem);

        // Liberar reset tras breve tiempo
        #2 rst = 0;

        // --- Test: Full & Expanded Memory Sequence ---
        $display("\n----- STARTING TEST: Full Memory Sequence -----");

        // --- Part 1: Original Test (RegB -> Mem -> RegA) ---
        $display("\n--- Part 1: Testing RegB -> Memory -> RegA ---");

        // Check Inst 0: MOV B, 99 | Purpose: Verify that register B is loaded with the immediate value 99.
        #2;
        $display("CHECK @ t=%0t: After MOV B, 99 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd99) begin
            $error("FAIL [Part 1]: regB expected 99, got %d", regB_out);
            mem_sequence_test_failed = 1'b1;
        end

        // Check Inst 1: MOV (50), B | Purpose: Verify that the value from register B (99) is stored in DM[50].
        #2;
        $display("CHECK @ t=%0t: After MOV (50), B -> DM[50] = %d", $time, Comp.U_DMEM.ram[50]);
        if (Comp.U_DMEM.ram[50] !== 8'd99) begin
            $error("FAIL [Part 1]: DM[50] expected 99, got %d", Comp.U_DMEM.ram[50]);
            mem_sequence_test_failed = 1'b1;
        end

        // Check Inst 2: MOV A, (50) | Purpose: Verify that register A is loaded with the value from DM[50] (99).
        #2;
        $display("CHECK @ t=%0t: After MOV A, (50) -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd99) begin
            $error("FAIL [Part 1]: regA expected 99, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        // --- Part 2: Symmetric Test (RegA -> Mem -> RegB) ---
        $display("\n--- Part 2: Testing RegA -> Memory -> RegB ---");

        // Check Inst 3: MOV A, 123 | Purpose: Verify that register A is loaded with the immediate value 123.
        #2;
        $display("CHECK @ t=%0t: After MOV A, 123 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd123) begin
            $error("FAIL [Part 2]: regA expected 123, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        // Check Inst 4: MOV (51), A | Purpose: Verify that the value from register A (123) is stored in DM[51].
        #2;
        $display("CHECK @ t=%0t: After MOV (51), A -> DM[51] = %d", $time, Comp.U_DMEM.ram[51]);
        if (Comp.U_DMEM.ram[51] !== 8'd123) begin
            $error("FAIL [Part 2]: DM[51] expected 123, got %d", Comp.U_DMEM.ram[51]);
            mem_sequence_test_failed = 1'b1;
        end

        // Check Inst 5: MOV B, (51) | Purpose: Verify that register B is loaded with the value from DM[51] (123).
        #2;
        $display("CHECK @ t=%0t: After MOV B, (51) -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd123) begin
            $error("FAIL [Part 2]: regB expected 123, got %d", regB_out);
            mem_sequence_test_failed = 1'b1;
        end

        // --- Part 3: Overwrite and Edge Case Test (0 and 255) ---
        $display("\n--- Part 3: Testing Overwrite and Edge Cases ---");

        // Check Inst 6: MOV A, 255 | Purpose: Verify that register A is loaded with the immediate value 255.
        #2;
        $display("CHECK @ t=%0t: After MOV A, 255 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd255) begin
            $error("FAIL [Part 3]: regA expected 255, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        // Check Inst 7: MOV (50), A | Purpose: Verify that the value from register A (255) overwrites the content of DM[50].
        #2;
        $display("CHECK @ t=%0t: After MOV (50), A [Overwrite] -> DM[50] = %d", $time, Comp.U_DMEM.ram[50]);
        if (Comp.U_DMEM.ram[50] !== 8'd255) begin
            $error("FAIL [Part 3]: DM[50] expected 255 after overwrite, got %d", Comp.U_DMEM.ram[50]);
            mem_sequence_test_failed = 1'b1;
        end

        // Check Inst 8: MOV A, 0 | Purpose: Verify that register A is loaded with the immediate value 0.
        #2;
        $display("CHECK @ t=%0t: After MOV A, 0 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd0) begin
            $error("FAIL [Part 3]: regA expected 0, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        // Check Inst 9: MOV A, (50) | Purpose: Verify that register A reads the overwritten value (255) from DM[50].
        #2;
        $display("CHECK @ t=%0t: After MOV A, (50) [Read Overwritten Value] -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd255) begin
            $error("FAIL [Part 3]: Read of overwritten DM[50] expected 255, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        // --- Final Summary for this Test Block ---
        if (!mem_sequence_test_failed) begin
            $display(">>>>> ALL MEMORY SEQUENCE TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> MEMORY SEQUENCE TEST FAILED! <<<<< ");
        end

        // --- Test: ADD A, (Dir) ---
        $display("\n----- STARTING TEST: ADD A, (Dir) -----");

        // Check Inst 10: MOV A, 100 | Purpose: Verify that register A is loaded with the operand 100.
        #2;
        $display("CHECK @ t=%0t: After MOV A, 100 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd100) begin
            $error("FAIL [ADD A, Dir]: regA expected 100, got %d", regA_out);
            add_a_dir_test_failed = 1'b1;
        end

        // Check Inst 11: MOV B, 50 | Purpose: Verify that register B is loaded with the operand 50.
        #2;
        $display("CHECK @ t=%0t: After MOV B, 50 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd50) begin
            $error("FAIL [ADD A, Dir]: regB expected 50, got %d", regB_out);
            add_a_dir_test_failed = 1'b1;
        end

        // Check Inst 12: MOV (120), B | Purpose: Verify that the value from register B (50) is stored in DM[120].
        #2;
        $display("CHECK @ t=%0t: After MOV (120), B -> DM[120] = %d", $time, Comp.U_DMEM.ram[120]);
        if (Comp.U_DMEM.ram[120] !== 8'd50) begin
            $error("FAIL [ADD A, Dir]: DM[120] expected 50, got %d", Comp.U_DMEM.ram[120]);
            add_a_dir_test_failed = 1'b1;
        end

        // Check Inst 13: ADD A, (120) | Purpose: Verify that regA = regA + DM[120] (100 + 50 = 150).
        #2;
        $display("CHECK @ t=%0t: After ADD A, (120) -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd150) begin
            $error("FAIL [ADD A, Dir]: regA expected 150, got %d", regA_out);
            add_a_dir_test_failed = 1'b1;
        end

        // --- Final Summary for this Test Block ---
        if (!add_a_dir_test_failed) begin
            $display(">>>>> ADD A, (Dir) TEST PASSED! <<<<< ");
        end else begin
            $display(">>>>> ADD A, (Dir) TEST FAILED! <<<<< ");
        end

        // --- Test: JEQ (IF/ELSE) - Case 1: A == B ---
        $display("\n----- STARTING TEST: JEQ - Case 1 (A == B) -----");
        #16; // Wait for the entire 8-instruction program to complete.

        // Check Program Result (Inst 14-21): JEQ Logic | Purpose: Verify DM[100] is 1, confirming the conditional jump was correctly taken.
        $display("CHECK @ t=%0t: After IF/ELSE program (A==B) -> DM[100] = %d", $time, Comp.U_DMEM.ram[100]);
        if (Comp.U_DMEM.ram[100] !== 8'd1) begin
            $error("FAIL [JEQ Case 1]: DM[100] expected 1, got %d. The jump was likely not taken.", Comp.U_DMEM.ram[100]);
            jeq_test_1_failed = 1'b1;
        end

        // --- Final Summary for this Test Block ---
        if (!jeq_test_1_failed) begin
            $display(">>>>> JEQ (A == B) TEST PASSED! <<<<< ");
        end else begin
            $display(">>>>> JEQ (A == B) TEST FAILED! <<<<< ");
        end

        #2;
        $finish;
    end

    // Clock Generator
    always #1 clk = ~clk;

endmodule
