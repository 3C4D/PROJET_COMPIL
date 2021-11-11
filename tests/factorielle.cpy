cpyrr

/*
    Calcule la factorielle
*/

var x:int;

proc factorielle(numero:int)
    var x:int;
    var resultat:int;
    var nbTerme:int;
    {
        x := 2;
        resultat := 1;
        nbTerme := 2;

        if numero < 0 then{
            afficher("Erreur, numero négatif négatif\n");
            return;
        }
        if numero < 2 then{
            afficher("%d! = 1\n", numero);
            return;
        }

        afficher("%d! = 1 x ", numero);
        while(nbTerme != numero)do{
            afficher("%d x ", x);
            resultat := resultat*x;
            x := x+1;
            nbTerme := nbTerme + 1;
        }

        resultat := resultat*x;
        afficher("%d = %d\n", x, resultat);
    }
{
    x := 0;
    while(x < 10)do{
        factorielle(x+1);
        x := x+1;
    }
}
