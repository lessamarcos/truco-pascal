program truco;

const
    TAM_BARALHO = 40;
    TAM_MAO = 3;
    MAX_PONTOS = 12;

type
    Tcarta = record
<<<<<<< HEAD
        valor: string;
        naipe: string;
=======
        valor: integer;
        naipe: integer;
>>>>>>> 768dc2d3181ef1cc222a04987239202d2e1815a9
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
