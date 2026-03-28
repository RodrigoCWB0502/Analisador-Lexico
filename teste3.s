@ =============================================================================
@ Código Assembly ARMv7 - Gerado pelo Analisador Léxico
@ Compatível com CPUlator DE1-SoC (v16.1)
@ =============================================================================
@ Instituição: PUCPR - Pontifícia Universidade Católica do Paraná
@ Disciplina:  Construção de Interpretadores
@ Professor:   Frank Coelho de Alcantara
@ Grupo:       Equipe 05
@ =============================================================================

.text
.global _start

_start:
    @ Inicializar stack pointer
    LDR SP, =0x20000

    @ Habilitar VFP (coprocessador de ponto flutuante)
    MRC p15, 0, R0, c1, c0, 2
    ORR R0, R0, #0xF00000      @ Habilitar acesso a CP10 e CP11
    MCR p15, 0, R0, c1, c0, 2
    MOV R0, #0x40000000         @ Setar EN bit no FPEXC
    VMSR FPEXC, R0

    @ Inicializar ponteiro de resultados
    LDR R8, =resultados         @ R8 = ponteiro para array de resultados
    MOV R9, #0                   @ R9 = contador de resultados

    @ Inicializar memória (MEM)
    LDR R10, =mem_storage        @ R10 = ponteiro para memória MEM

    @ ========== Expressão 1 ==========
    @ Empilhar número 0.001
    LDR R0, =const_double_0
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 999.999
    LDR R0, =const_double_1
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_4
hex_neg_3:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_4:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 2 ==========
    @ Empilhar número 1000000.0
    LDR R0, =const_double_2
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 0.000001
    LDR R0, =const_double_3
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: *
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VMUL.F64 D2, D0, D1   @ D2 = A * B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_8
hex_neg_7:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_8:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 3 ==========
    @ Empilhar número 7.0
    LDR R0, =const_double_4
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 3
    LDR R0, =const_double_5
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: ^
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    @ Potenciação: A^B (B inteiro positivo)
    VCVT.S32.F64 S2, D1   @ S2 = (int)B  [S2=lower D1, preserva D0]
    VMOV R1, S2            @ R1 = expoente
    MOV R0, #1
    VMOV S4, R0            @ S4 = lower D2 (nao alias D0!)
    VCVT.F64.S32 D2, S4   @ D2 = 1.0 (acumulador, D0 preservado)
    CMP R1, #0
    BLE pow_end_10
pow_loop_9:
    VMUL.F64 D2, D2, D0   @ D2 = D2 * A
    SUBS R1, R1, #1
    BNE pow_loop_9
pow_end_10:
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_14
hex_neg_13:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_14:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    B _skip_ltorg_3
    .ltorg
_skip_ltorg_3:

    @ ========== Expressão 4 ==========
    @ Empilhar número 99
    LDR R0, =const_double_6
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 10
    LDR R0, =const_double_7
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: //
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    @ Divisão inteira: converter para inteiro, dividir
    VCVT.S32.F64 S0, D0   @ S0 = (int)A
    VCVT.S32.F64 S1, D1   @ S1 = (int)B
    VMOV R0, S0            @ R0 = (int)A
    VMOV R1, S1            @ R1 = (int)B
    @ Divisão inteira por subtração repetida
    MOV R2, #0             @ R2 = quociente
    CMP R0, #0
    RSBLT R0, R0, #0       @ abs(A)
    CMP R1, #0
    RSBLT R1, R1, #0       @ abs(B)
div_int_loop_15:
    CMP R0, R1
    BLT div_int_end_16
    SUB R0, R0, R1
    ADD R2, R2, #1
    B div_int_loop_15
div_int_end_16:
    VMOV S0, R2
    VCVT.F64.S32 D2, S0   @ D2 = resultado como double
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_20
hex_neg_19:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_20:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 5 ==========
    @ Empilhar número 99
    LDR R0, =const_double_6
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 10
    LDR R0, =const_double_7
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: %
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    @ Resto da divisão inteira
    VCVT.S32.F64 S0, D0   @ S0 = (int)A
    VCVT.S32.F64 S1, D1   @ S1 = (int)B
    VMOV R0, S0            @ R0 = (int)A
    VMOV R1, S1            @ R1 = (int)B
    @ Módulo por subtração repetida
