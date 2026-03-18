"""
=============================================================================
Analisador Léxico e Gerador de Assembly ARMv7 - Fase 1
=============================================================================
Instituição: PUCPR - Pontifícia Universade Católica do Paraná
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
