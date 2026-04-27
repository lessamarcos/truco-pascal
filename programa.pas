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
    writeln;
end;

// os valores da manilha tem alguns casos especiais, que precisam ser filtrados, se não tivesse esses casos era só fazer + 1 na vira, mas, não funciona assim, de inicio,
// pensei em usar um vetor com as cartas, mas vi que não a necessidade, pq ha somente 2 casos especiais
function valorManilha(var vira: Tcarta): integer;
begin
    case vira.valor of
        7:  valorManilha:= 10;
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

// converte o número do naipe para seu nome em texto, usado na exibição das cartas.
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
// o FOR percorre até "TAM_MAO" para verificar as 3 cartas, e logo em seguida imprime o valor, naipe e em que posição esta na mão do jogador.
procedure ExibirMao(mao: Tmao);
var i: integer;
beg
    for i:= 1 to TAM_MAO do
    begin
        if mao[i].valor <> 0 then
        begin
            textColor(1);
            textBackground(10);
            write('Carta ', i, ': ', mao[i].valor, ' De ', nomeNaipe(mao[i].naipe));
            writeln;
        end;
    end;
    textColor(2);
    textBackground(0);
end;

// Está função pede ao jogador qual carta deseja escolher para jogar (1 a 3).
// O while serve para caso o jogador digitar uma posição invalida ele ter que escolher outra posição válida.
// O laço FOR desloca a posição da direita para esquerda para reposicionar as cartas
// Logo em seguida o programa limpa a ultima posição da mão.
function JogarCarta(var mao: Tmao): Tcarta;
var pos, i: integer;
    cartaEscolhida: Tcarta;
begin
    textColor(14);
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

// compara a força de duas cartas e retorna 1 se a primeira vence, 2 se a segunda vence, ou 0 em caso de empate.
function compararCartas(carta1, carta2: Tcarta): integer;
begin
    if carta1.forca > carta2.forca then
        compararCartas:= 1
    else if carta1.forca < carta2.forca then
        compararCartas:= 2
    else
        compararCartas:= 0;
end;

// define a jogada da CPU escolhendo sempre a carta de menor força da mão, removendo-a em seguida.
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

// verifica se a mão possui pelo menos uma carta com força igual ou superior a 8, indicando carta forte ou manilha.
function temCartaForte(mao: Tmao): boolean;
var i: integer;
begin
    temCartaForte:= false;
    for i:= 1 to TAM_MAO do
        if mao[i].forca >= 8 then
            temCartaForte:= true;
end;

// a função pedirTruco segue a progressão oficial: 1, 3, 6, 9, 12.
// o parametro trucoPedidoPor impede que o jogador peça truco duas vezes na mesma mão.
// se a CPU recusar, devolve o valor atual negativo para sinalizar encerramento da mão.
function pedirTruco(valorAtual: integer; mao2: Tmao; var trucoPedidoPor: integer): integer;
var novoValor: integer;
begin
    if valorAtual = 1 then
        novoValor:= 3
    else if valorAtual = 3 then
        novoValor:= 6
    else if valorAtual = 6 then
        novoValor:= 12
    else
    begin
        textColor(12);
        writeln('A mao ja vale 12! Nao e possivel pedir mais.');
        textColor(2);
        pedirTruco:= valorAtual;
        exit;
    end;

    if trucoPedidoPor = 1 then
    begin
        textColor(12);
        writeln('Voce ja pediu truco nesta mao!');
        textColor(2);
        pedirTruco:= valorAtual;
        exit;
    end;

    textColor(14);
    if novoValor = 3 then
        writeln('Voce pediu TRUCO!')
    else if novoValor = 6 then
        writeln('Voce pediu SEIS!')
    else if novoValor = 9 then
        writeln('Voce pediu NOVE!')
    else
        writeln('Voce pediu DOZE!');
    textColor(2);

    if temCartaForte(mao2) then
    begin
        textColor(10);
        writeln('CPU aceitou! A mao agora vale ', novoValor, ' pontos.');
        textColor(2);
        trucoPedidoPor:= 1;
        pedirTruco:= novoValor;
    end
    else
    begin
        textColor(12);
        writeln('CPU recusou! Voce ganha ', valorAtual, ' ponto(s).');
        textColor(2);
        pedirTruco:= -(valorAtual);
    end;
