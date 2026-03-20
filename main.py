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

