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


// a ideia aqui Ã© auto explicativo, inicializar o baralho, Ã© simples basta percorrer todos os nipes juntamente com todas as cartas, 
// percorre nipes e dentro de nipes o valor, pq cada nÃºmero, deve ter 4 nipes. Aplica-se uma simples condicional pra filtrar se os
// nÃºmeros sÃ£o diferentes de 8 e 9, caso sejam, coloca no baralho. O procedimento tambÃ©m inicializa a forÃ§a das cartas, atributo
// que serÃ¡ usado para decidir qual carta irÃ¡ ganhar.
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
                    4:  l[cartas].forca:= 1;
                    5:  l[cartas].forca:= 2;
                    6:  l[cartas].forca:= 3;
                    7:  l[cartas].forca:= 4;
                    10: l[cartas].forca:= 5;
                    11: l[cartas].forca:= 6;
                    12: l[cartas].forca:= 7;
                    1:  l[cartas].forca:= 8;
                    2:  l[cartas].forca:= 9;
                    3:  l[cartas].forca:= 10;
                end;
                cartas:= cartas + 1;
            end;
        end;
end;

// a lÃ³gica para embaralhar foi feita atravÃ©s do algoritmo fisher-yates, que pra mim Ã© o padrÃ£o ouro, ele garante que todas as permutaÃ§Ãµes
// possÃ­veis tem a mesma probabilidade de acontecer, entÃ£o, Ã© um embaralhamento uniforme. Funciona da seguinte forma: percorre-se o vetor de
// trÃ¡s pra frente, e em cada posiÃ§Ã£o i, sortear um Ã­ndice aleatÃ³rio j, entre 1 e i, e trocar os elementos dessas duas posiÃ§Ãµes
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

// Aqui de verdade, Ã© a coisa mais simples do mundo, sÃ³ jogar as coisas da lista pra pilha, na verdade, daria sÃ³ pra ir colocando direto e definindo o topo 
// pra 40 depois, mas, na minha opiniÃ£o, perderia toda a ideia do que Ã© uma pilha
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
// e o enqueue insere sempre no fim da fila (f.fim), respeitando o princÃ­pio FIFO. a cada iteraÃ§Ã£o o topo
// decrementa e o fim incrementa, atÃ© a pilha esvaziar completamente.
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

// Aqui Ã© simples, o usuÃ¡rio ganha uma carta e o computador outra, atÃ© que suas mÃ£o estejam cheia, o inicio Ã© atualizado a cada carta entregue, pq ela foi 
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

// funÃ§Ã£o simples sÃ³ pra efetuar a vira do baralho e atualizar o inicio dele
function virarManilha(var f: Tfila): Tcarta;
begin
    virarManilha:= f.cartas[f.inicio];
    f.inicio:= f.inicio+1;
    writeln;
end;

// os valores da manilha tem alguns casos especiais, que precisam ser filtrados, se nÃ£o tivesse esses casos era sÃ³ fazer + 1 na vira, mas, nÃ£o funciona assim, de inicio,
// pensei em usar um vetor com as cartas, mas vi que nÃ£o a necessidade, pq ha somente 2 casos especiais
function valorManilha(var vira: Tcarta): integer;
begin
    case vira.valor of
        7:  valorManilha:= 10;
        12: valorManilha:= 1;
        else valorManilha:= vira.valor + 1;
    end;
end;

// devido a forÃ§a das manilhas ser superior e cada manilha precisar ter uma forÃ§a diferente, jÃ¡ que manilha nunca empacha, Ã© necessÃ¡rio atualizar as forÃ§as delas depois que 
// as cartas sÃ£o entregues, e cada naipe precisa ter uma forÃ§a diferente
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

// converte o nÃºmero do naipe para seu nome em texto, usado na exibiÃ§Ã£o das cartas.
function nomeNaipe(naipe: integer): string;
begin
    case naipe of
        1: nomeNaipe:= 'Ouro';
        2: nomeNaipe:= 'Espada';
        3: nomeNaipe:= 'Copas';
        4: nomeNaipe:= 'Paus';
    end;
end;

// Aqui as cartas ja foram distribuidas, e este procedimento mostra a "mÃ£o" do jogador.
// o FOR percorre atÃ© "TAM_MAO" para verificar as 3 cartas, e logo em seguida imprime o valor, naipe e em que posiÃ§Ã£o esta na mÃ£o do jogador.
procedure ExibirMao(mao: Tmao);
var i: integer;
begin
		writeln;
    for i:= 1 to TAM_MAO do
    begin
        if mao[i].valor <> 0 then
        begin
            textColor(15);
            write('Carta ', i, ': ', mao[i].valor, ' De ', nomeNaipe(mao[i].naipe));
            writeln;
        end;
    end;
    writeln;
    textColor(2);
