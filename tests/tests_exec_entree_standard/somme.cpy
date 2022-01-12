/*
    Somme des entiers pairs ou impairs d'un tableau par des fonctions imbriquées
*/
cpyrr

type tabInt : array[0_15] of int;
var tab:tabInt;
var i:int;

func f1(i:int) return int
    func f2(i:int) return int
    {
        if(i < 16)then{
            return tab[i] + f1(i+1);
        }
        return 0;
    }
{
    if(i < 16)then{
        return f2(i+1);
    }
    return 0;
}

{
    i := 0;
    while(i < 16)do{
        lire(tab[i]);
        i := i + 1;
    }

    i := 0;
    while(i < 16)do{
        afficher("%d ", tab[i]);
        i := i + 1;
    }
    afficher("\n");

    afficher("somme des index impairs : %d\n", f1(0));
    afficher("somme des index pairs : %d\n", f1(-1));
}
