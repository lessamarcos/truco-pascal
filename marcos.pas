program marcos;
type
    Tpilha = record
        cartas: array[1..40] of integer;
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

procedure ListaParaPilha(l: Tlista; var p: tpilha);
var i: integer;
begin
    for i:= 1 to TAM_BARALHO do
        p[i]:= l[i];
end;
