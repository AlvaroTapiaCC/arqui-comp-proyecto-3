module test;
    reg           clk = 0;
    reg           rst = 1; // reset inicial activo
    wire [7:0]    regA_out;
    wire [7:0]    regB_out;

    reg           mov_test_failed = 1'b0;
    reg           reg_mov_test_failed = 1'b0;
    reg           add_test_failed = 1'b0;
    reg           sub_test_failed = 1'b0;
    reg           and_test_failed = 1'b0;
    reg           or_test_failed = 1'b0;
    reg           not_test_failed = 1'b0;
    reg           xor_test_failed = 1'b0;
    reg           shl_test_failed = 1'b0;
    reg           shr_test_failed = 1'b0;
    reg           inc_test_failed = 1'b0;

    // Instancia top con puertos expuestos (elimina acceso jerárquico interno)
    computer Comp(
        .clk(clk),
        .rst(rst),
        .A_out(regA_out),
        .B_out(regB_out),
        .last_opcode_out(),
        .flags_out()
    );

    initial begin
    $dumpfile("out/dump.vcd");
    $dumpvars(0, test);
    // La instrucción ya se carga dentro de instruction_memory; no se necesita $readmemb aquí.
    #2; rst = 0; // liberar reset después de 2 unidades de tiempo

        // --- Test 0: MOV Literal Instructions ---
        $display("\n----- STARTING TEST 0: MOV A,Lit & MOV B,Lit -----");

    #3; // tiempo tras liberar reset
        $display("CHECK @ t=%0t: After MOV A, 42 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd42) begin
            $error("FAIL: regA expected 42, got %d", regA_out);
            mov_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, 123 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd123) begin
            $error("FAIL: regB expected 123, got %d", regB_out);
            mov_test_failed = 1'b1;
        end

        if (!mov_test_failed) begin
            $display(">>>>> MOV TEST PASSED! <<<<< ");
        end else begin
            $display(">>>>> MOV TEST FAILED! <<<<< ");
        end

        // --- Test 1: Register-to-Register MOV Instructions ---
        $display("\n----- STARTING TEST 1: MOV A,B & MOV B,A -----");

        #2;
        $display("CHECK @ t=%0t: After MOV B, 85 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd85) begin
            $error("FAIL: regB expected 85, got %d", regB_out);
            reg_mov_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV A, 170 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd170) begin
            $error("FAIL: regA expected 170, got %d", regA_out);
            reg_mov_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV A, B -> regA = %d, regB = %d", $time, regA_out, regB_out);
        if (regA_out !== 8'd85) begin
            $error("FAIL: regA expected 85 (value from B), got %d", regA_out);
            reg_mov_test_failed = 1'b1;
        end
        if (regB_out !== 8'd85) begin
            $error("FAIL: Source regB should not change. Expected 85, got %d", regB_out);
            reg_mov_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV A, 99 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd99) begin
            $error("FAIL: regA expected 99, got %d", regA_out);
            reg_mov_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, A -> regA = %d, regB = %d", $time, regA_out, regB_out);
        if (regB_out !== 8'd99) begin
            $error("FAIL: regB expected 99 (value from A), got %d", regB_out);
            reg_mov_test_failed = 1'b1;
        end
        if (regA_out !== 8'd99) begin
            $error("FAIL: Source regA should not change. Expected 99, got %d", regA_out);
            reg_mov_test_failed = 1'b1;
        end

        if (!reg_mov_test_failed) begin
            $display(">>>>> REGISTER MOV TEST PASSED! <<<<< ");
        end else begin
            $display(">>>>> REGISTER MOV TEST FAILED! <<<<< ");
        end

        // --- Test 1: ADD Instructions (Register and Literal) ---
        $display("\n----- STARTING TEST 2: ADD Instructions -----");

        #2; // MOV A, 2
        $display("CHECK @ t=%0t: After MOV A, 2 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd2) begin
            $error("FAIL: regA expected 2, got %d", regA_out);
            add_test_failed = 1'b1;
        end

        #2; // MOV B, 3
        $display("CHECK @ t=%0t: After MOV B, 3 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd3) begin
            $error("FAIL: regB expected 3, got %d", regB_out);
            add_test_failed = 1'b1;
        end

        #2; // ADD A, B
        $display("CHECK @ t=%0t: After ADD A, B -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd5) begin
            $error("FAIL: regA expected 5 (2+3), got %d", regA_out);
            add_test_failed = 1'b1;
        end

        #2; // ADD A, 10
        $display("CHECK @ t=%0t: After ADD A, 10 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd15) begin
            $error("FAIL: regA expected 15 (5+10), got %d", regA_out);
            add_test_failed = 1'b1;
        end

        #2; // ADD B, 20
        $display("CHECK @ t=%0t: After ADD B, 20 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd23) begin
            $error("FAIL: regB expected 23 (3+20), got %d", regB_out);
            add_test_failed = 1'b1;
        end

        if (!add_test_failed) begin
            $display(">>>>> ALL ADD TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> ADD TEST FAILED! <<<<< ");
        end

        // --- Test 4: SUB Instructions ---
        $display("\n----- STARTING TEST 3: All SUB Instructions -----");

        #2; // MOV A, 20
        $display("CHECK @ t=%0t: After MOV A, 20 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd20) begin
            $error("FAIL: regA expected 20, got %d", regA_out);
            sub_test_failed = 1'b1;
        end

        #2; // MOV B, 5
        $display("CHECK @ t=%0t: After MOV B, 5 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd5) begin
            $error("FAIL: regB expected 5, got %d", regB_out);
            sub_test_failed = 1'b1;
        end

        #2; // SUB A, B
        $display("CHECK @ t=%0t: After SUB A, B -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd15) begin
            $error("FAIL: regA expected 15 (20-5), got %d", regA_out);
            sub_test_failed = 1'b1;
        end

        #2; // SUB B, A
        $display("CHECK @ t=%0t: After SUB B, A -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd10) begin
            $error("FAIL: regB expected 10 (15-5), got %d", regB_out);
            sub_test_failed = 1'b1;
        end

        #2; // SUB A, 7
        $display("CHECK @ t=%0t: After SUB A, 7 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd8) begin
            $error("FAIL: regA expected 8 (15-7), got %d", regA_out);
            sub_test_failed = 1'b1;
        end

        #2; // SUB B, 10
        $display("CHECK @ t=%0t: After SUB B, 10 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd0) begin
            $error("FAIL: regB expected0 (10-10 = 0), got %d", regB_out);
            sub_test_failed = 1'b1;
        end

        if (!sub_test_failed) begin
            $display(">>>>> ALL SUB TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> SUB TEST FAILED! <<<<< ");
        end

        // --- Test 5: AND Instructions ---
        $display("\n----- STARTING TEST 4: All AND Instructions -----");

        #2; // MOV A, 202
        $display("CHECK @ t=%0t: After MOV A, 202 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd202) begin
            $error("FAIL: regA expected 202, got %d", regA_out);
            and_test_failed = 1'b1;
        end

        #2; // MOV B, 174
        $display("CHECK @ t=%0t: After MOV B, 174 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd174) begin
            $error("FAIL: regB expected 174, got %d", regB_out);
            and_test_failed = 1'b1;
        end

        #2; // AND A, B
        $display("CHECK @ t=%0t: After AND A, B -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd138) begin
            $error("FAIL: regA expected 138 (202 & 174), got %d", regA_out);
            and_test_failed = 1'b1;
        end

        #2; // AND B, A
        $display("CHECK @ t=%0t: After AND B, A -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd138) begin
            $error("FAIL: regB expected 138 (174 & 138), got %d", regB_out);
            and_test_failed = 1'b1;
        end

        #2; // MOV A, 240
        $display("CHECK @ t=%0t: After MOV A, 240 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd240) begin
            $error("FAIL: regA expected 240, got %d", regA_out);
            and_test_failed = 1'b1;
        end

        #2; // AND A, 85
        $display("CHECK @ t=%0t: After AND A, 85 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd80) begin
            $error("FAIL: regA expected 80 (240 & 85), got %d", regA_out);
            and_test_failed = 1'b1;
        end

        #2; // MOV B, 204
        $display("CHECK @ t=%0t: After MOV B, 204 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd204) begin
            $error("FAIL: regB expected 204, got %d", regB_out);
            and_test_failed = 1'b1;
        end

        #2; // AND B, 170
        $display("CHECK @ t=%0t: After AND B, 170 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd136) begin
            $error("FAIL: regB expected 136 (204 & 170), got %d", regB_out);
            and_test_failed = 1'b1;
        end

        if (!and_test_failed) begin
            $display(">>>>> ALL AND TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> AND TEST FAILED! <<<<< ");
        end

        // --- Test 6: OR Instructions ---
        $display("\n----- STARTING TEST 5: All OR Instructions -----");

        #2; // MOV A, 202
        $display("CHECK @ t=%0t: After MOV A, 202 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd202) begin
            $error("FAIL: regA expected 202, got %d", regA_out);
            or_test_failed = 1'b1;
        end

        #2; // MOV B, 174
        $display("CHECK @ t=%0t: After MOV B, 174 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd174) begin
            $error("FAIL: regB expected 174, got %d", regB_out);
            or_test_failed = 1'b1;
        end

        #2; // OR A, B
        $display("CHECK @ t=%0t: After OR A, B -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd238) begin
            $error("FAIL: regA expected 238 (202 | 174), got %d", regA_out);
            or_test_failed = 1'b1;
        end

        #2; // OR B, A
        $display("CHECK @ t=%0t: After OR B, A -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd238) begin
            $error("FAIL: regB expected 238 (174 | 238), got %d", regB_out);
            or_test_failed = 1'b1;
        end

        #2; // MOV A, 51
        $display("CHECK @ t=%0t: After MOV A, 51 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd51) begin
            $error("FAIL: regA expected 51, got %d", regA_out);
            or_test_failed = 1'b1;
        end

        #2; // OR A, 240
        $display("CHECK @ t=%0t: After OR A, 240 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd243) begin
            $error("FAIL: regA expected 243 (51 | 240), got %d", regA_out);
            or_test_failed = 1'b1;
        end

        #2; // MOV B, 165
        $display("CHECK @ t=%0t: After MOV B, 165 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd165) begin
            $error("FAIL: regB expected 165, got %d", regB_out);
            or_test_failed = 1'b1;
        end

        #2; // OR B, 90
        $display("CHECK @ t=%0t: After OR B, 90 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd255) begin
            $error("FAIL: regB expected 255 (165 | 90), got %d", regB_out);
            or_test_failed = 1'b1;
        end

        if (!or_test_failed) begin
            $display(">>>>> ALL OR TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> OR TEST FAILED! <<<<< ");
        end

        // --- Test 7: NOT Instructions ---
        $display("\n----- STARTING TEST 6: All NOT Instructions -----");

        #2; // MOV A, 170
        $display("CHECK @ t=%0t: After MOV A, 170 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd170) begin
            $error("FAIL: regA expected 170, got %d", regA_out);
            not_test_failed = 1'b1;
        end

        #2; // NOT A, A
        $display("CHECK @ t=%0t: After NOT A, A -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd85) begin
            $error("FAIL: regA expected 85 (~170), got %d", regA_out);
            not_test_failed = 1'b1;
        end

        #2; // MOV B, 204
        $display("CHECK @ t=%0t: After MOV B, 204 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd204) begin
            $error("FAIL: regB expected 204, got %d", regB_out);
            not_test_failed = 1'b1;
        end

        #2; // NOT B, B
        $display("CHECK @ t=%0t: After NOT B, B -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd51) begin
            $error("FAIL: regB expected 51 (~204), got %d", regB_out);
            not_test_failed = 1'b1;
        end

        // Test NOT A, B
        #2; // MOV A, 255
        #2; // MOV B, 240
        #2; // NOT A, B
        $display("CHECK @ t=%0t: After NOT A, B -> regA = %d, regB = %d", $time, regA_out, regB_out);
        if (regA_out !== 8'd15) begin
            $error("FAIL: regA expected 15 (~240), got %d", regA_out);
            not_test_failed = 1'b1;
        end
        if (regB_out !== 8'd240) begin
            $error("FAIL: Source regB should not change. Expected 240, got %d", regB_out);
            not_test_failed = 1'b1;
        end

        // Test NOT B, A
        #2; // MOV A, 15
        #2; // MOV B, 255
        #2; // NOT B, A
        $display("CHECK @ t=%0t: After NOT B, A -> regB = %d, regA = %d", $time, regB_out, regA_out);
        if (regB_out !== 8'd240) begin
            $error("FAIL: regB expected 240 (~15), got %d", regB_out);
            not_test_failed = 1'b1;
        end
        if (regA_out !== 8'd15) begin
            $error("FAIL: Source regA should not change. Expected 15, got %d", regA_out);
            not_test_failed = 1'b1;
        end

        if (!not_test_failed) begin
            $display(">>>>> ALL NOT TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> NOT TEST FAILED! <<<<< ");
        end

        // --- Test 8: XOR Instructions ---
        $display("\n----- STARTING TEST 7: All XOR Instructions -----");

        #2; // MOV A, 202
        #2; // MOV B, 174

        #2; // the first XOR A, B
        $display("CHECK @ t=%0t: After first XOR A, B -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd100) begin
            $error("FAIL: regA expected 100 (202 ^ 174), got %d", regA_out);
            xor_test_failed = 1'b1;
        end

        #2; // the second XOR A, B
        $display("CHECK @ t=%0t: After second XOR A, B -> regA = %d (should restore)", $time, regA_out);
        if (regA_out !== 8'd202) begin
            $error("FAIL: regA expected 202 (100 ^ 174), got %d", regA_out);
            xor_test_failed = 1'b1;
        end

        #2; // MOV A, 240
        #2; // MOV B, 170

        #2; // XOR B, A
        $display("CHECK @ t=%0t: After XOR B, A -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd90) begin
            $error("FAIL: regB expected 90 (170 ^ 240), got %d", regB_out);
            xor_test_failed = 1'b1;
        end

        #2; // MOV A, 60
        #2; // XOR A, 255
        $display("CHECK @ t=%0t: After XOR A, 255 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd195) begin
            $error("FAIL: regA expected 195 (60 ^ 255), got %d", regA_out);
            xor_test_failed = 1'b1;
        end

        #2; // MOV B, 146
        #2; // XOR B, 102
        $display("CHECK @ t=%0t: After XOR B, 102 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd244) begin
            $error("FAIL: regB expected 244 (146 ^ 102), got %d", regB_out);
            xor_test_failed = 1'b1;
        end

        if (!xor_test_failed) begin
            $display(">>>>> ALL XOR TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> XOR TEST FAILED! <<<<< ");
        end

        // --- Test 9: SHL Instructions  ---
        $display("\n----- STARTING TEST 8: All SHL Instructions -----");

        // Test Case 1: SHL A, A (A = A << 1)
        #2; // MOV A, 5
        #2; // SHL A, A
        $display("CHECK @ t=%0t: After SHL A, A (A=5<<1) -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd10) begin
            $error("FAIL: regA expected 10, got %d", regA_out);
            shl_test_failed = 1'b1;
        end

        // Test Case 2: SHL B, B (B = B << 1)
        #2; // MOV B, 12
        #2; // SHL B, B
        $display("CHECK @ t=%0t: After SHL B, B (B=12<<1) -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd24) begin
            $error("FAIL: regB expected 24, got %d", regB_out);
            shl_test_failed = 1'b1;
        end

        // Test Case 3: SHL A, B (A = B << 1)
        #2; // MOV A, 99
        #2; // MOV B, 21
        #2; // SHL A, B
        $display("CHECK @ t=%0t: After SHL A, B (A=21<<1) -> regA = %d, regB = %d", $time, regA_out, regB_out);
        if (regA_out !== 8'd42) begin
            $error("FAIL: regA expected 42, got %d", regA_out);
            shl_test_failed = 1'b1;
        end
        if (regB_out !== 8'd21) begin
            $error("FAIL: Source regB should not change. Expected 21, got %d", regB_out);
            shl_test_failed = 1'b1;
        end

        // Test Case 4: SHL B, A (B = A << 1)
        #2; // MOV B, 88
        #2; // MOV A, 30
        #2; // SHL B, A
        $display("CHECK @ t=%0t: After SHL B, A (B=30<<1) -> regB = %d, regA = %d", $time, regB_out, regA_out);
        if (regB_out !== 8'd60) begin
            $error("FAIL: regB expected 60, got %d", regB_out);
            shl_test_failed = 1'b1;
        end
        if (regA_out !== 8'd30) begin
            $error("FAIL: Source regA should not change. Expected 30, got %d", regA_out);
            shl_test_failed = 1'b1;
        end

        // Test Case 5: Overflow Test (B = A << 1)
        #2; // MOV B, 0
        #2; // MOV A, 192
        #2; // SHL B, A
        $display("CHECK @ t=%0t: After SHL B, A (B=192<<1, overflow) -> regB = %d, regA = %d", $time, regB_out, regA_out);
        if (regB_out !== 8'd128) begin
            $error("FAIL: regB expected 128 (due to overflow), got %d", regB_out);
            shl_test_failed = 1'b1;
        end
        if (regA_out !== 8'd192) begin
            $error("FAIL: Source regA should not change. Expected 192, got %d", regA_out);
            shl_test_failed = 1'b1;
        end

        if (!shl_test_failed) begin
            $display(">>>>> ALL SHL TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> SHL TEST FAILED! <<<<< ");
        end

        // --- Test 10: SHR Instructions ---
        $display("\n----- STARTING TEST 9: All SHR Instructions -----");

        // Test Case 1: SHR A, A (A = A >> 1)
        #2; // MOV A, 10
        #2; // SHR A, A
        $display("CHECK @ t=%0t: After SHR A, A (A=10>>1) -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd5) begin
            $error("FAIL: regA expected 5, got %d", regA_out);
            shr_test_failed = 1'b1;
        end

        // Test Case 2: SHR B, B (B = B >> 1)
        #2; // MOV B, 24
        #2; // SHR B, B
        $display("CHECK @ t=%0t: After SHR B, B (B=24>>1) -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd12) begin
            $error("FAIL: regB expected 12, got %d", regB_out);
            shr_test_failed = 1'b1;
        end

        // Test Case 3: SHR A, B (A = B >> 1)
        #2; // MOV A, 99
        #2; // MOV B, 42
        #2; // SHR A, B
        $display("CHECK @ t=%0t: After SHR A, B (A=42>>1) -> regA = %d, regB = %d", $time, regA_out, regB_out);
        if (regA_out !== 8'd21) begin
            $error("FAIL: regA expected 21, got %d", regA_out);
            shr_test_failed = 1'b1;
        end
        if (regB_out !== 8'd42) begin
            $error("FAIL: Source regB should not change. Expected 42, got %d", regB_out);
            shr_test_failed = 1'b1;
        end

        // Test Case 4: SHR B, A (B = A >> 1)
        #2; // MOV B, 88
        #2; // MOV A, 60
        #2; // SHR B, A
        $display("CHECK @ t=%0t: After SHR B, A (B=60>>1) -> regB = %d, regA = %d", $time, regB_out, regA_out);
        if (regB_out !== 8'd30) begin
            $error("FAIL: regB expected 30, got %d", regB_out);
            shr_test_failed = 1'b1;
        end
        if (regA_out !== 8'd60) begin
            $error("FAIL: Source regA should not change. Expected 60, got %d", regA_out);
            shr_test_failed = 1'b1;
        end

        // Test Case 5: LSB Discard Test (B = A >> 1)
        #2; // MOV B, 0
        #2; // MOV A, 13
        #2; // SHR B, A
        $display("CHECK @ t=%0t: After SHR B, A (B=13>>1, LSB discard) -> regB = %d, regA = %d", $time, regB_out, regA_out);
        if (regB_out !== 8'd6) begin
            $error("FAIL: regB expected 6 (LSB discarded), got %d", regB_out);
            shr_test_failed = 1'b1;
        end
        if (regA_out !== 8'd13) begin
            $error("FAIL: Source regA should not change. Expected 13, got %d", regA_out);
            shr_test_failed = 1'b1;
        end

        if (!shr_test_failed) begin
            $display(">>>>> ALL SHR TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> SHR TEST FAILED! <<<<< ");
        end

        // --- Test 11: INC B Instruction ---
        $display("\n----- STARTING TEST 10: INC B Instruction -----");

        // Test Case 1: Basic Increment
        #2; // MOV B, 50
        #2; // INC B
        $display("CHECK @ t=%0t: After INC B (B=50+1) -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd51) begin
            $error("FAIL: regB expected 51, got %d", regB_out);
            inc_test_failed = 1'b1;
        end

        // Test Case 2: Increment from Zero
        #2; // MOV B, 0
        #2; // INC B
        $display("CHECK @ t=%0t: After INC B (B=0+1) -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd1) begin
            $error("FAIL: regB expected 1, got %d", regB_out);
            inc_test_failed = 1'b1;
        end

        // Test Case 3: Rollover/Overflow Test
        #2; // MOV B, 255
        #2; // INC B
        $display("CHECK @ t=%0t: After INC B (B=255+1, overflow) -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd0) begin
            $error("FAIL: regB expected 0 (due to 8-bit rollover), got %d", regB_out);
            inc_test_failed = 1'b1;
        end

        if (!inc_test_failed) begin
            $display(">>>>> ALL INC TESTS PASSED! <<<<< ");
        end else begin
            $display(">>>>> INC TEST FAILED! <<<<< ");
        end

        #2;
        $finish;
    end

    // Clock Generator
    always #1 clk = ~clk;

endmodule
