program truco;
uses crt;
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
// números são diferentes de 8 e 9, caso sejam, coloca no baralho. O procedimento também inicializa a força das cartas, atributo
// que será usado para decidir qual carta irá ganhar.

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
                    3:l[cartas].forca:= 10;
                end;
                cartas:= cartas + 1;
            end;
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

// Aqui é simples, o usuário ganha uma carta e o computador outra, até que suas mão estejam cheia, o inicio é atualizado a cada carta entregue, pq ela foi 
// tecnicamente removida do baralho pra ser entregue

procedure distribuirCartas(var f: Tfila; var mao1, mao2: Tmao);
var i: integer;
begin
    for i:= 1 to 3 do
    begin
        mao1[i]:= f.cartas[f.inicio];
        f.inicio:= f.inicio+1;
        mao2[i]:= f.cartas[f.inicio];
        f.inicio:= f.inicio+1;
    end;
end;

// função simples só pra efetuar a vira do baralho e atualizar o inicio dele

function virarManilha(var f: Tfila): Tcarta;
begin
    virarManilha:= f.cartas[f.inicio];
    f.inicio:= f.inicio+1;
end;

// os valores da manilha tem alguns casos especiais, que precisam ser filtrados, se não tivesse esses casos era só fazer + 1 na vira, mas, não funciona assim, de inicio,
// pensei em usar um vetor com as cartas, mas vi que não a necessidade, pq ha somente 2 casos especiais

function valorManilha(var vira: Tcarta): integer;
begin
    case vira.valor of
        7: valorManilha:= 10;
        12: valorManilha:= 1;
        else valorManilha:= vira.valor + 1;
    end;
end;
    

// devido a força das manilhas ser superior e cada manilha precisar ter uma força diferente, já que manilha nunca empacha, é necessário atualizar as forças delas depois que 
// as cartas são entregues, e cada naipe precisa ter uma força diferente

procedure atualizaForcas(var mao: Tmao; vira: Tcarta);
var i: integer;
begin
    for i:= 1 to TAM_MAO do
    begin
        if mao[i].valor = valorManilha(vira) then
        begin
            case mao[i].naipe of
                1: mao[i].forca:= 11;
                2: mao[i].forca:= 12;
                3: mao[i].forca:= 13;
                4: mao[i].forca:= 14;
            end;
        end;
    end;
end;

function nomeNaipe(naipe: integer): string;
begin
    case naipe of
        1: nomeNaipe:= 'Ouro';
        2: nomeNaipe:= 'Espada';
        3: nomeNaipe:= 'Copas';
        4: nomeNaipe:= 'Paus';
    end;
end;


// Aqui as cartas ja foram distribuidas, e este procedimento mostra a "mão" do jogador.
// o FOR percorre até "TAM_MAO" para verificar as 3 cartas, e logo em seguida imprime o valor, naipe e em que posição esta na mão do jogador;
procedure ExibirMao(mao:Tmao);
var i:integer;
begin   
    for i:=1 to TAM_MAO do
    begin   
        if mao[i].valor <> 0 then
            write('Carta ', i, ': ', mao[i].valor,' De ', nomeNaipe(mao[i].naipe));
        writeln;
    end;
end;

//Está funcão pede ao jogador qual carta deseja escolher para jogar (1 a 3).
//O while serve para caso o jogador digitar uma posição invalida ele ter que escolher outra posição válida.
//O laço FOR desloca a posição da direita para esqueda para reposicionar as cartas
//Logo em seguida o programa limpa a ultima posição da mão.
function JogarCarta(var mao:Tmao):Tcarta;
var pos, i:integer;
    cartaEscolhida:Tcarta;
begin  
    write('Escolha a carta para jogar (1 a ', TAM_MAO, '): ');
    readln(pos);

    while (pos < 1) or (pos > TAM_MAO) or (mao[pos].valor = 0) do
    begin
        write('Posicao invalida ou carta vazia! Escolha novamente: ');
        readln(pos);
    end;

    cartaEscolhida:=mao[pos];

    for i:=pos to TAM_MAO - 1 do    
        mao[i]:=mao[i+1];
    
    mao[TAM_MAO].valor:= 0;
    mao[TAM_MAO].naipe:= 0;
    mao[TAM_MAO].forca:= 0;

    jogarCarta:= cartaEscolhida;
end;

function compararCartas(carta1, carta2: Tcarta): integer;
begin
    if carta1.forca > carta2.forca then
        compararCartas:= 1
    else if carta1.forca < carta2.forca then
        compararCartas:= 2
    else
        compararCartas:= 0;
end;

function jogadaComputador(var mao: Tmao): Tcarta;
var i, posMenor: integer;
begin
    posMenor:= 0;
    for i:= 1 to TAM_MAO do
        if  (mao[i].valor <> 0) then
            if (posMenor = 0) or (mao[i].forca < mao[posMenor].forca) then
                posMenor:= i;

    jogadaComputador := mao[posMenor];
    
    for i:= posMenor to TAM_MAO-1 do
        mao[i]:= mao[i+1];
    mao[TAM_MAO].valor:= 0;
    mao[TAM_MAO].naipe:= 0;
    mao[TAM_MAO].forca:= 0;