end;

// EstÃ¡ funÃ§Ã£o pede ao jogador qual carta deseja escolher para jogar (1 a 3).
// O while serve para caso o jogador digitar uma posiÃ§Ã£o invalida ele ter que escolher outra posiÃ§Ã£o vÃ¡lida.
// O laÃ§o FOR desloca a posiÃ§Ã£o da direita para esquerda para reposicionar as cartas
// Logo em seguida o programa limpa a ultima posiÃ§Ã£o da mÃ£o.
function JogarCarta(var mao: Tmao): Tcarta;
var pos, i: integer;
    cartaEscolhida: Tcarta;
begin
    textColor(14);
    writeln;
    write('Escolha a carta para jogar (1 a ', TAM_MAO, '): ');
    readln(pos);

    while (pos < 1) or (pos > TAM_MAO) or (mao[pos].valor = 0) do
    begin
        textColor(12);
        write('Posicao invalida ou carta vazia! Escolha novamente: ');
        readln(pos);
    end;

    cartaEscolhida:= mao[pos];

    for i:= pos to TAM_MAO - 1 do
        mao[i]:= mao[i+1];

    mao[TAM_MAO].valor:= 0;
    mao[TAM_MAO].naipe:= 0;
    mao[TAM_MAO].forca:= 0;

    jogarCarta:= cartaEscolhida;
    textColor(2);
end;

// compara a forÃ§a de duas cartas e retorna 1 se a primeira vence, 2 se a segunda vence, ou 0 em caso de empate.
function compararCartas(carta1, carta2: Tcarta): integer;
begin
    if carta1.forca > carta2.forca then
        compararCartas:= 1
    else if carta1.forca < carta2.forca then
        compararCartas:= 2
    else
        compararCartas:= 0;
end;

// define a jogada da CPU escolhendo sempre a carta de menor forÃ§a da mÃ£o, removendo-a em seguida.
function jogadaComputador(var mao: Tmao): Tcarta;
var i, posMenor: integer;
begin
    posMenor:= 0;
    for i:= 1 to TAM_MAO do
        if (mao[i].valor <> 0) then
            if (posMenor = 0) or (mao[i].forca < mao[posMenor].forca) then
                posMenor:= i;

    jogadaComputador:= mao[posMenor];

    for i:= posMenor to TAM_MAO-1 do
        mao[i]:= mao[i+1];
    mao[TAM_MAO].valor:= 0;
    mao[TAM_MAO].naipe:= 0;
    mao[TAM_MAO].forca:= 0;
end;

// exibe o valor e o naipe de uma carta na tela.
procedure exibirCarta(c: Tcarta);
begin
    write(c.valor, ' - ', nomeNaipe(c.naipe));
end;

// verifica se a mÃ£o possui pelo menos uma carta com forÃ§a igual ou superior a 8, indicando carta forte ou manilha.
function temCartaForte(mao: Tmao): boolean;
var i: integer;
begin
    temCartaForte:= false;
    for i:= 1 to TAM_MAO do
        if mao[i].forca >= 8 then
            temCartaForte:= true;
end;

// Permite apenas pedir truco 1 -> 3.
// Bloqueia pedido duplicado via trucoPedidoPor e bloqueia se ja foi aceito (valorAtual >= 3).
// Se a CPU recusar, retorna o valor atual negativo para sinalizar encerramento da mao.
function pedirTruco(valorAtual: integer; mao2: Tmao; var trucoPedidoPor: boolean): integer;
begin
    if trucoPedidoPor then
    begin
        textColor(12);
        writeln('Voce ja pediu truco nesta mao!');
        textColor(2);
        pedirTruco:= valorAtual;
    end
    else
    begin
        textColor(14);
        writeln('Voce pediu TRUCO!');
        textColor(2);
        if temCartaForte(mao2) then
        begin
            textColor(10);
            writeln('CPU aceitou! A mao agora vale 3 pontos. ');
            textColor(2);
            trucoPedidoPor:= true;
            pedirTruco:= 3;
        end
        else
        begin
            textColor(12);
            writeln('CPU recusou! Voce ganha 1 ponto.');
            textColor(2);
            pedirTruco:= (valorAtual);
        end;
    end;