mod_loop_21:
    CMP R0, R1
    BLT mod_end_22
    SUB R0, R0, R1
    B mod_loop_21
mod_end_22:
    VMOV S0, R0            @ S0 = resto
    VCVT.F64.S32 D2, S0   @ D2 = resultado como double
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_26
hex_neg_25:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_26:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 6 ==========
    @ Empilhar número 3.14159
    LDR R0, =const_double_8
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 2.71828
    LDR R0, =const_double_9
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_30
hex_neg_29:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_30:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    B _skip_ltorg_6
    .ltorg
_skip_ltorg_6:

    @ ========== Expressão 7 ==========
    @ Empilhar número 1.0
    LDR R0, =const_double_10
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 2.0
    LDR R0, =const_double_11
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Empilhar número 3.0
    LDR R0, =const_double_12
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 4.0
    LDR R0, =const_double_13
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Empilhar número 5.0
    LDR R0, =const_double_14
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 6.0
    LDR R0, =const_double_15
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Operação: *
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VMUL.F64 D2, D0, D1   @ D2 = A * B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_34
hex_neg_33:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_34:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 8 ==========
    @ Empilhar número 2.0
    LDR R0, =const_double_11
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 3.0
    LDR R0, =const_double_12
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: *
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VMUL.F64 D2, D0, D1   @ D2 = A * B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Empilhar número 4.0
    LDR R0, =const_double_13
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 5.0
    LDR R0, =const_double_14
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: *
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VMUL.F64 D2, D0, D1   @ D2 = A * B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Operação: -
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VSUB.F64 D2, D0, D1   @ D2 = A - B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_38
hex_neg_37:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_38:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 9 ==========
    @ Empilhar número 42.0
    LDR R0, =const_double_16
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Comando MEM: armazenar valor
    VLDR D0, [SP]          @ D0 = valor no topo (não desempilha)
    VSTR D0, [R10]         @ Salvar na memória MEM

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_42
hex_neg_41:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_42:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    B _skip_ltorg_9
    .ltorg
_skip_ltorg_9:

    @ ========== Expressão 10 ==========
    @ Comando MEM: recuperar valor
    VLDR D0, [R10]         @ D0 = valor da memória
    SUB SP, SP, #8
    VSTR D0, [SP]          @ Empilhar valor recuperado
    @ Comando MEM: recuperar valor
    VLDR D0, [R10]         @ D0 = valor da memória
    SUB SP, SP, #8
    VSTR D0, [SP]          @ Empilhar valor recuperado
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_46
hex_neg_45:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_46:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 11 ==========
    @ Empilhar número 1
    LDR R0, =const_double_17
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Comando RES: buscar resultado anterior
    VLDR D0, [SP]          @ D0 = N (índice)
    ADD SP, SP, #8         @ Desempilhar N
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = N
    @ Calcular endereço: resultados + (R9 - R0) * 8
    SUB R1, R9, R0         @ R1 = total_resultados - N
    LSL R1, R1, #3         @ R1 = R1 * 8 (cada double = 8 bytes)
    ADD R1, R8, R1         @ R1 = endereço do resultado
    VLDR D2, [R1]          @ D2 = resultado buscado
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado buscado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_50
hex_neg_49:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_50:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 12 ==========
    @ Empilhar número 100.0
    LDR R0, =const_double_18
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 50.0
    LDR R0, =const_double_19
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: -
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VSUB.F64 D2, D0, D1   @ D2 = A - B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Empilhar número 25.0
    LDR R0, =const_double_20
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 5.0
    LDR R0, =const_double_14
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: /
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VDIV.F64 D2, D0, D1   @ D2 = A / B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Operação: *
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VMUL.F64 D2, D0, D1   @ D2 = A * B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_54
hex_neg_53:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_54:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    B _skip_ltorg_12
    .ltorg
_skip_ltorg_12:

    @ ========== Expressão 13 ==========
    @ Empilhar número 2.0
    LDR R0, =const_double_11
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 16
    LDR R0, =const_double_21
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: ^
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    @ Potenciação: A^B (B inteiro positivo)
    VCVT.S32.F64 S2, D1   @ S2 = (int)B  [S2=lower D1, preserva D0]
    VMOV R1, S2            @ R1 = expoente
    MOV R0, #1
    VMOV S4, R0            @ S4 = lower D2 (nao alias D0!)
    VCVT.F64.S32 D2, S4   @ D2 = 1.0 (acumulador, D0 preservado)
    CMP R1, #0
    BLE pow_end_56
