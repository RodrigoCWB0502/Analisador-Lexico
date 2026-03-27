"""
=============================================================================
Analisador Léxico e Gerador de Assembly ARMv7 - Fase 1
=============================================================================
Instituição: PUCPR - Pontifícia Universidade Católica do Paraná
Disciplina:  Construção de Interpretadores
Professor:   Professor Frank Coelho de Alcantara

Integrantes do Grupo (ordem alfabética):
  - André Luís Oliveira Ferreira da Silva - GitHub: AndreLuis-DEV
  - Bruno Rodolfo da Silveira - GitHub: BrunoRodolfoo
  - Erick Otto Polzin - GitHub: ErickPolzin
  - Rodrigo Granado Bittencourt - GitHub: RodrigoCWB0502

Grupo no AVA: Equipe 05

Repositório: https://github.com/RodrigoCWB0502/Analisador-Lexico
=============================================================================

Este programa:
1. Lê um arquivo de texto com expressões RPN
2. Realiza análise léxica usando AFD (Autômato Finito Determinístico)
   com estados implementados como funções
3. Gera código Assembly ARMv7 compatível com CPUlator DE1-SoC (v16.1)

IMPORTANTE: Nenhum cálculo é realizado em Python.
            Todo cálculo é feito no Assembly gerado.
"""

import sys
import json
import struct


# =============================================================================
# PARTE 1 - ANALISADOR LÉXICO (AFD com estados como funções)
# =============================================================================

# Tipos de tokens reconhecidos pela linguagem
TOKEN_NUMERO    = "NUMERO"
TOKEN_OPERADOR  = "OPERADOR"
TOKEN_ABRE_PAR  = "ABRE_PAREN"
TOKEN_FECHA_PAR = "FECHA_PAREN"
TOKEN_RES       = "RES"
TOKEN_MEM       = "MEM"
TOKEN_INVALIDO  = "INVALIDO"


class Token:
    """Representa um token identificado pelo analisador léxico."""
    def __init__(self, tipo, valor, posicao):
        self.tipo = tipo
        self.valor = valor
        self.posicao = posicao

    def __repr__(self):
        return f"Token({self.tipo}, '{self.valor}', pos={self.posicao})"

    def to_dict(self):
        return {"tipo": self.tipo, "valor": self.valor, "posicao": self.posicao}


