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

    Tbaralho = record
        cartas: array[1.. TAM_BARALHO] of Tcarta;
        topo: integer;
    end;


procedure embaralhar(var l: Tlista);
var i, j, temp: integer;
begin
    for i:= TAMANHO_BARALHO downto 2 do
    begin
        j:= random(i) + 1;
        temp:= l[i];
        l[i]:= l[j];
        l[j]:= temp;
    end;
end;


procedure cortar(var l: Tlista);

function virarManilha(l: Tlista)


procedure ListaParaPilha(l: Tlista; var p: tpilha);
var i: integer;
begin
    for i:= 1 to TAM_BARALHO do
        p[i]:= l[i];
end;
