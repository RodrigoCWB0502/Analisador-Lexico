#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
=============================================================================
Funções de Teste para o Analisador Léxico
=============================================================================
Testa o AFD com entradas válidas e inválidas conforme exigido no enunciado.
"""

import sys
sys.path.insert(0, '.')

from main import (
    AnalisadorLexico, ExecutorExpressao, GeradorAssembly,
    TOKEN_NUMERO, TOKEN_OPERADOR, TOKEN_ABRE_PAR, TOKEN_FECHA_PAR,
    TOKEN_RES, TOKEN_MEM, TOKEN_INVALIDO
)


def teste_separador():
    print("\n" + "=" * 60)


# =============================================================================
# TESTES DO ANALISADOR LÉXICO (AFD)
# =============================================================================

def teste_numeros_validos():
    """Testa reconhecimento de números válidos pelo AFD."""
    print("\n[TESTE] Números válidos")
    print("-" * 40)
    analisador = AnalisadorLexico()

    casos = [
        ("3.14", TOKEN_NUMERO, "3.14"),
        ("2.0", TOKEN_NUMERO, "2.0"),
        ("42", TOKEN_NUMERO, "42"),
        ("0.5", TOKEN_NUMERO, "0.5"),
        ("100.001", TOKEN_NUMERO, "100.001"),
        ("0", TOKEN_NUMERO, "0"),
        ("999999.999999", TOKEN_NUMERO, "999999.999999"),
    ]

    passou = 0
    for entrada, tipo_esperado, valor_esperado in casos:
        tokens = analisador.parseExpressao(entrada)
        ok = (len(tokens) == 1 and tokens[0].tipo == tipo_esperado and tokens[0].valor == valor_esperado)
        status = "OK" if ok else "FALHOU"
        if ok:
            passou += 1
        print(f"  '{entrada}' -> {status} (obtido: {tokens[0] if tokens else 'vazio'})")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_numeros_invalidos():
    """Testa detecção de números malformados pelo AFD."""
    print("\n[TESTE] Números inválidos (malformados)")
    print("-" * 40)
    analisador = AnalisadorLexico()

    casos = [
        "3.14.5",     # Dois pontos decimais
        "3.14.5.6",   # Múltiplos pontos
        "3,45",       # Vírgula ao invés de ponto
    ]

    passou = 0
    for entrada in casos:
        tokens = analisador.parseExpressao(entrada)
        tem_invalido = any(t.tipo == TOKEN_INVALIDO for t in tokens)
        status = "OK" if tem_invalido else "FALHOU"
        if tem_invalido:
            passou += 1
        print(f"  '{entrada}' -> {status} (detectou inválido: {tem_invalido})")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_operadores_validos():
    """Testa reconhecimento de operadores válidos."""
    print("\n[TESTE] Operadores válidos")
    print("-" * 40)
    analisador = AnalisadorLexico()

    casos = [
        ("(3.14 2.0 +)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_NUMERO, TOKEN_OPERADOR, TOKEN_FECHA_PAR]),
        ("(5 3 -)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_NUMERO, TOKEN_OPERADOR, TOKEN_FECHA_PAR]),
        ("(2 4 *)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_NUMERO, TOKEN_OPERADOR, TOKEN_FECHA_PAR]),
        ("(10 3 /)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_NUMERO, TOKEN_OPERADOR, TOKEN_FECHA_PAR]),
        ("(10 3 //)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_NUMERO, TOKEN_OPERADOR, TOKEN_FECHA_PAR]),
        ("(10 3 %)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_NUMERO, TOKEN_OPERADOR, TOKEN_FECHA_PAR]),
        ("(2 3 ^)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_NUMERO, TOKEN_OPERADOR, TOKEN_FECHA_PAR]),
    ]

    passou = 0
    for entrada, tipos_esperados in casos:
        tokens = analisador.parseExpressao(entrada)
        tipos_obtidos = [t.tipo for t in tokens]
        ok = tipos_obtidos == tipos_esperados
        status = "OK" if ok else "FALHOU"
        if ok:
            passou += 1
        print(f"  '{entrada}' -> {status}")
        if not ok:
            print(f"    Esperado: {tipos_esperados}")
            print(f"    Obtido:   {tipos_obtidos}")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_operadores_invalidos():
    """Testa detecção de operadores inválidos."""
    print("\n[TESTE] Operadores inválidos")
    print("-" * 40)
    analisador = AnalisadorLexico()

    casos = [
        "(3.14 2.0 &)",   # & não é operador válido
        "(3.14 2.0 @)",   # @ não é operador válido
        "(3.14 2.0 !)",   # ! não é operador válido
    ]

    passou = 0
    for entrada in casos:
        tokens = analisador.parseExpressao(entrada)
        tem_invalido = any(t.tipo == TOKEN_INVALIDO for t in tokens)
        status = "OK" if tem_invalido else "FALHOU"
        if tem_invalido:
            passou += 1
        print(f"  '{entrada}' -> {status} (detectou inválido: {tem_invalido})")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_comandos_especiais():
    """Testa reconhecimento de RES e MEM."""
    print("\n[TESTE] Comandos especiais (RES, MEM)")
    print("-" * 40)
    analisador = AnalisadorLexico()

    casos = [
        ("(5 RES)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_RES, TOKEN_FECHA_PAR]),
        ("(3.14 MEM)", [TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_MEM, TOKEN_FECHA_PAR]),
        ("(MEM)", [TOKEN_ABRE_PAR, TOKEN_MEM, TOKEN_FECHA_PAR]),
    ]

    passou = 0
    for entrada, tipos_esperados in casos:
        tokens = analisador.parseExpressao(entrada)
        tipos_obtidos = [t.tipo for t in tokens]
        ok = tipos_obtidos == tipos_esperados
        status = "OK" if ok else "FALHOU"
        if ok:
            passou += 1
        print(f"  '{entrada}' -> {status}")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_identificadores_invalidos():
    """Testa detecção de identificadores inválidos (ex: CONTADOr)."""
    print("\n[TESTE] Identificadores inválidos")
    print("-" * 40)
    analisador = AnalisadorLexico()

    casos = [
        "(10.5 CONTADOr)",   # Identificador desconhecido
        "(5 ABC)",           # Identificador desconhecido
        "(2 XYZ123)",        # Identificador desconhecido
    ]

    passou = 0
    for entrada in casos:
        tokens = analisador.parseExpressao(entrada)
        tem_invalido = any(t.tipo == TOKEN_INVALIDO for t in tokens)
        status = "OK" if tem_invalido else "FALHOU"
        if tem_invalido:
            passou += 1
        print(f"  '{entrada}' -> {status} (detectou inválido: {tem_invalido})")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_parenteses():
    """Testa reconhecimento de parênteses."""
    print("\n[TESTE] Parênteses")
    print("-" * 40)
    analisador = AnalisadorLexico()

    casos = [
        ("()", [TOKEN_ABRE_PAR, TOKEN_FECHA_PAR]),
        ("((3 4 +))", [TOKEN_ABRE_PAR, TOKEN_ABRE_PAR, TOKEN_NUMERO, TOKEN_NUMERO,
                       TOKEN_OPERADOR, TOKEN_FECHA_PAR, TOKEN_FECHA_PAR]),
    ]

    passou = 0
    for entrada, tipos_esperados in casos:
        tokens = analisador.parseExpressao(entrada)
        tipos_obtidos = [t.tipo for t in tokens]
        ok = tipos_obtidos == tipos_esperados
        status = "OK" if ok else "FALHOU"
        if ok:
            passou += 1
        print(f"  '{entrada}' -> {status}")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_expressoes_aninhadas():
    """Testa expressões aninhadas complexas."""
    print("\n[TESTE] Expressões aninhadas")
    print("-" * 40)
    analisador = AnalisadorLexico()

    casos = [
        "(3.14 (2.0 1.0 +) *)",           # Aninhamento simples
        "((1.5 2.0 *) (3.0 4.0 *) /)",    # Dois sub-expressões
        "((2.0 3.0 +) (4.0 5.0 *) /)",    # Exemplo do enunciado
        "(((1.0 2.0 +) 3.0 *) 4.0 -)",    # Triplo aninhamento
    ]

    passou = 0
    for entrada in casos:
        tokens = analisador.parseExpressao(entrada)
        tem_erro = any(t.tipo == TOKEN_INVALIDO for t in tokens)
        # Verificar balanceamento de parênteses
        abre = sum(1 for t in tokens if t.tipo == TOKEN_ABRE_PAR)
        fecha = sum(1 for t in tokens if t.tipo == TOKEN_FECHA_PAR)
        balanceado = (abre == fecha)
        ok = not tem_erro and balanceado
        status = "OK" if ok else "FALHOU"
        if ok:
            passou += 1
        print(f"  '{entrada}' -> {status} (erros={tem_erro}, balanceado={balanceado})")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_expressoes_completas():
    """Testa o fluxo completo: análise léxica -> execução."""
    print("\n[TESTE] Fluxo completo (análise + execução para validação)")
    print("-" * 40)
    analisador = AnalisadorLexico()
    executor = ExecutorExpressao()

    casos = [
        ("(3.0 2.0 +)", 5.0),
        ("(10.0 3.0 -)", 7.0),
        ("(4.0 5.0 *)", 20.0),
        ("(10.0 2.0 /)", 5.0),
        ("(10 3 //)", 3.0),
        ("(10 3 %)", 1.0),
        ("(2.0 3 ^)", 8.0),
    ]

    passou = 0
    for entrada, esperado in casos:
        tokens = analisador.parseExpressao(entrada)
        resultado = executor.executarExpressao(tokens)
        ok = resultado is not None and abs(resultado - esperado) < 0.001
        status = "OK" if ok else "FALHOU"
        if ok:
            passou += 1
        print(f"  '{entrada}' -> {status} (esperado={esperado}, obtido={resultado})")

    print(f"  Resultado: {passou}/{len(casos)} passaram")
    return passou == len(casos)


def teste_geracao_assembly():
    """Testa se a geração de Assembly produz código válido."""
    print("\n[TESTE] Geração de Assembly")
    print("-" * 40)
    analisador = AnalisadorLexico()
    gerador = GeradorAssembly()

    expressoes = [
        "(3.14 2.0 +)",
        "((1.5 2.0 *) (3.0 4.0 *) /)",
        "(5.0 MEM)",
        "(10.0 3 //)",
    ]

    todas_tokens = []
    for expr in expressoes:
        tokens = analisador.parseExpressao(expr)
        todas_tokens.append(tokens)

    assembly = gerador.gerarAssembly(todas_tokens)

    # Verificações básicas
    testes = [
        ("Contém .text", ".text" in assembly),
        ("Contém _start", "_start:" in assembly),
        ("Contém .data", ".data" in assembly),
        ("Contém VADD ou VSUB ou VMUL", any(x in assembly for x in ["VADD", "VSUB", "VMUL"])),
        ("Contém VLDR", "VLDR" in assembly),
        ("Contém VSTR", "VSTR" in assembly),
        ("Contém halt", "halt:" in assembly),
        ("Contém hex_table", "hex_table:" in assembly),
        ("Contém constantes double", "const_double_" in assembly),
        ("Contém VFP enable", "FPEXC" in assembly),
    ]

    passou = 0
    for descricao, ok in testes:
        status = "OK" if ok else "FALHOU"
        if ok:
            passou += 1
        print(f"  {descricao}: {status}")

    print(f"  Resultado: {passou}/{len(testes)} passaram")
    print(f"  Tamanho do Assembly gerado: {len(assembly)} caracteres, {assembly.count(chr(10))} linhas")
    return passou == len(testes)


# =============================================================================
# EXECUÇÃO DOS TESTES
# =============================================================================

def executar_todos_testes():
    """Executa todos os testes e exibe um resumo."""
    print("=" * 60)
    print("EXECUÇÃO DE TESTES DO ANALISADOR LÉXICO")
    print("=" * 60)

    testes = [
        ("Números válidos", teste_numeros_validos),
        ("Números inválidos", teste_numeros_invalidos),
        ("Operadores válidos", teste_operadores_validos),
        ("Operadores inválidos", teste_operadores_invalidos),
        ("Comandos especiais", teste_comandos_especiais),
        ("Identificadores inválidos", teste_identificadores_invalidos),
        ("Parênteses", teste_parenteses),
        ("Expressões aninhadas", teste_expressoes_aninhadas),
        ("Fluxo completo", teste_expressoes_completas),
        ("Geração de Assembly", teste_geracao_assembly),
    ]

    resultados = []
    for nome, func in testes:
        resultado = func()
        resultados.append((nome, resultado))

    # Resumo
    print("\n" + "=" * 60)
    print("RESUMO DOS TESTES")
    print("=" * 60)
    total_ok = 0
    for nome, ok in resultados:
        status = "PASSOU" if ok else "FALHOU"
        emoji = "+" if ok else "-"
        if ok:
            total_ok += 1
        print(f"  [{emoji}] {nome}: {status}")

    print(f"\n  Total: {total_ok}/{len(resultados)} testes passaram")
    print("=" * 60)

    return total_ok == len(resultados)


if __name__ == "__main__":
    sucesso = executar_todos_testes()
    sys.exit(0 if sucesso else 1)