class AnalisadorLexico:
    """
    Analisador Léxico baseado em Autômato Finito Determinístico (AFD).
    Cada estado do autômato é implementado como uma função/método.

    Estados do AFD:
    - estado_inicial: ponto de partida, decide para qual estado transitar
    - estado_numero: reconhece números inteiros e reais (ex: 3, 3.14)
    - estado_operador: reconhece operadores (+, -, *, /, //, %, ^)
    - estado_parenteses: reconhece ( e )
    - estado_identificador: reconhece palavras-chave (RES, MEM)
    - estado_erro: trata tokens inválidos
    """

    def __init__(self):
        self.tokens = []
        self.linha = ""
        self.pos = 0
        self.erros = []

    def parseExpressao(self, linha):
        """
        Função principal do analisador léxico.
        Recebe uma linha de texto e retorna um vetor de tokens.

        Corresponde à função parseExpressao(linha, tokens) do enunciado.
        """
        self.tokens = []
        self.linha = linha
        self.pos = 0
        self.erros = []

        while self.pos < len(self.linha):
            # Pula espaços em branco
            if self.linha[self.pos] == ' ' or self.linha[self.pos] == '\t':
                self.pos += 1
                continue

            # Estado inicial - decide a transição
            self.estado_inicial()

        return self.tokens

    def estado_inicial(self):
        """
        Estado inicial do AFD.
        Analisa o caractere atual e faz a transição para o estado adequado.
        """
        if self.pos >= len(self.linha):
            return

        c = self.linha[self.pos]

        if c == '(' or c == ')':
            self.estado_parenteses()
        elif c.isdigit():
            self.estado_numero()
        elif c == '.':
            # Ponto no início - pode ser número como .5
            self.estado_numero()
        elif c in ('+', '-', '*', '/', '%', '^'):
            # Verificar se é operador ou número negativo
            # Um '-' é número negativo se:
            #   - está no início ou após '('
            #   - e o próximo char é dígito ou ponto
            if c == '-' and self._pode_ser_numero_negativo():
                self.estado_numero()
            else:
                self.estado_operador()
        elif c.isalpha():
            self.estado_identificador()
        else:
            self.estado_erro()

    def _pode_ser_numero_negativo(self):
        """Verifica se um '-' pode ser interpretado como início de número negativo."""
        # Próximo caractere deve ser dígito ou ponto
        if self.pos + 1 < len(self.linha):
            proximo = self.linha[self.pos + 1]
            if proximo.isdigit() or proximo == '.':
                # Deve estar após ( ou ser o primeiro token significativo
                # Verificar último token não-espaço
                if len(self.tokens) == 0:
                    return True
                ultimo = self.tokens[-1]
                if ultimo.tipo == TOKEN_ABRE_PAR:
                    return True
                # Se o último token é outro operador ou abre parêntese
                if ultimo.tipo == TOKEN_OPERADOR:
                    return True
        return False

    def estado_numero(self):
        """
        Estado do AFD que reconhece números reais.
        Formato válido: [sinal]digitos[.digitos]
        Detecta erros como múltiplos pontos decimais (ex: 3.14.5)
        """
        inicio = self.pos
        tem_ponto = False
        tem_digito = False

        # Aceitar sinal negativo opcional
        if self.pos < len(self.linha) and self.linha[self.pos] == '-':
            self.pos += 1

        # Aceitar ponto no início (.5 => 0.5)
        if self.pos < len(self.linha) and self.linha[self.pos] == '.':
            tem_ponto = True
            self.pos += 1

        # Consumir dígitos
        while self.pos < len(self.linha) and self.linha[self.pos].isdigit():
            tem_digito = True
            self.pos += 1

        # Verificar ponto decimal
        if self.pos < len(self.linha) and self.linha[self.pos] == '.':
            if tem_ponto:
                # Segundo ponto - ERRO: número malformado como 3.14.5
                # Consumir o resto até espaço ou parêntese para reportar erro completo
                self.pos += 1
                while self.pos < len(self.linha) and self.linha[self.pos] not in (' ', '\t', '(', ')'):
                    self.pos += 1
                valor = self.linha[inicio:self.pos]
                erro_msg = f"Número malformado '{valor}' na posição {inicio}"
                self.erros.append(erro_msg)
                self.tokens.append(Token(TOKEN_INVALIDO, valor, inicio))
                return
            tem_ponto = True
            self.pos += 1

            # Dígitos após o ponto
            while self.pos < len(self.linha) and self.linha[self.pos].isdigit():
                tem_digito = True
                self.pos += 1

            # Verificar se há OUTRO ponto (ex: 3.14.5)
            if self.pos < len(self.linha) and self.linha[self.pos] == '.':
                # Consumir tudo até delimitador
                while self.pos < len(self.linha) and self.linha[self.pos] not in (' ', '\t', '(', ')'):
                    self.pos += 1
                valor = self.linha[inicio:self.pos]
                erro_msg = f"Número malformado '{valor}' na posição {inicio}"
                self.erros.append(erro_msg)
                self.tokens.append(Token(TOKEN_INVALIDO, valor, inicio))
                return

        # Verificar se reconheceu pelo menos um dígito
        if not tem_digito:
            valor = self.linha[inicio:self.pos]
            erro_msg = f"Número malformado '{valor}' na posição {inicio}"
            self.erros.append(erro_msg)
            self.tokens.append(Token(TOKEN_INVALIDO, valor, inicio))
            return

        # Verificar se o próximo char é letra (ex: 3.14abc)
        if self.pos < len(self.linha) and self.linha[self.pos].isalpha():
            while self.pos < len(self.linha) and self.linha[self.pos] not in (' ', '\t', '(', ')'):
                self.pos += 1
            valor = self.linha[inicio:self.pos]
            erro_msg = f"Token inválido '{valor}' na posição {inicio}"
            self.erros.append(erro_msg)
            self.tokens.append(Token(TOKEN_INVALIDO, valor, inicio))
            return

        valor = self.linha[inicio:self.pos]
        self.tokens.append(Token(TOKEN_NUMERO, valor, inicio))

    def estado_operador(self):
        """
        Estado do AFD que reconhece operadores.
        Operadores válidos: +, -, *, /, //, %, ^
        """
        inicio = self.pos
        c = self.linha[self.pos]

        if c == '/':
            # Verificar se é // (divisão inteira) ou / (divisão real)
            if self.pos + 1 < len(self.linha) and self.linha[self.pos + 1] == '/':
                self.pos += 2
                self.tokens.append(Token(TOKEN_OPERADOR, "//", inicio))
            else:
                self.pos += 1
                self.tokens.append(Token(TOKEN_OPERADOR, "/", inicio))
        elif c in ('+', '-', '*', '%', '^'):
            self.pos += 1
            self.tokens.append(Token(TOKEN_OPERADOR, c, inicio))
        else:
            self.estado_erro()

    def estado_parenteses(self):
        """
        Estado do AFD que reconhece parênteses.
        """
        c = self.linha[self.pos]
        if c == '(':
            self.tokens.append(Token(TOKEN_ABRE_PAR, "(", self.pos))
        else:
            self.tokens.append(Token(TOKEN_FECHA_PAR, ")", self.pos))
        self.pos += 1

    def estado_identificador(self):
        """
        Estado do AFD que reconhece identificadores/palavras-chave.
        Palavras-chave válidas: RES, MEM
        Qualquer outro identificador é um token inválido.
        """
        inicio = self.pos
        while self.pos < len(self.linha) and (self.linha[self.pos].isalpha() or self.linha[self.pos].isdigit() or self.linha[self.pos] == '_'):
            self.pos += 1

        valor = self.linha[inicio:self.pos]
        valor_upper = valor.upper()

        if valor_upper == "RES":
            self.tokens.append(Token(TOKEN_RES, valor, inicio))
        elif valor_upper == "MEM":
            self.tokens.append(Token(TOKEN_MEM, valor, inicio))
        else:
            erro_msg = f"Identificador inválido '{valor}' na posição {inicio}"
            self.erros.append(erro_msg)
            self.tokens.append(Token(TOKEN_INVALIDO, valor, inicio))

    def estado_erro(self):
        """
        Estado de erro do AFD.
        Consome caracteres inválidos até encontrar um delimitador.
        """
        inicio = self.pos
        while self.pos < len(self.linha) and self.linha[self.pos] not in (' ', '\t', '(', ')'):
            self.pos += 1

        valor = self.linha[inicio:self.pos]
        erro_msg = f"Token inválido '{valor}' na posição {inicio}"
        self.erros.append(erro_msg)
        self.tokens.append(Token(TOKEN_INVALIDO, valor, inicio))