end;

// jogarRodada apresenta ao jogador as opções de jogar carta, pedir truco ou correr.
// a vira é recebida por parametro para ser exibida corretamente a cada rodada.
// trucoPedidoPor é compartilhado entre rodadas para impedir pedidos duplicados na mesma mão.
// se o jogador correr, fugou é marcado como true e a mão encerra com vitória da CPU.
// se a CPU recusar o truco, jogarRodada encerra imediatamente devolvendo vitória ao jogador.
function jogarRodada(var mao1, mao2: Tmao; var valorMao: integer;
var fugou: boolean; vira: Tcarta;
var trucoPedidoPor: integer): integer;
var cartaJogador, cartaComputador: Tcarta;
    opcao, resultado: integer;
begin
    fugou:= false;
    resultado:= 0;

    write('Manilha: ');
    exibirCarta(vira);
    writeln;
    ExibirMao(mao1);
    textColor(3);
    writeln;
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
            write('Manilha: ');
            exibirCarta(vira);
            writeln;
            ExibirMao(mao1);
            cartaJogador:= jogarCarta(mao1);
            cartaComputador:= jogadaComputador(mao2);
            write('Carta Jogador: ');
            exibirCarta(cartaJogador);
            writeln;
            write('Carta CPU    : ');
            exibirCarta(cartaComputador);
            writeln;
            resultado:= compararCartas(cartaJogador, cartaComputador);
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
            resultado:= pedirTruco(valorMao, mao2, trucoPedidoPor);
            if resultado < 0 then
            begin
                valorMao:= -resultado;
                jogarRodada:= 1;
                readkey;
                clrscr;
                exit;
            end;
            valorMao:= resultado;
            readkey;
            clrscr;
            write('Manilha: ');
            exibirCarta(vira);
            writeln;
            ExibirMao(mao1);
            cartaJogador:= jogarCarta(mao1);
            cartaComputador:= jogadaComputador(mao2);
            write('Carta Jogador: ');
            exibirCarta(cartaJogador);
            writeln;
            write('Carta CPU    : ');
            exibirCarta(cartaComputador);
            writeln;
            resultado:= compararCartas(cartaJogador, cartaComputador);
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

// jogarMao controla as três rodadas de uma mão e aplica as regras de desempate do truco:
// se o jogador ganhar as duas primeiras rodadas, vence a mão. se a CPU ganhar as duas, ela vence.
// se empatar a primeira e alguém ganhar a segunda, vence quem ganhou a segunda.
// se empatar as duas primeiras, a mão é empate. se cada um ganhar uma, decide na terceira.
// se alguém ganhar a primeira e empatar a segunda, vence quem ganhou a primeira.
function jogarMao(var mao1, mao2: Tmao; var valorMao: integer; vira: Tcarta): integer;
var rodada1, rodada2, rodada3: integer;
    fugou: boolean;
    trucoPedidoPor: integer;
begin
    fugou:= false;
    trucoPedidoPor:= 0;

    rodada1:= jogarRodada(mao1, mao2, valorMao, fugou, vira, trucoPedidoPor);
    if fugou then
    begin
        jogarMao:= 2;
        exit;
    end;

    rodada2:= jogarRodada(mao1, mao2, valorMao, fugou, vira, trucoPedidoPor);
    if fugou then
    begin
        jogarMao:= 2;
        exit;
    end;

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
        rodada3:= jogarRodada(mao1, mao2, valorMao, fugou, vira, trucoPedidoPor);
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