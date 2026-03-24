# Analisador Léxico e Gerador de Assembly ARMv7 - Fase 1

## Informações Acadêmicas

- **Instituição:** PUCPR - Pontifícia Universidade Católica do Paraná
- **Disciplina:** Construção de Interpretadores
- **Professor:** Frank Coelho de Alcantara
- **Grupo:** Equipe 05

### Integrantes (ordem alfabética)

| Nome | GitHub |
|------|--------|
| André Luís Oliveira Ferreira da Silva | [@AndreLuis-DEV](https://github.com/AndreLuis-DEV) |
| Bruno Rodolfo da Silveira | [@BrunoRodolfoo](https://github.com/BrunoRodolfoo) |
| Erick Otto Polzin | [@ErickPolzin](https://github.com/ErickPolzin) |
| Rodrigo Granado Bittencourt | [@RodrigoCWB0502](https://github.com/RodrigoCWB0502) |

### Materiais Extras

- Vídeo do youtube [Link do vídeo](https://www.youtube.com/watch?v=QxHKSbjFquI)

- Documentação 01 [Link do Doc](https://medium.com/@pythonmembers.club/building-a-lexer-in-python-a-tutorial-3b6de161fe84)

---

## Descrição do Projeto

Programa em Python que realiza **análise léxica** de expressões aritméticas em **Notação Polonesa Reversa (RPN)** e gera **código Assembly ARMv7** compatível com o simulador **CPUlator DE1-SoC (v16.1)**.

### Funcionalidades

- Leitura de arquivo de texto com expressões RPN
- Análise léxica com **Autômato Finito Determinístico (AFD)** — cada estado é uma função
- Suporte a operadores: `+`, `-`, `*`, `/`, `//`, `%`, `^`
- Suporte a comandos especiais: `RES`, `MEM`
- Expressões aninhadas sem limite de profundidade
- Geração de código Assembly ARMv7 com VFP (ponto flutuante 64 bits IEEE 754)
- Exibição de resultados nos displays 7-segmentos e LEDs do DE1-SoC
- Tokens salvos em arquivo JSON

---

## Como Executar

### Pré-requisitos

- Python 3.6 ou superior
- Nenhuma biblioteca externa necessária

### Execução

```bash
python main.py teste1.txt
```

Substitua `teste1.txt` pelo arquivo de teste desejado (`teste2.txt`, `teste3.txt`).

### Executar Testes do Analisador Léxico

```bash
python testes.py
```

### Saídas Geradas

- `teste1_tokens.json` — Tokens extraídos pelo analisador léxico
- `teste1.s` — Código Assembly ARMv7 gerado

---

## Estrutura do Projeto

```
Analisador-Lexico/
├── main.py              # Código-fonte principal
├── testes.py            # Funções de teste do analisador léxico
├── teste1.txt           # Arquivo de teste 1
├── teste2.txt           # Arquivo de teste 2
├── teste3.txt           # Arquivo de teste 3
├── teste1_tokens.json   # Tokens da última execução
├── teste1.s             # Assembly ARMv7 da última execução
└── README.md            # Este arquivo
```

---

## Arquitetura do Sistema

### Funções Principais

| Função | Descrição |
|--------|-----------|
| `parseExpressao(linha)` | Analisa léxica de uma linha RPN, retorna vetor de tokens |
| `executarExpressao(tokens)` | Executa expressão para validação (NÃO faz cálculos finais) |
| `gerarAssembly(tokens)` | Gera código Assembly ARMv7 a partir dos tokens |
| `lerArquivo(nomeArquivo)` | Lê arquivo de entrada |
| `exibirResultados(resultados)` | Exibe resultados formatados |

### Estados do AFD (Autômato Finito Determinístico)

| Estado/Função | Reconhece |
|---------------|-----------|
| `estado_inicial` | Decide transição baseado no caractere atual |
| `estado_numero` | Números inteiros e reais (ex: `3`, `3.14`) |
| `estado_operador` | Operadores (`+`, `-`, `*`, `/`, `//`, `%`, `^`) |
| `estado_parenteses` | Parênteses `(` e `)` |
| `estado_identificador` | Palavras-chave `RES` e `MEM` |
| `estado_erro` | Tokens inválidos |

---

## Formato da Linguagem RPN

```
(A B op)          → Operação simples
(A (C D *) +)     → Expressões aninhadas
(V MEM)           → Armazenar valor na memória
(MEM)             → Recuperar valor da memória
(N RES)           → Recuperar N-ésimo resultado anterior
```

---

## Testando o Assembly no CPUlator

1. Abra o [CPUlator](https://cpulator.01xz.net/?sys=arm-de1soc)
2. Selecione **ARMv7 DE1-SoC (v16.1)**
3. Cole o conteúdo do arquivo `.s` gerado
4. Clique em **Compile and Load**
5. Clique em **Continue** para executar
6. Observe os resultados nos displays HEX e LEDs

---

## Observações Importantes

- **Nenhum cálculo é feito em Python** — o Python apenas lê, analisa e gera Assembly
- **Não foram usadas expressões regulares** — o AFD é implementado manualmente com funções
- **IEEE 754 64 bits** — todos os números reais usam precisão double
- A função `executarExpressao` existe apenas para **validação/testes**

<sub>[Repositorio_Do_Autor](https://github.com/RodrigoCWB0502/Analisador-Lexico)</sub>