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

    Tpilha = record
        cartas: array[1..TAM_BARALHO] of Tcarta;
        topo: integer;
    end;

    Tfila = record
        cartas: array[1..TAM_BARALHO] of Tcarta;
        inicio: integer;
        fim: integer;
        quantidade: integer;
    end;

    Tlista = record
