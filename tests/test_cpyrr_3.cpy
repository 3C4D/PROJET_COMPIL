cpyrr
var factorielle : int;

func factorielle(n:int) return int{
    if(n < 1)
    then{
        return 1;
    }
    else{
        return n*factorielle(n-1);
    }
}

{
    afficher("%d", factorielle(5));
}
