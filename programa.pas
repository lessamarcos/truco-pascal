program truco;

const
    TAM_BARALHO = 40;
    TAM_MAO = 3;
    MAX_PONTOS = 12;

type
    Tcarta = record
        valor: string;
        naipe: string;
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
        qtd: integer;
    end;

    Tlista = record