pow_loop_55:
    VMUL.F64 D2, D2, D0   @ D2 = D2 * A
    SUBS R1, R1, #1
    BNE pow_loop_55
pow_end_56:
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_60
hex_neg_59:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_60:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 14 ==========
    @ Empilhar número 0.5
    LDR R0, =const_double_22
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 0.25
    LDR R0, =const_double_23
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: /
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VDIV.F64 D2, D0, D1   @ D2 = A / B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_64
hex_neg_63:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_64:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]
    @ Pressione KEY0 para próxima expressão
    BL wait_key

    @ ========== Expressão 15 ==========
    @ Empilhar número 3.0
    LDR R0, =const_double_12
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 4.0
    LDR R0, =const_double_13
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 5.0
    LDR R0, =const_double_14
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 6.0
    LDR R0, =const_double_15
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Operação: *
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VMUL.F64 D2, D0, D1   @ D2 = A * B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Operação: +
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VADD.F64 D2, D0, D1   @ D2 = A + B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado
    @ Empilhar número 2.0
    LDR R0, =const_double_11
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Operação: -
    VLDR D1, [SP]          @ B = topo da pilha
    ADD SP, SP, #8
    VLDR D0, [SP]          @ A = segundo da pilha
    ADD SP, SP, #8
    VSUB.F64 D2, D0, D1   @ D2 = A - B
    SUB SP, SP, #8
    VSTR D2, [SP]          @ Empilhar resultado

    @ Salvar resultado da expressão
    VLDR D0, [SP]          @ D0 = resultado
    ADD SP, SP, #8         @ Desempilhar
    LSL R1, R9, #3         @ R1 = R9 * 8
    ADD R1, R8, R1         @ R1 = endereço no array
    VSTR D0, [R1]          @ Salvar resultado
    ADD R9, R9, #1         @ Incrementar contador
    @ Exibir resultado nos displays HEX
    VCVT.S32.F64 S0, D0   @ Converter para inteiro
    VMOV R0, S0            @ R0 = parte inteira do resultado
    
    @ Verificar sinal
    CMP R0, #0
    BGE hex_pos_68
