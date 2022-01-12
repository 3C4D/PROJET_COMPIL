cpyrr

/*
    Test l'erreur de division 0
*/

var x:int;

proc div{
  afficher("div!\n");
}

func div(x:int; y:int) return int{
  return x / y;
}

{
    x := 5;

    div();

    while(x >= 0)do{
        afficher("60/%d = %d\n", x, div(60, x));
        x := x-1;
    }
}
