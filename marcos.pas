program truco;
const 
    TAM_BARALHO = 40;
    TAM_MAO = 3;
    MAX_PONTOS = 12;
type
    Tcarta = record
        valor: integer;
        naipe: integer;
        forca: integer;
    end;

    Tlista = array [1..TAM_BARALHO] of Tcarta;

    Tpilha = record
        cartas: array [1..TAM_BARALHO] of Tcarta;
        topo: integer;
    end;

    Tfila = record
        cartas: array [1..TAM_BARALHO] of Tcarta;
        inicio: integer;
        fim: integer;
    end;

    Tmao = array [1..TAM_MAO] of Tcarta;


// a ideia aqui é auto explicativo, inicializar o baralho, é simples basta percorrer todos os nipes juntamente com todas as cartas, 
// percorre nipes e dentro de nipes o valor, pq cada número, deve ter 4 nipes. Aplica-se uma simples condicional pra filtrar se os
// números são diferentes de 8 e 9, caso sejam, coloca no baralho.

procedure inicializarBaralho(var l: Tlista);
var cartas, valor, naipe: integer;
begin
    cartas:= 1;
    for naipe:= 1 to 4 do
        for valor:= 1 to 12 do
        begin
            if (valor <> 8) and (valor <> 9) then 
            begin
                l[cartas].valor:= valor;
                l[cartas].naipe:= naipe;
                cartas:= cartas + 1;
            end;
        end;

        case valor of
            4: l[cartas].forca:= 1;
            5: l[cartas].forca:= 2;
            6: l[cartas].forca:= 3;
            7: l[cartas].forca:= 4;
            10: l[cartas].forca:= 5;
            11: l[cartas].forca:= 6;
            12: l[cartas].forca:= 7;
            1: l[cartas].forca:= 8;
            2: l[cartas].forca:= 9;
            3:= l[cartas].forca:= 10;
        end;
end;

// a lógica para embaralhar foi feita através do algoritmo fisher-yates, que pra mim é o padrão ouro, ele garante que todas as permutações
// possíveis tem a mesma probabilidade de acontecer, então, é um embaralhamento uniforme. Funciona da seguinte forma: percorre-se o vetor de
// trás pra frente, e em cada posição i, sortear um índice aleatório j, entre 1 e i, e trocar os elementos dessas duas posições

procedure embaralhar(var l: Tlista);
var i, j: integer;
    temp: Tcarta;
begin
    for i:= TAM_BARALHO downto 2 do
    begin
        j:= random(i) + 1;
        temp:= l[i];
        l[i]:= l[j];
        l[j]:= temp;
    end;
end;

// Aqui de verdade, é a coisa mais simples do mundo, só jogar as coisas da lista pra pilha, na verdade, daria só pra ir colocando direto e definindo o topo 
// pra 40 depois, mas, na minha opinião, perderia toda a ideia do que é uma pilha

procedure listaParaPilha(var l: Tlista; var p: Tpilha);
var i: integer;
begin
    p.topo:= 0;
    for i:= 1 to TAM_BARALHO do
    begin
        p.topo:= p.topo + 1;
        p.cartas[p.topo]:= l[i];
    end;
end;

// transfere as cartas da pilha pra fila usando pop e enqueue. o pop retira sempre do topo da pilha (p.topo),
// e o enqueue insere sempre no fim da fila (f.fim), respeitando o princípio FIFO. a cada iteração o topo
// decrementa e o fim incrementa, até a pilha esvaziar completamente.

procedure cortarPilha(var p: Tpilha; var f: Tfila);
var i: integer;
begin
    f.inicio:= 1;
    f.fim:= 1;  
    for i:= 1 to TAM_BARALHO do
    begin
        f.cartas[f.fim]:= p.cartas[p.topo];
        p.topo:= p.topo - 1;
        f.fim:= f.fim + 1;
    end;
end;