end;

procedure exibirCarta(c: tcarta);
begin
    write(c.valor, ' - ', nomeNaipe(c.naipe));
end;

function temCartaForte(mao: Tmao): boolean;
var i: integer;
begin
    temCartaForte:= false;
    for i:= 1 to TAM_MAO do
        if mao[i].forca >= 8 then
            temCartaForte:= true;
end;

function pedirTruco(valorAtual: integer; mao2: Tmao): integer;
begin
    if valorAtual + 3 > 12 then
    begin
        writeln('Não é possível pedir truco.');
        pedirTruco:= valorAtual;
    end
    else
    begin
        if temCartaForte(mao2) then
        begin
            writeln('CPU aceitou o truco! Mao vale ', valorAtual + 2, ' pontos.');
            pedirTruco:= valorAtual + 2;
        end
        else
        begin
            writeln('CPU recusou o truco! Você ganha ', valorAtual, ' pontos. ');
            pedirTruco:= valorAtual;
        end;
    end;
end;



function jogarRodada(var mao1, mao2: Tmao; var valorMao: integer; var fugou: boolean):integer;
var cartaJogador, cartaComputador: tcarta;
    opcao: integer;
begin
    writeln;
    ExibirMao(mao1);
    writeln;
    writeln('1 - Jogar');
    writeln('2 - Pedir Truco');
    writeln('3 - Correr');
    readln(opcao);
    while (opcao < 1) or (opcao > 3) do
    begin
        writeln('Opção inválida! Escolha 1, 2 ou 3.');
        readln(opcao);
    end;
    case opcao of
        1: begin
            writeln;
            ExibirMao(mao1);
            cartaJogador:= jogarCarta(mao1);
            cartaComputador:= jogadaComputador(mao2);
            write('Carta Jogador: ');
            exibirCarta(cartaJogador);
            writeln;
            write('Carta CPU: ');
            exibirCarta(cartaComputador);
            writeln;
            jogarRodada:= compararCartas(cartaJogador, cartaComputador);
            readln;
            clrscr;
        end;
        2: begin
            valorMao:= pedirTruco(valorMao, mao2);
            ExibirMao(mao1);
            cartaJogador:= jogarCarta(mao1);
            cartaComputador:= jogadaComputador(mao2);
            jogarRodada:= compararCartas(cartaJogador, cartaComputador);
            readln;
            clrscr;
        end;
        3: begin
            writeln('Tu correu, seu cagão!');
            jogarRodada:= 2;
            fugou:= true;
        end;
    end;
end;

function jogarMao(var mao1, mao2: Tmao; var valorMao: integer): integer;
var rodada1, rodada2, rodada3: integer;
    fugou: boolean;
begin
    fugou := false;
    rodada1 := jogarRodada(mao1, mao2, valorMao, fugou);
    if fugou then
        jogarMao := 2
    else
    begin
        rodada2 := jogarRodada(mao1, mao2, valorMao, fugou);
        if fugou then
            jogarMao := 2
        else
        begin
            if (rodada1 = 1) and (rodada2 = 1) then
                jogarMao := 1
            else if (rodada1 = 2) and (rodada2 = 2) then
                jogarMao := 2
            else if (rodada1 = 0) and (rodada2 <> 0) then
                jogarMao := rodada2
            else if (rodada2 = 0) then
            begin
                rodada3 := jogarRodada(mao1, mao2, valorMao, fugou);
                if rodada3 = 0 then
                    jogarMao := rodada1
                else
                    jogarMao := rodada3;
            end
            else
            begin
                rodada3 := jogarRodada(mao1, mao2, valorMao, fugou);
                if rodada3 = 0 then
                    jogarMao := 0
                else
                    jogarMao := rodada3;
            end;
        end;
    end;
end;

var lista: Tlista;
    pilha: Tpilha;
    fila: Tfila;
    mao1, mao2: Tmao;
    vira: tcarta;
    pontosJogador, pontosComputador: integer;
    valorMao: integer;
    resultado: integer;

begin
    randomize;
    pontosJogador:= 0;
    pontosComputador:= 0;
    repeat
        inicializarBaralho(lista);
        embaralhar(lista);
        listaParaPilha(lista, pilha);
        cortarPilha(pilha, fila);
        distribuirCartas(fila, mao1, mao2);
        vira:= virarManilha(fila);
        write('Manilha: ');
        exibirCarta(vira);
        writeln;
        atualizaForcas(mao1, vira);
        atualizaForcas(mao2, vira);
        valorMao:= 1;
        resultado:= jogarMao(mao1, mao2, valorMao);
        if resultado = 1 then
            pontosJogador:= pontosJogador + valorMao
        else if resultado = 2 then
            pontosComputador:= pontosComputador + valorMao;
        writeln('Placar: Você ', pontosJogador, ' x ', pontosComputador, ' CPU');      
    until (pontosJogador >= MAX_PONTOS) or (pontosComputador >= MAX_PONTOS);
    if pontosJogador >= MAX_PONTOS then
        writeln('Você ganhou o jogo!')
    else
        writeln('CPU ganhou o jogo!');
End.