hex_neg_67:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_68:
    @ Converter para BCD e exibir nos HEX displays
    LDR R4, =hex_table     @ Tabela de segmentos
    MOV R3, #0             @ Acumulador de segmentos
    
    @ Dígito 0 (unidades)
    MOV R1, #10
    BL div_mod             @ R0=quociente, R2=resto
    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito
    ORR R3, R3, R5         @ HEX0
    
    @ Dígito 1 (dezenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #8  @ HEX1
    
    @ Dígito 2 (centenas)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #16 @ HEX2
    
    @ Dígito 3 (milhares)
    BL div_mod
    LDR R5, [R4, R2, LSL #2]
    ORR R3, R3, R5, LSL #24 @ HEX3
    
    @ Escrever nos displays HEX3-HEX0
    LDR R6, =0xFF200020
    STR R3, [R6]
    
    @ Acender LEDs com padrão indicando expressão processada
    LDR R6, =0xFF200000
    MOV R1, #1
    LSL R1, R1, R9          @ LED correspondente à expressão
    STR R1, [R6]

    B _skip_ltorg_15
    .ltorg
_skip_ltorg_15:

    @ ========== Fim do programa ==========
    @ Loop infinito (programa concluído)
halt:
    B halt

@ ----- Sub-rotina: esperar botão KEY0 -----
wait_key:
    PUSH {R0-R1, LR}
    LDR R1, =0xFF200050    @ KEY data register
wait_key_press:
    LDR R0, [R1]
    TST R0, #1             @ Bit0=1 significa NÃO pressionado
    BNE wait_key_press     @ Ainda não apertou, esperar
    @ KEY0 pressionado, agora esperar soltar
wait_key_release:
    LDR R0, [R1]
    TST R0, #1
    BEQ wait_key_release   @ Ainda apertado, esperar soltar
    POP {R0-R1, PC}

@ ----- Sub-rotina: divisão e módulo -----
@ Entrada: R0 = dividendo, R1 = divisor
@ Saída: R0 = quociente, R2 = resto
div_mod:
    PUSH {LR}
    MOV R2, R0             @ R2 = dividendo (será o resto)
    MOV R0, #0             @ R0 = quociente
div_mod_loop:
    CMP R2, R1
    BLT div_mod_end
    SUB R2, R2, R1
    ADD R0, R0, #1
    B div_mod_loop
div_mod_end:
    POP {PC}

@ =============================================================================
@ Seção de dados
@ =============================================================================
.data

@ Tabela de segmentos para display 7-seg (0-F)
hex_table:
    .word 0x3F    @ 0
    .word 0x06    @ 1
    .word 0x5B    @ 2
    .word 0x4F    @ 3
    .word 0x66    @ 4
    .word 0x6D    @ 5
    .word 0x7D    @ 6
    .word 0x07    @ 7
    .word 0x7F    @ 8
    .word 0x6F    @ 9
    .word 0x77    @ A
    .word 0x7C    @ B
    .word 0x39    @ C
    .word 0x5E    @ D
    .word 0x79    @ E
    .word 0x71    @ F

.align 3                   @ Alinhar em 8 bytes para doubles
@ Constantes double (IEEE 754 - 64 bits)
const_double_0:    @ 0.001
    .word 0xD2F1A9FC    @ low word
    .word 0x3F50624D    @ high word
const_double_1:    @ 999.999
    .word 0xF3B645A2    @ low word
    .word 0x408F3FFD    @ high word
const_double_2:    @ 1000000.0
    .word 0x00000000    @ low word
    .word 0x412E8480    @ high word
const_double_3:    @ 0.000001
    .word 0xA0B5ED8D    @ low word
    .word 0x3EB0C6F7    @ high word
const_double_4:    @ 7.0
    .word 0x00000000    @ low word
    .word 0x401C0000    @ high word
const_double_5:    @ 3
    .word 0x00000000    @ low word
    .word 0x40080000    @ high word
const_double_6:    @ 99
    .word 0x00000000    @ low word
    .word 0x4058C000    @ high word
const_double_7:    @ 10
    .word 0x00000000    @ low word
    .word 0x40240000    @ high word
const_double_8:    @ 3.14159
    .word 0xF01B866E    @ low word
    .word 0x400921F9    @ high word
const_double_9:    @ 2.71828
    .word 0x95AAF790    @ low word
    .word 0x4005BF09    @ high word
const_double_10:    @ 1.0
    .word 0x00000000    @ low word
    .word 0x3FF00000    @ high word
const_double_11:    @ 2.0
    .word 0x00000000    @ low word
    .word 0x40000000    @ high word
const_double_12:    @ 3.0
    .word 0x00000000    @ low word
    .word 0x40080000    @ high word
const_double_13:    @ 4.0
    .word 0x00000000    @ low word
    .word 0x40100000    @ high word
const_double_14:    @ 5.0
    .word 0x00000000    @ low word
    .word 0x40140000    @ high word
const_double_15:    @ 6.0
    .word 0x00000000    @ low word
    .word 0x40180000    @ high word
const_double_16:    @ 42.0
    .word 0x00000000    @ low word
    .word 0x40450000    @ high word
const_double_17:    @ 1
    .word 0x00000000    @ low word
    .word 0x3FF00000    @ high word
const_double_18:    @ 100.0
    .word 0x00000000    @ low word
    .word 0x40590000    @ high word
const_double_19:    @ 50.0
    .word 0x00000000    @ low word
    .word 0x40490000    @ high word
const_double_20:    @ 25.0
    .word 0x00000000    @ low word
    .word 0x40390000    @ high word
const_double_21:    @ 16
    .word 0x00000000    @ low word
    .word 0x40300000    @ high word
const_double_22:    @ 0.5
    .word 0x00000000    @ low word
    .word 0x3FE00000    @ high word
const_double_23:    @ 0.25
    .word 0x00000000    @ low word
    .word 0x3FD00000    @ high word

@ Array de resultados (até 64 expressões)
resultados:
    .space 512             @ 64 * 8 bytes

@ Memória MEM (1 double)
mem_storage:
    .space 8
