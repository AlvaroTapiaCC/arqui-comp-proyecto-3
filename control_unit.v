// control_unit.v
module control_unit(
    input  wire [6:0] opcode,
    output reg        weA,
    output reg        weB,
    output reg [1:0]  selA,
    output reg [1:0]  selB,
    output reg [3:0]  alu_op
);

    always @* begin
        // defaults
        weA = 0;
        weB = 0;
        selA = 2'b00;
        selB = 2'b01; // por defecto: a=A, b=B
        alu_op = 4'h0;            // PASSA

        case (opcode)
            // MOV
            7'h00: begin // MOV A,B
                alu_op = 4'h1;
                selA = 2'b01;
                weA = 1;
            end
            7'h00: begin // MOV A,B
                alu_op = 4'h1;
                selA  = 2'b01;
                weA   = 1;
            end
            7'h02: begin // MOV A, lit
                selA = 2'b10;
                selB  = 2'b00;
                weB   = 1;
            7'h03: begin // MOV B, lit
                alu_op = 4'h1;
                selA  = 2'b10;
                weA   = 1;      // Y = imm
            end

            // ADD
                selB  = 2'b10;
                weB   = 1;      // Y = imm (vía PASSB)
                selA = 2'b00;
                selB = 2'b01;
                weA = 1;
            end
            7'h05: begin // ADD B,A
                alu_op = 4'h2;
                selA = 2'b01;
                selB = 2'b00;
                weB = 1;
            end
            7'h06: begin // ADD A, lit
                alu_op = 4'h2;
                selA = 2'b00;
                selB = 2'b10;
                weA = 1;
            end
            7'h07: begin // ADD B, lit
                alu_op = 4'h2;
                selA = 2'b01;
                selB = 2'b10;
                weB = 1;
            end

            // SUB
            7'h08: begin // SUB A,B
                alu_op = 4'h3;
                selA = 2'b00;
                selB = 2'b01;
                weA = 1;
            end
            7'h09: begin // SUB B,A
                alu_op = 4'h3;
                selA  = 2'b01;
                selB  = 2'b00;
                weB   = 1;
            end
            7'h04: begin // ADD A,B
                alu_op = 4'h2;
                selA  = 2'b00;
                selB  = 2'b01;
                weA   = 1;
            end
            7'h0B: begin // SUB B, lit
                alu_op = 4'h3;
                selA  = 2'b01;
                selB  = 2'b00;
                weB   = 1;
            end

            // AND
                selA  = 2'b00;
                selB  = 2'b10;
                weA   = 1;
                selB  = 2'b01;
                weA   = 1;
            end
                selA  = 2'b01;
                selB  = 2'b10;
                weB   = 1;
                selB  = 2'b00;
                weB   = 1;
            end
            7'h08: begin // SUB A,B
                alu_op = 4'h3;
                selA  = 2'b00;
                selB  = 2'b01;
                weA   = 1;
            end
            7'h0F: begin // AND B, lit
                alu_op = 4'h4;
                selA  = 2'b01;
                selB  = 2'b10;
                weB   = 1;
            end

            // OR
            7'h10: begin // OR A,B
                alu_op = 4'h5;
                selA  = 2'b00;
                selB  = 2'b01;
                weA   = 1;
            end
            7'h11: begin // OR B,A
                alu_op = 4'h5;
                selA  = 2'b01;
                selB  = 2'b00;
                weB   = 1;
            end
            7'h12: begin // OR A, lit
                alu_op = 4'h5;
                selA  = 2'b00;
                selB  = 2'b10;
                weA   = 1;
            end
            7'h13: begin // OR B, lit
                alu_op = 4'h5;
                selA  = 2'b01;
                selB  = 2'b10;
                weB   = 1;
            end

            // NOT
            7'h14: begin // NOT A,A  -> A = ~A
                alu_op = 4'h7;
                selA  = 2'b00;
                weA   = 1;
            end
            7'h15: begin // NOT A,B  -> A = ~B
                alu_op = 4'h7;
                selA  = 2'b01;
                weA   = 1;
            end
            7'h16: begin // NOT B,A  -> B = ~A
                alu_op = 4'h7;
                selA  = 2'b00;
                weB   = 1;
            end
            7'h17: begin // NOT B,B  -> B = ~B
                alu_op = 4'h7;
                selA  = 2'b01;
                weB   = 1;
            end

            // XOR
            7'h18: begin // XOR A,B
                alu_op = 4'h6;
                selA  = 2'b00;
                selB  = 2'b01;
                weA   = 1;
            end
            7'h19: begin // XOR B,A
                alu_op = 4'h6;
                selA  = 2'b01;
                selB  = 2'b00;
                weB   = 1;
            end
            7'h1A: begin // XOR A, lit
                alu_op = 4'h6;
                selA  = 2'b00;
                selB  = 2'b10;
                weA   = 1;
            end
            7'h1B: begin // XOR B, lit
                alu_op = 4'h6;
                selA  = 2'b01;
                selB  = 2'b10;
                weB   = 1;
            end

            // SHL (ALU desplaza 'a')
            7'h1C: begin // SHL A,A
                alu_op = 4'h8;
                selA  = 2'b00;
                weA   = 1;
            end
            7'h1D: begin // SHL A,B  -> A = B<<1
                alu_op = 4'h8;
                selA  = 2'b01;
                weA   = 1;
            end
            7'h1E: begin // SHL B,A  -> B = A<<1
                alu_op = 4'h8;
                selA  = 2'b00;
                weB   = 1;
            end
            7'h1F: begin // SHL B,B
                alu_op = 4'h8;
                selA  = 2'b01;
                weB   = 1;
            end

            // SHR (ALU desplaza 'a' lógico)
            7'h20: begin // SHR A,A
                alu_op = 4'h9;
                selA  = 2'b00;
                weA   = 1;
            end
            7'h21: begin // SHR A,B  -> A = B>>1
                alu_op = 4'h9;
                selA  = 2'b01;
                weA   = 1;
            end
            7'h22: begin // SHR B,A  -> B = A>>1
                alu_op = 4'h9;
                selA  = 2'b00;
                weB   = 1;
            end
                7'h23: begin // SHR B,B
                alu_op = 4'h9;
                selA  = 2'b01;
                weB   = 1;
            end

            // INC
            7'h24: begin // INC B
                alu_op = 4'hA;
                selA  = 2'b00;
                selB  = 2'b01;
                weB   = 1;
            end

            default: ; // NOP
        endcase
    end
endmodule