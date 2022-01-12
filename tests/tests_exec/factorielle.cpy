cpyrr

/*
    Calcule la factorielle
*/

var x:int;

func factorielle(n:int) return int
    {
        if(n > 0) then{
            return n*factorielle(n-1);
        }
        else{
            if(n < 0) then{
                afficher("Nombre négatif, arret de la fonction\n");
                return -1;
            }
            else{
                return 1;
            }
        }
    }
{
    x := 0;
    while(x < 10) do{
        afficher("%d! = %d\n", x, factorielle(x));
        x := x+1;
    }
}