end;

// jogarRodada apresenta ao jogador as opÃ§Ãµes de jogar carta, pedir truco ou correr.
// a vira Ã© recebida por parametro para ser exibida corretamente a cada rodada.
// trucoPedidoPor Ã© compartilhado entre rodadas para impedir pedidos duplicados na mesma mÃ£o.
// se o jogador correr, fugou Ã© marcado como true e a mÃ£o encerra com vitÃ³ria da CPU.
// se a CPU recusar o truco, jogarRodada encerra imediatamente devolvendo vitÃ³ria ao jogador.
function jogarRodada(var mao1, mao2: Tmao; var valorMao: integer;
var fugou: boolean; vira: Tcarta;
var trucoPedidoPor: boolean; var quemComeca: integer): integer;
var cartaJogador, cartaComputador: Tcarta;
    opcao, resultado: integer;
begin
    fugou:= false;
    resultado:= 0;

    write('Carta Virada: ');
    exibirCarta(vira);
    writeln;
    write('Manilha: ');
    write(valorManilha(vira));
    writeln;
    ExibirMao(mao1);
    textColor(3);
    if quemComeca = 2 then
        writeln('--- A CPU JOGA PRIMEIRO ---');
    writeln('1 - Jogar');
    writeln('2 - Pedir Truco');
    writeln('3 - Correr');
    textColor(2);
    readln(opcao);
    

    while (opcao < 1) or (opcao > 3) do
    begin
        textColor(12);
        writeln('Opcao invalida! Escolha 1, 2 ou 3.');
        textColor(2);
        readln(opcao);
    end;
    clrscr;

    case opcao of
        1: begin
            write('Vira: ');
            writeln;
            write('Manilha: ');
            write(valorManilha(vira));
            exibirCarta(vira);
            writeln;
            ExibirMao(mao1);
            
            
            if quemComeca = 1 then
            begin
                cartaJogador:= jogarCarta(mao1);
                cartaComputador:= jogadaComputador(mao2);
                writeln;
                write('Carta Jogador: '); exibirCarta(cartaJogador); writeln; 
                write('Carta CPU    : '); exibirCarta(cartaComputador); writeln;
                writeln;
            end
            else
            begin
                cartaComputador:= jogadaComputador(mao2);
                write('A CPU jogou  : '); exibirCarta(cartaComputador); writeln;
                writeln;
                cartaJogador:= jogarCarta(mao1);
                write('Sua Carta    : '); exibirCarta(cartaJogador); writeln;
            end;

            resultado:= compararCartas(cartaJogador, cartaComputador);
        
            if resultado <> 0 then 
                quemComeca:= resultado;
						
						writeln;
            textColor(11);
            if resultado = 1 then
                writeln('Voce ganhou esta rodada!')
            else if resultado = 2 then
                writeln('CPU ganhou esta rodada!')
            else
                writeln('Empate nesta rodada!');
            textColor(2);
            readkey;
            clrscr;
            jogarRodada:= resultado;
        end;
        2: begin
            valorMao:= pedirTruco(valorMao, mao2, trucoPedidoPor);''
            readkey;
            clrscr;
            
            write('Vira: ');
            writeln;
            write('Manilha: ');
            write(valorManilha(vira));
            exibirCarta(vira);
            writeln;
            ExibirMao(mao1);
            
            if quemComeca = 1 then
            begin
                cartaJogador:= jogarCarta(mao1);
                cartaComputador:= jogadaComputador(mao2);
                write('Carta Jogador: '); exibirCarta(cartaJogador); writeln;
                write('Carta CPU    : '); exibirCarta(cartaComputador); writeln;
            end
            else
            begin
                cartaComputador:= jogadaComputador(mao2);
                write('A CPU jogou  : '); exibirCarta(cartaComputador); writeln;
                writeln;
                cartaJogador:= jogarCarta(mao1);
                write('Sua Carta    : '); exibirCarta(cartaJogador); writeln;
            end;
            resultado:= compararCartas(cartaJogador, cartaComputador);
            if resultado <> 0 then 
                quemComeca:= resultado;
            textColor(11);
            if resultado = 1 then
                writeln('Voce ganhou esta rodada!')
            else if resultado = 2 then
                writeln('CPU ganhou esta rodada!')
            else
                writeln('Empate nesta rodada!');
            textColor(2);
            readkey;
            clrscr;
            jogarRodada:= resultado;
        end;
        3: begin
            textColor(12);
            writeln('Tu correu, seu cagao!');
            textColor(2);
            jogarRodada:= 2;
            fugou:= true;
            readkey;
            clrscr;
        end;
    end;
