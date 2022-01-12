cpyrr

/*
    Test l'erreur de modulo 0
*/

var x:int;

proc mod{
  afficher("mod!\n");
}

func mod(x:int; y:int) return int{
  return x % y;
}

{
    x := 5;

    mod();

    while(x >= 0)do{
        afficher("7 mod %d = %d\n", x, mod(7, x));
        x := x-1;
    }
}