# =============================================================================
# PARTE 2 - EXECUÇÃO DE EXPRESSÕES (para validação/testes)
# =============================================================================

class ExecutorExpressao:
    """
    Executa expressões RPN a partir dos tokens para fins de VALIDAÇÃO.

    NOTA: Esta classe é usada apenas para TESTES e VALIDAÇÃO.
    Os cálculos reais são feitos no Assembly gerado.

    Gerencia memória (MEM) e histórico de resultados (RES).
    """

    def __init__(self):
        self.resultados = []      # Histórico de resultados
        self.memoria = {}         # Dicionário de memória {nome: valor}
        self.mem_valor = None     # Último valor armazenado com MEM

    def executarExpressao(self, tokens):
        """
        Executa uma expressão RPN a partir de uma lista de tokens.
        Usa uma pilha para avaliar as expressões.

        IMPORTANTE: Esta função existe apenas para VALIDAÇÃO.
        O cálculo real é feito no Assembly ARMv7 gerado.
        """
        try:
            resultado = self._avaliar_tokens(tokens, 0)
            if resultado is not None:
                self.resultados.append(resultado)
            return resultado
        except Exception as e:
            print(f"  [ERRO na execução] {e}")
            return None

    def _avaliar_tokens(self, tokens, inicio):
        """
        Avalia recursivamente os tokens de uma expressão RPN.
        Retorna (valor, próximo_índice).
        """
        pilha = []
        i = inicio

        while i < len(tokens):
            token = tokens[i]

            if token.tipo == TOKEN_ABRE_PAR:
                # Início de sub-expressão - avaliar recursivamente
                val, i = self._avaliar_subexpressao(tokens, i + 1)
                if val is not None:
                    pilha.append(val)
                continue

            elif token.tipo == TOKEN_NUMERO:
                pilha.append(float(token.valor))
                i += 1

            elif token.tipo == TOKEN_RES:
                # (N RES) - recupera o N-ésimo resultado anterior
                if len(pilha) >= 1:
                    n = int(pilha.pop())
                    if 0 < n <= len(self.resultados):
                        pilha.append(self.resultados[-n])
                    else:
                        print(f"  [ERRO] RES: índice {n} fora do intervalo")
                        return None
                i += 1

            elif token.tipo == TOKEN_MEM:
                if len(pilha) >= 1:
                    # (V MEM) - armazena valor na memória
                    self.mem_valor = pilha[-1]  # Mantém na pilha também
                else:
                    # (MEM) - recupera valor da memória
                    if self.mem_valor is not None:
                        pilha.append(self.mem_valor)
                    else:
                        print("  [ERRO] MEM: nenhum valor armazenado")
                        return None
                i += 1

            elif token.tipo == TOKEN_OPERADOR:
                if len(pilha) < 2:
                    print(f"  [ERRO] Operador '{token.valor}' sem operandos suficientes")
                    return None
                b = pilha.pop()
                a = pilha.pop()
                resultado = self._aplicar_operacao(a, b, token.valor)
                if resultado is not None:
                    pilha.append(resultado)
                i += 1

            elif token.tipo == TOKEN_FECHA_PAR:
                i += 1
                break

            else:
                i += 1

        if pilha:
            return pilha[-1]
        return None

    def _avaliar_subexpressao(self, tokens, inicio):
        """Avalia uma sub-expressão delimitada por parênteses."""
        pilha = []
        i = inicio

        while i < len(tokens):
            token = tokens[i]

            if token.tipo == TOKEN_ABRE_PAR:
                val, i = self._avaliar_subexpressao(tokens, i + 1)
                if val is not None:
                    pilha.append(val)
                continue

            elif token.tipo == TOKEN_FECHA_PAR:
                i += 1
                if pilha:
                    return pilha[-1], i
                return None, i

            elif token.tipo == TOKEN_NUMERO:
                pilha.append(float(token.valor))
                i += 1

            elif token.tipo == TOKEN_RES:
                if len(pilha) >= 1:
                    n = int(pilha.pop())
                    if 0 < n <= len(self.resultados):
                        pilha.append(self.resultados[-n])
                    else:
                        print(f"  [ERRO] RES: índice {n} fora do intervalo")
                i += 1

            elif token.tipo == TOKEN_MEM:
                if len(pilha) >= 1:
                    self.mem_valor = pilha[-1]
                else:
                    if self.mem_valor is not None:
                        pilha.append(self.mem_valor)
                i += 1

            elif token.tipo == TOKEN_OPERADOR:
                if len(pilha) >= 2:
                    b = pilha.pop()
                    a = pilha.pop()
                    resultado = self._aplicar_operacao(a, b, token.valor)
                    if resultado is not None:
                        pilha.append(resultado)
                i += 1

            else:
                i += 1

        if pilha:
            return pilha[-1], i
        return None, i

    def _aplicar_operacao(self, a, b, op):
        """Aplica uma operação aritmética (apenas para validação)."""
        if op == '+':
            return a + b
        elif op == '-':
            return a - b
        elif op == '*':
            return a * b
        elif op == '/':
            if b == 0:
                print("  [ERRO] Divisão por zero")
                return None
            return a / b
        elif op == '//':
            if b == 0:
                print("  [ERRO] Divisão inteira por zero")
                return None
            return float(int(a) // int(b))
        elif op == '%':
            if b == 0:
                print("  [ERRO] Módulo por zero")
                return None
            return float(int(a) % int(b))
        elif op == '^':
            return a ** int(b)
        return None


# =============================================================================
# PARTE 3 - GERADOR DE ASSEMBLY ARMv7
# =============================================================================

class GeradorAssembly:
    """
    Gera código Assembly ARMv7 compatível com CPUlator DE1-SoC (v16.1).

    O Assembly gerado utiliza:
    - Registradores VFP (d0-d15) para operações com ponto flutuante 64 bits
    - Uma pilha de software para empilhar/desempilhar valores double
    - Endereços de memória do DE1-SoC para I/O (LEDs, HEX displays)

    IMPORTANTE: Todo cálculo é feito no Assembly. O Python apenas gera o código.
    """

    # Endereços de I/O do DE1-SoC
    ADDR_LEDR    = "0xFF200000"   # LEDs vermelhos
    ADDR_HEX3_0  = "0xFF200020"   # Displays 7-seg HEX3-HEX0
    ADDR_HEX5_4  = "0xFF200030"   # Displays 7-seg HEX5-HEX4
    ADDR_SW      = "0xFF200040"   # Switches
    ADDR_KEY     = "0xFF200050"   # Push buttons

    # Tabela de segmentos para display 7-seg (0-9 e A-F)
    HEX_TABLE = [0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,
                 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71]

    def __init__(self):
        self.codigo = []
        self.label_counter = 0
        self.data_section = []
        self.resultados_count = 0
        self.mem_label = "mem_storage"
        self.res_labels = []
        self.double_constants = {}  # {valor_str: label}
        self.expr_count = 0

    def _nova_label(self, prefixo="L"):
        """Gera uma label única."""
        self.label_counter += 1
        return f"{prefixo}_{self.label_counter}"

    def _double_to_hex(self, valor_str):
        """
        Converte um número real (string) para representação IEEE 754 de 64 bits.
        Retorna (word_low, word_high) para uso com .word no Assembly.
        """
        valor = float(valor_str)
        # Empacota como double IEEE 754 (little-endian)
        packed = struct.pack('<d', valor)
        word_low = struct.unpack('<I', packed[0:4])[0]
        word_high = struct.unpack('<I', packed[4:8])[0]
        return word_low, word_high

    def _registrar_constante(self, valor_str):
        """Registra uma constante double na seção de dados e retorna a label."""
        if valor_str not in self.double_constants:
            label = f"const_double_{len(self.double_constants)}"
            self.double_constants[valor_str] = label
        return self.double_constants[valor_str]

    def gerarAssembly(self, todas_expressoes_tokens):
        """
        Função principal de geração de Assembly.
        Recebe uma lista de listas de tokens (uma por linha/expressão).
        Retorna o código Assembly completo como string.
        """
        self.codigo = []
        self.data_section = []
        self.double_constants = {}
        self.label_counter = 0
        self.resultados_count = 0
        self.expr_count = 0

        # Cabeçalho do programa Assembly
        self._gerar_cabecalho()

        # Gerar código para cada expressão
        total_expressoes = sum(1 for t in todas_expressoes_tokens if t and not any(tk.tipo == TOKEN_INVALIDO for tk in t))
        expr_geradas = 0

        for idx, tokens in enumerate(todas_expressoes_tokens):
            if not tokens:
                continue
            tem_invalido = any(t.tipo == TOKEN_INVALIDO for t in tokens)
            if tem_invalido:
                self.codigo.append(f"    @ Expressão {idx + 1} ignorada (contém tokens inválidos)")
                self.codigo.append("")
                continue

            self.expr_count += 1
            expr_geradas += 1
            self.codigo.append(f"    @ ========== Expressão {idx + 1} ==========")
            self._gerar_expressao(tokens)
            self.codigo.append("")

            self._gerar_salvar_resultado()
            self._gerar_exibir_resultado_hex()

            # Esperar KEY0 entre expressões (exceto na última)
            if expr_geradas < total_expressoes:
                self.codigo.append("    @ Pressione KEY0 para próxima expressão")
                self.codigo.append("    BL wait_key")
            self.codigo.append("")

            # A cada 3 expressões, forçar despejo do literal pool
            # Isso evita que LDR Rx, =label fique fora de alcance (máx 4095 bytes)
            if expr_geradas % 3 == 0:
                self.codigo.append("    B _skip_ltorg_" + str(expr_geradas))
                self.codigo.append("    .ltorg")
                self.codigo.append("_skip_ltorg_" + str(expr_geradas) + ":")
                self.codigo.append("")

        # Fim do programa
        self._gerar_rodape()

        # Gerar seção de dados
        self._gerar_secao_dados()

        # Montar código final
        codigo_final = "\n".join(self.codigo)
        return codigo_final

    def _gerar_cabecalho(self):
        """Gera o cabeçalho do programa Assembly."""
        self.codigo.extend([
            "@ =============================================================================",
            "@ Código Assembly ARMv7 - Gerado pelo Analisador Léxico",
            "@ Compatível com CPUlator DE1-SoC (v16.1)",
            "@ =============================================================================",
            "@ Instituição: PUCPR - Pontifícia Universidade Católica do Paraná",
            "@ Disciplina:  Construção de Interpretadores",
            "@ Professor:   Frank Coelho de Alcantara",
            "@ Grupo:       Equipe 05",
            "@ =============================================================================",
            "",
            ".text",
            ".global _start",
            "",
            "_start:",
            "    @ Inicializar stack pointer",
            "    LDR SP, =0x20000",
            "",
            "    @ Habilitar VFP (coprocessador de ponto flutuante)",
            "    MRC p15, 0, R0, c1, c0, 2",
            "    ORR R0, R0, #0xF00000      @ Habilitar acesso a CP10 e CP11",
            "    MCR p15, 0, R0, c1, c0, 2",
            "    MOV R0, #0x40000000         @ Setar EN bit no FPEXC",
            "    VMSR FPEXC, R0",
            "",
            "    @ Inicializar ponteiro de resultados",
            "    LDR R8, =resultados         @ R8 = ponteiro para array de resultados",
            "    MOV R9, #0                   @ R9 = contador de resultados",
            "",
            "    @ Inicializar memória (MEM)",
            "    LDR R10, =mem_storage        @ R10 = ponteiro para memória MEM",
            "",
        ])

    def _gerar_expressao(self, tokens):
        """
        Gera código Assembly para uma expressão RPN completa.
        Usa a pilha de hardware (SP) para empilhar valores double (8 bytes cada).
        Registradores VFP d0-d7 são usados como temporários.
        """
        i = [0]  # Usar lista para permitir modificação em closure

        def processar(tokens_list):
            while i[0] < len(tokens_list):
                token = tokens_list[i[0]]

                if token.tipo == TOKEN_ABRE_PAR:
                    i[0] += 1
                    processar(tokens_list)
                    continue

                elif token.tipo == TOKEN_FECHA_PAR:
                    i[0] += 1
                    return

                elif token.tipo == TOKEN_NUMERO:
                    # Carregar constante double e empilhar
                    label = self._registrar_constante(token.valor)
                    self.codigo.append(f"    @ Empilhar número {token.valor}")
                    self.codigo.append(f"    LDR R0, ={label}")
                    self.codigo.append(f"    VLDR D0, [R0]")
                    self.codigo.append(f"    SUB SP, SP, #8")
                    self.codigo.append(f"    VSTR D0, [SP]")
                    i[0] += 1

                elif token.tipo == TOKEN_OPERADOR:
                    self._gerar_operacao(token.valor)
                    i[0] += 1

                elif token.tipo == TOKEN_RES:
                    # (N RES) - pegar N da pilha, buscar resultado anterior
                    self._gerar_res()
                    i[0] += 1

                elif token.tipo == TOKEN_MEM:
                    self._gerar_mem(tokens_list, i[0])
                    i[0] += 1

                else:
                    i[0] += 1

        processar(tokens)

    def _gerar_operacao(self, op):
        """Gera código Assembly para uma operação aritmética."""
        self.codigo.append(f"    @ Operação: {op}")
        # Desempilhar B (topo) e A
        self.codigo.append(f"    VLDR D1, [SP]          @ B = topo da pilha")
        self.codigo.append(f"    ADD SP, SP, #8")
        self.codigo.append(f"    VLDR D0, [SP]          @ A = segundo da pilha")
        self.codigo.append(f"    ADD SP, SP, #8")

        if op == '+':
            self.codigo.append(f"    VADD.F64 D2, D0, D1   @ D2 = A + B")
        elif op == '-':
            self.codigo.append(f"    VSUB.F64 D2, D0, D1   @ D2 = A - B")
        elif op == '*':
            self.codigo.append(f"    VMUL.F64 D2, D0, D1   @ D2 = A * B")
        elif op == '/':
            self.codigo.append(f"    VDIV.F64 D2, D0, D1   @ D2 = A / B")
        elif op == '//':
            # Divisão inteira: converter para int, dividir, converter de volta
            label_loop = self._nova_label("div_int_loop")
            label_end = self._nova_label("div_int_end")
            self.codigo.extend([
                f"    @ Divisão inteira: converter para inteiro, dividir",
                f"    VCVT.S32.F64 S0, D0   @ S0 = (int)A",
                f"    VCVT.S32.F64 S1, D1   @ S1 = (int)B",
                f"    VMOV R0, S0            @ R0 = (int)A",
                f"    VMOV R1, S1            @ R1 = (int)B",
                f"    @ Divisão inteira por subtração repetida",
                f"    MOV R2, #0             @ R2 = quociente",
                f"    CMP R0, #0",
                f"    RSBLT R0, R0, #0       @ abs(A)",
                f"    CMP R1, #0",
                f"    RSBLT R1, R1, #0       @ abs(B)",
                f"{label_loop}:",
                f"    CMP R0, R1",
                f"    BLT {label_end}",
                f"    SUB R0, R0, R1",
                f"    ADD R2, R2, #1",
                f"    B {label_loop}",
                f"{label_end}:",
                f"    VMOV S0, R2",
                f"    VCVT.F64.S32 D2, S0   @ D2 = resultado como double",
            ])
        elif op == '%':
            # Resto da divisão inteira
            label_loop = self._nova_label("mod_loop")
            label_end = self._nova_label("mod_end")
            self.codigo.extend([
                f"    @ Resto da divisão inteira",
                f"    VCVT.S32.F64 S0, D0   @ S0 = (int)A",
                f"    VCVT.S32.F64 S1, D1   @ S1 = (int)B",
                f"    VMOV R0, S0            @ R0 = (int)A",
                f"    VMOV R1, S1            @ R1 = (int)B",
                f"    @ Módulo por subtração repetida",
                f"{label_loop}:",
                f"    CMP R0, R1",
                f"    BLT {label_end}",
                f"    SUB R0, R0, R1",
                f"    B {label_loop}",
                f"{label_end}:",
                f"    VMOV S0, R0            @ S0 = resto",
                f"    VCVT.F64.S32 D2, S0   @ D2 = resultado como double",
            ])
        elif op == '^':
            # Potenciação: A^B onde B é inteiro positivo
            label_loop = self._nova_label("pow_loop")
            label_end = self._nova_label("pow_end")
            self.codigo.extend([
                f"    @ Potenciação: A^B (B inteiro positivo)",
                f"    VCVT.S32.F64 S2, D1   @ S2 = (int)B  [S2=lower D1, preserva D0]",
                f"    VMOV R1, S2            @ R1 = expoente",
                f"    MOV R0, #1",
                f"    VMOV S4, R0            @ S4 = lower D2 (nao alias D0!)",
                f"    VCVT.F64.S32 D2, S4   @ D2 = 1.0 (acumulador, D0 preservado)",
                f"    CMP R1, #0",
                f"    BLE {label_end}",
                f"{label_loop}:",
                f"    VMUL.F64 D2, D2, D0   @ D2 = D2 * A",
                f"    SUBS R1, R1, #1",
                f"    BNE {label_loop}",
                f"{label_end}:",
            ])

        # Empilhar resultado
        self.codigo.append(f"    SUB SP, SP, #8")
        self.codigo.append(f"    VSTR D2, [SP]          @ Empilhar resultado")

    def _gerar_res(self):
        """Gera Assembly para comando RES: (N RES)."""
        self.codigo.extend([
            f"    @ Comando RES: buscar resultado anterior",
            f"    VLDR D0, [SP]          @ D0 = N (índice)",
            f"    ADD SP, SP, #8         @ Desempilhar N",
            f"    VCVT.S32.F64 S0, D0   @ Converter para inteiro",
            f"    VMOV R0, S0            @ R0 = N",
            f"    @ Calcular endereço: resultados + (R9 - R0) * 8",
            f"    SUB R1, R9, R0         @ R1 = total_resultados - N",
            f"    LSL R1, R1, #3         @ R1 = R1 * 8 (cada double = 8 bytes)",
            f"    ADD R1, R8, R1         @ R1 = endereço do resultado",
            f"    VLDR D2, [R1]          @ D2 = resultado buscado",
            f"    SUB SP, SP, #8",
            f"    VSTR D2, [SP]          @ Empilhar resultado buscado",
        ])

    def _gerar_mem(self, tokens, pos):
        """Gera Assembly para comando MEM: (V MEM) ou (MEM)."""
        # Verificar se é (V MEM) ou (MEM) checando se há valor na pilha antes
        # Heurística: se o token anterior é número ou fecha_paren, é (V MEM)
        is_store = False
        if pos > 0:
            prev = tokens[pos - 1]
            if prev.tipo in (TOKEN_NUMERO, TOKEN_FECHA_PAR):
                is_store = True

        if is_store:
            self.codigo.extend([
                f"    @ Comando MEM: armazenar valor",
                f"    VLDR D0, [SP]          @ D0 = valor no topo (não desempilha)",
                f"    VSTR D0, [R10]         @ Salvar na memória MEM",
            ])
        else:
            self.codigo.extend([
                f"    @ Comando MEM: recuperar valor",
                f"    VLDR D0, [R10]         @ D0 = valor da memória",
                f"    SUB SP, SP, #8",
                f"    VSTR D0, [SP]          @ Empilhar valor recuperado",
            ])

    def _gerar_salvar_resultado(self):
        """Salva o resultado da expressão no array de resultados."""
        self.codigo.extend([
            f"    @ Salvar resultado da expressão",
            f"    VLDR D0, [SP]          @ D0 = resultado",
            f"    ADD SP, SP, #8         @ Desempilhar",
            f"    LSL R1, R9, #3         @ R1 = R9 * 8",
            f"    ADD R1, R8, R1         @ R1 = endereço no array",
            f"    VSTR D0, [R1]          @ Salvar resultado",
            f"    ADD R9, R9, #1         @ Incrementar contador",
        ])
        self.resultados_count += 1

    def _gerar_exibir_resultado_hex(self):
        """
        Gera código para exibir a parte inteira do resultado nos displays HEX.
        Converte o double para inteiro e mostra nos displays 7-segmentos.
        """
        label_conv_loop = self._nova_label("hex_conv")
        label_conv_end = self._nova_label("hex_end")
        label_neg = self._nova_label("hex_neg")
        label_pos = self._nova_label("hex_pos")

        self.codigo.extend([
            f"    @ Exibir resultado nos displays HEX",
            f"    VCVT.S32.F64 S0, D0   @ Converter para inteiro",
            f"    VMOV R0, S0            @ R0 = parte inteira do resultado",
            f"    ",
            f"    @ Verificar sinal",
            f"    CMP R0, #0",
            f"    BGE {label_pos}",
            f"{label_neg}:",
            f"    RSB R0, R0, #0         @ R0 = abs(resultado)",
            f"{label_pos}:",
            f"    @ Converter para BCD e exibir nos HEX displays",
            f"    LDR R4, =hex_table     @ Tabela de segmentos",
            f"    MOV R3, #0             @ Acumulador de segmentos",
            f"    ",
            f"    @ Dígito 0 (unidades)",
            f"    MOV R1, #10",
            f"    BL div_mod             @ R0=quociente, R2=resto",
            f"    LDR R5, [R4, R2, LSL #2]  @ Segmento para dígito",
            f"    ORR R3, R3, R5         @ HEX0",
            f"    ",
            f"    @ Dígito 1 (dezenas)",
            f"    BL div_mod",
            f"    LDR R5, [R4, R2, LSL #2]",
            f"    ORR R3, R3, R5, LSL #8  @ HEX1",
            f"    ",
            f"    @ Dígito 2 (centenas)",
            f"    BL div_mod",
            f"    LDR R5, [R4, R2, LSL #2]",
            f"    ORR R3, R3, R5, LSL #16 @ HEX2",
            f"    ",
            f"    @ Dígito 3 (milhares)",
            f"    BL div_mod",
            f"    LDR R5, [R4, R2, LSL #2]",
            f"    ORR R3, R3, R5, LSL #24 @ HEX3",
            f"    ",
            f"    @ Escrever nos displays HEX3-HEX0",
            f"    LDR R6, ={self.ADDR_HEX3_0}",
            f"    STR R3, [R6]",
            f"    ",
            f"    @ Acender LEDs com padrão indicando expressão processada",
            f"    LDR R6, ={self.ADDR_LEDR}",
            f"    MOV R1, #1",
            f"    LSL R1, R1, R9          @ LED correspondente à expressão",
            f"    STR R1, [R6]",
        ])

    def _gerar_rodape(self):
        """Gera o final do programa Assembly."""
        self.codigo.extend([
            "    @ ========== Fim do programa ==========",
            "    @ Loop infinito (programa concluído)",
            "halt:",
            "    B halt",
            "",
            "@ ----- Sub-rotina: esperar botão KEY0 -----",
            "wait_key:",
            "    PUSH {R0-R1, LR}",
            "    LDR R1, =0xFF200050    @ KEY data register",
            "wait_key_press:",
            "    LDR R0, [R1]",
            "    TST R0, #1             @ Bit0=1 significa NÃO pressionado",
            "    BNE wait_key_press     @ Ainda não apertou, esperar",
            "    @ KEY0 pressionado, agora esperar soltar",
            "wait_key_release:",
            "    LDR R0, [R1]",
            "    TST R0, #1",
            "    BEQ wait_key_release   @ Ainda apertado, esperar soltar",
            "    POP {R0-R1, PC}",
            "",
            "@ ----- Sub-rotina: divisão e módulo -----",
            "@ Entrada: R0 = dividendo, R1 = divisor",
            "@ Saída: R0 = quociente, R2 = resto",
            "div_mod:",
            "    PUSH {LR}",
            "    MOV R2, R0             @ R2 = dividendo (será o resto)",
            "    MOV R0, #0             @ R0 = quociente",
            "div_mod_loop:",
            "    CMP R2, R1",
            "    BLT div_mod_end",
            "    SUB R2, R2, R1",
            "    ADD R0, R0, #1",
            "    B div_mod_loop",
            "div_mod_end:",
            "    POP {PC}",
            "",
        ])

    def _gerar_secao_dados(self):
        """Gera a seção .data com constantes e variáveis."""
        self.codigo.extend([
            "@ =============================================================================",
            "@ Seção de dados",
            "@ =============================================================================",
            ".data",
            "",
            "@ Tabela de segmentos para display 7-seg (0-F)",
            "hex_table:",
        ])

        for i, val in enumerate(self.HEX_TABLE):
            self.codigo.append(f"    .word 0x{val:02X}    @ {i:X}")

        self.codigo.extend([
            "",
            ".align 3                   @ Alinhar em 8 bytes para doubles",
            "@ Constantes double (IEEE 754 - 64 bits)",
        ])

        for valor_str, label in self.double_constants.items():
            low, high = self._double_to_hex(valor_str)
            self.codigo.extend([
                f"{label}:    @ {valor_str}",
                f"    .word 0x{low:08X}    @ low word",
                f"    .word 0x{high:08X}    @ high word",
            ])

        self.codigo.extend([
            "",
            "@ Array de resultados (até 64 expressões)",
            "resultados:",
            "    .space 512             @ 64 * 8 bytes",
            "",
            "@ Memória MEM (1 double)",
            "mem_storage:",
            "    .space 8",
            "",
        ])


# =============================================================================
# PARTE 4 - LEITURA DE ARQUIVO E INTERFACE
# =============================================================================

def lerArquivo(nomeArquivo):
    """
    Lê um arquivo de texto e retorna uma lista de linhas.
    Verifica erros de abertura e exibe mensagens claras.
    """
    try:
        with open(nomeArquivo, 'r', encoding='utf-8') as f:
            linhas = f.readlines()
        # Remover linhas vazias e whitespace
        linhas = [linha.strip() for linha in linhas if linha.strip()]
        return linhas
    except FileNotFoundError:
        print(f"[ERRO] Arquivo '{nomeArquivo}' não encontrado.")
        sys.exit(1)
    except PermissionError:
        print(f"[ERRO] Sem permissão para ler '{nomeArquivo}'.")
        sys.exit(1)
    except Exception as e:
        print(f"[ERRO] Falha ao ler '{nomeArquivo}': {e}")
        sys.exit(1)


def exibirResultados(resultados):
    """
    Exibe os resultados das expressões com formato claro.
    Uma casa decimal para números reais.
    """
    print("\n" + "=" * 60)
    print("RESULTADOS DAS EXPRESSÕES (validação Python)")
    print("=" * 60)
    for i, res in enumerate(resultados):
        if res is not None:
            # Verificar se é inteiro
            if res == int(res):
                print(f"  Expressão {i + 1}: {int(res)}")
            else:
                print(f"  Expressão {i + 1}: {res:.6f}")
        else:
            print(f"  Expressão {i + 1}: [ERRO]")
    print("=" * 60)


def salvar_tokens(todos_tokens, nome_arquivo):
    """
    Salva os tokens gerados em um arquivo .txt no formato JSON.
    Apenas os tokens da última execução ficam salvos.
    """
    dados = []
    for idx, tokens in enumerate(todos_tokens):
        linha_tokens = []
        for t in tokens:
            linha_tokens.append(t.to_dict())
        dados.append({
            "linha": idx + 1,
            "tokens": linha_tokens
        })

    nome_saida = nome_arquivo.replace('.txt', '_tokens.json')
    if nome_saida == nome_arquivo:
        nome_saida = "tokens_saida.json"

    with open(nome_saida, 'w', encoding='utf-8') as f:
        json.dump(dados, f, indent=2, ensure_ascii=False)

    print(f"\n[INFO] Tokens salvos em '{nome_saida}'")
    return nome_saida


def salvar_assembly(codigo_assembly, nome_arquivo):
    """Salva o código Assembly gerado em um arquivo .s"""
    nome_saida = nome_arquivo.replace('.txt', '.s')
    if nome_saida == nome_arquivo:
        nome_saida = "saida.s"

    with open(nome_saida, 'w', encoding='utf-8') as f:
        f.write(codigo_assembly)

    print(f"[INFO] Assembly salvo em '{nome_saida}'")
    return nome_saida


# =============================================================================
# FUNÇÃO MAIN
# =============================================================================

def main():
    """
    Função principal do programa.
    Gerencia a execução: leitura -> análise léxica -> execução -> assembly -> saída.
    """
    # Verificar argumento de linha de comando
    if len(sys.argv) < 2:
        print("Uso: python main.py <arquivo_teste.txt>")
        print("Exemplo: python main.py teste1.txt")
        sys.exit(1)

    nome_arquivo = sys.argv[1]

    print("=" * 60)
    print("ANALISADOR LÉXICO E GERADOR DE ASSEMBLY ARMv7")
    print("Equipe 05 - Fase 1")
    print("=" * 60)
    print(f"\nArquivo de entrada: {nome_arquivo}")

    # 1. Ler arquivo
    linhas = lerArquivo(nome_arquivo)
    print(f"Linhas lidas: {len(linhas)}")

    # 2. Análise léxica
    analisador = AnalisadorLexico()
    todos_tokens = []
    todos_erros = []

    print("\n--- ANÁLISE LÉXICA ---")
    for i, linha in enumerate(linhas):
        print(f"\nLinha {i + 1}: {linha}")
        tokens = analisador.parseExpressao(linha)
        todos_tokens.append(tokens)

        # Exibir tokens
        for token in tokens:
            print(f"  {token}")

        # Exibir erros
        if analisador.erros:
            for erro in analisador.erros:
                print(f"  [ERRO LÉXICO] {erro}")
            todos_erros.extend(analisador.erros)

    # 3. Salvar tokens
    salvar_tokens(todos_tokens, nome_arquivo)

    # 4. Executar expressões (VALIDAÇÃO apenas)
    print("\n--- EXECUÇÃO (VALIDAÇÃO PYTHON) ---")
    executor = ExecutorExpressao()
    resultados = []

    for i, tokens in enumerate(todos_tokens):
        # Pular linhas com erros
        tem_erro = any(t.tipo == TOKEN_INVALIDO for t in tokens)
        if tem_erro:
            print(f"  Expressão {i + 1}: IGNORADA (tokens inválidos)")
            resultados.append(None)
            continue

        resultado = executor.executarExpressao(tokens)
        resultados.append(resultado)
        if resultado is not None:
            print(f"  Expressão {i + 1}: {resultado}")

    # 5. Exibir resultados
    exibirResultados(resultados)

    # 6. Gerar Assembly
    print("\n--- GERAÇÃO DE ASSEMBLY ARMv7 ---")
    gerador = GeradorAssembly()
    codigo_assembly = gerador.gerarAssembly(todos_tokens)
    nome_asm = salvar_assembly(codigo_assembly, nome_arquivo)

    # 7. Resumo final
    print("\n" + "=" * 60)
    print("RESUMO")
    print("=" * 60)
    print(f"  Expressões processadas: {len(linhas)}")
    print(f"  Erros léxicos: {len(todos_erros)}")
    print(f"  Código Assembly: {nome_asm}")
    if todos_erros:
        print("\n  Erros encontrados:")
        for erro in todos_erros:
            print(f"    - {erro}")
    print("=" * 60)


if __name__ == "__main__":
    main()