end;

// jogarMao controla as trÃªs rodadas de uma mÃ£o e aplica as regras de desempate do truco:
// se o jogador ganhar as duas primeiras rodadas, vence a mÃ£o. se a CPU ganhar as duas, ela vence.
// se empatar a primeira e alguÃ©m ganhar a segunda, vence quem ganhou a segunda.
// se empatar as duas primeiras, a mÃ£o Ã© empate. se cada um ganhar uma, decide na terceira.
// se alguÃ©m ganhar a primeira e empatar a segunda, vence quem ganhou a primeira.
function jogarMao(var mao1, mao2: Tmao; var valorMao: integer; vira: Tcarta): integer;
var rodada1, rodada2, rodada3: integer;
    fugou, trucoPedidoPor: boolean;
    quemComeca: integer;
begin
    fugou:= false;
    trucoPedidoPor:= false;
    quemComeca:= 1; 

    rodada1:= jogarRodada(mao1, mao2, valorMao, fugou, vira, trucoPedidoPor, quemComeca);
    if not fugou then
        rodada2:= jogarRodada(mao1, mao2, valormao, fugou, vira, trucoPedidoPor, quemComeca);

    if fugou then
        jogarMao:= 2;
 

    if (rodada1 = 1) and (rodada2 = 1) then
        jogarMao:= 1
    else if (rodada1 = 2) and (rodada2 = 2) then
        jogarMao:= 2
    else if (rodada1 = 0) and (rodada2 <> 0) then
        jogarMao:= rodada2
    else if (rodada1 = 0) and (rodada2 = 0) then
        jogarMao:= 0
    else if (rodada1 = 1) and (rodada2 = 0) then
        jogarMao:= 1
    else if (rodada1 = 2) and (rodada2 = 0) then
        jogarMao:= 2
    else
    begin
        rodada3:= jogarRodada(mao1, mao2, valorMao, fugou, vira, trucoPedidoPor, quemComeca);
        if fugou then
            jogarMao:= 2
        else if rodada3 = 0 then
            jogarMao:= 0
        else
            jogarMao:= rodada3;
    end;
end;

var lista: Tlista;
    pilha: Tpilha;
    fila: Tfila;
    mao1, mao2: Tmao;
    vira: Tcarta;
    pontosJogador, pontosComputador: integer;
    valorMao: integer;
    resultado: integer;
    op: integer;

Begin
    randomize;
    pontosJogador:= 0;
    pontosComputador:= 0;
    op:= 1;
    while op <> 0 do
    begin
        textColor(15);
        writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=');
        writeln('| 1 -     INICIAR         |');
        writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=');
        writeln('| 0 -     SAIR            |');
        writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=');
        textColor(2);
        readln(op);
        clrscr;
        case op of
        1: begin
            pontosJogador:= 0;
            pontosComputador:= 0;
            repeat
                inicializarBaralho(lista);
                embaralhar(lista);
                listaParaPilha(lista, pilha);
                cortarPilha(pilha, fila);
                distribuirCartas(fila, mao1, mao2);
                vira:= virarManilha(fila);
                atualizaForcas(mao1, vira);
                atualizaForcas(mao2, vira);
                valorMao:= 1;
                resultado:= jogarMao(mao1, mao2, valorMao, vira);
                if resultado = 1 then
                    pontosJogador:= pontosJogador + valorMao
                else if resultado = 2 then
                    pontosComputador:= pontosComputador + valorMao;
                textColor(11);
                goToXY(35, 10);
                writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
                goToXY(35, 11);
                writeln('|         Placar            |');
                goToXY(35, 12);
                write('|  Voce: ');
                write(pontosJogador);
                write('  x  ');
                write(pontosComputador);
                writeln('  :CPU      |');
                goToXY(35, 13);
                writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
                textColor(2);
                readkey;
                clrscr;
            until (pontosJogador >= MAX_PONTOS) or (pontosComputador >= MAX_PONTOS);
            if pontosJogador >= MAX_PONTOS then
            begin
                textColor(10);
                writeln('============ Voce ganhou o jogo! ============');
                readkey;
                clrscr;
            end
            else
            begin
                textColor(12);
                writeln('============ CPU ganhou o jogo! ============');
                readkey;
                clrscr;
            end;
        end;
        end;
    end;
End.