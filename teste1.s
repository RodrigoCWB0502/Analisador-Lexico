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
    @ Empilhar número 3.14
    LDR R0, =const_double_0
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 2.0
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
    @ Empilhar número 10.5
    LDR R0, =const_double_2
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 3.5
    LDR R0, =const_double_3
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
    @ Empilhar número 4.0
    LDR R0, =const_double_4
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 5.0
    LDR R0, =const_double_5
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
    BGE hex_pos_12
hex_neg_11:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_12:
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
    @ Empilhar número 20.0
    LDR R0, =const_double_6
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 4.0
    LDR R0, =const_double_4
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
    BGE hex_pos_16
hex_neg_15:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_16:
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
    @ Empilhar número 17
    LDR R0, =const_double_7
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 5
    LDR R0, =const_double_8
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
div_int_loop_17:
    CMP R0, R1
    BLT div_int_end_18
    SUB R0, R0, R1
    ADD R2, R2, #1
    B div_int_loop_17
div_int_end_18:
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
    BGE hex_pos_22
hex_neg_21:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_22:
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
    @ Empilhar número 17
    LDR R0, =const_double_7
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 5
    LDR R0, =const_double_8
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
mod_loop_23:
    CMP R0, R1
    BLT mod_end_24
    SUB R0, R0, R1
    B mod_loop_23
mod_end_24:
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
    BGE hex_pos_28
hex_neg_27:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_28:
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
    @ Empilhar número 2.0
    LDR R0, =const_double_1
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 10
    LDR R0, =const_double_9
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
    BLE pow_end_30
pow_loop_29:
    VMUL.F64 D2, D2, D0   @ D2 = D2 * A
    SUBS R1, R1, #1
    BNE pow_loop_29
pow_end_30:
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
    @ Empilhar número 3.14
    LDR R0, =const_double_0
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 2.0
    LDR R0, =const_double_1
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 1.0
    LDR R0, =const_double_10
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
    @ Empilhar número 10.0
    LDR R0, =const_double_11
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 2.0
    LDR R0, =const_double_1
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
    LDR R0, =const_double_4
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 1.0
    LDR R0, =const_double_10
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
    @ Empilhar número 2.5
    LDR R0, =const_double_12
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 3.5
    LDR R0, =const_double_3
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
    @ Empilhar número 1.0
    LDR R0, =const_double_10
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 2.0
    LDR R0, =const_double_1
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
    @ Empilhar número 100.0
    LDR R0, =const_double_13
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
    @ Comando MEM: recuperar valor
    VLDR D0, [R10]         @ D0 = valor da memória
    SUB SP, SP, #8
    VSTR D0, [SP]          @ Empilhar valor recuperado

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
    @ Empilhar número 1
    LDR R0, =const_double_14
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
    BGE hex_pos_58
hex_neg_57:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_58:
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
    @ Empilhar número 3.0
    LDR R0, =const_double_15
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 4.0
    LDR R0, =const_double_4
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
    @ Empilhar número 2.0
    LDR R0, =const_double_1
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 3.0
    LDR R0, =const_double_15
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
    BGE hex_pos_62
hex_neg_61:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_62:
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
    @ Empilhar número 7.5
    LDR R0, =const_double_16
    VLDR D0, [R0]
    SUB SP, SP, #8
    VSTR D0, [SP]
    @ Empilhar número 2.5
    LDR R0, =const_double_12
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
    BGE hex_pos_66
hex_neg_65:
    RSB R0, R0, #0         @ R0 = abs(resultado)
hex_pos_66:
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
const_double_0:    @ 3.14
    .word 0x51EB851F    @ low word
    .word 0x40091EB8    @ high word
const_double_1:    @ 2.0
    .word 0x00000000    @ low word
    .word 0x40000000    @ high word
const_double_2:    @ 10.5
    .word 0x00000000    @ low word
    .word 0x40250000    @ high word
const_double_3:    @ 3.5
    .word 0x00000000    @ low word
    .word 0x400C0000    @ high word
const_double_4:    @ 4.0
    .word 0x00000000    @ low word
    .word 0x40100000    @ high word
const_double_5:    @ 5.0
    .word 0x00000000    @ low word
    .word 0x40140000    @ high word
const_double_6:    @ 20.0
    .word 0x00000000    @ low word
    .word 0x40340000    @ high word
const_double_7:    @ 17
    .word 0x00000000    @ low word
    .word 0x40310000    @ high word
const_double_8:    @ 5
    .word 0x00000000    @ low word
    .word 0x40140000    @ high word
const_double_9:    @ 10
    .word 0x00000000    @ low word
    .word 0x40240000    @ high word
const_double_10:    @ 1.0
    .word 0x00000000    @ low word
    .word 0x3FF00000    @ high word
const_double_11:    @ 10.0
    .word 0x00000000    @ low word
    .word 0x40240000    @ high word
const_double_12:    @ 2.5
    .word 0x00000000    @ low word
    .word 0x40040000    @ high word
const_double_13:    @ 100.0
    .word 0x00000000    @ low word
    .word 0x40590000    @ high word
const_double_14:    @ 1
    .word 0x00000000    @ low word
    .word 0x3FF00000    @ high word
const_double_15:    @ 3.0
    .word 0x00000000    @ low word
    .word 0x40080000    @ high word
const_double_16:    @ 7.5
    .word 0x00000000    @ low word
    .word 0x401E0000    @ high word

@ Array de resultados (até 64 expressões)
resultados:
    .space 512             @ 64 * 8 bytes

@ Memória MEM (1 double)
mem_storage:
    .space 8
