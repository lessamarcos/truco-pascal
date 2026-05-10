# 🃏 Truco em Pascal

Trabalho prático da disciplina de **Estrutura de Dados I** — BSI, UNIDAVI.

Implementação do jogo de Truco (modalidade paulista) em Pascal, com interface via terminal, rodando no compilador **Pascalzim**.

---

## 🎮 Como jogar

1. Abra o `programa.pas` no Pascalzim
2. Compile e execute
3. Escolha `1 - INICIAR` no menu principal
4. A cada rodada, escolha entre:
   - `1` — Jogar uma carta
   - `2` — Pedir Truco
   - `3` — Correr (se você for covarde)

O jogo vai até **12 pontos**. Boa sorte contra a CPU.

---

## 🧱 Estruturas de dados utilizadas

O projeto usa três estruturas clássicas de forma encadeada para simular o fluxo real de um baralho:

| Estrutura | Uso no jogo |
|-----------|-------------|
| **Lista** | Armazena e inicializa os 40 cards do baralho espanhol |
| **Pilha** (LIFO) | Representa o baralho empilhado após o embaralhamento |
| **Fila** (FIFO) | Simula o corte e a distribuição das cartas aos jogadores |

---

## ♠️ Regras implementadas

- Baralho espanhol com 40 cartas (sem 8, 9 e jokers)
- Embaralhamento via algoritmo **Fisher-Yates** (distribuição uniforme)
- **Manilha dinâmica** — definida pela carta virada, com casos especiais (7 → 10, 12 → 1)
- Manilhas têm força superior às demais, com hierarquia por naipe: Ouro < Espada < Copas < Paus
- Regras de desempate entre rodadas (quem ganha 2 de 3, empate na primeira conta quem ganhou a segunda, etc.)
- CPU joga sempre a carta de menor força (estratégia conservadora)
- CPU aceita truco se tiver carta forte (força ≥ 8) na mão
- Pedido de truco: 1 → 3 pontos
- Placar acumulado até 12 pontos

---

## 🛠️ Compilador

O projeto foi desenvolvido e testado exclusivamente no **[Pascalzim](http://pascalzim.com.br/)**.  
Não é garantida compatibilidade com Free Pascal ou Turbo Pascal.

---

## 👥 Equipe

Desenvolvido por **Marcos Gabriel Lessa**, **Luan Henrique Pinheiro** e **Carlos Miguel de Souza** — 3º semestre de BSI, UNIDAVI.
