cpyrr

var x:int;

// On cherche à calculer un terme de la suite de fibonnacci en itératif
func fibo(numeroTerme:int) return int
var terme1 : int;
var terme2 : int;
var termeTemp : int;
var nbTerme : int;
{
    if numeroTerme <= 0
    then{
      afficher("Erreur, numeroTerme négatif ou nul\n");
      return 0;
    }
    else{
      nbTerme := 2;
      terme1 := 1;
      terme2 := 1;
      while nbTerme < numeroTerme do{
        termeTemp := terme2;
        terme2 := terme2 + terme1;
        terme1 := termeTemp;
        nbTerme := nbTerme+1;
      }
    }
  return terme2;
}

{
  x := 1;
  afficher("Termes 1 à 10 de la suite de fibonacci :\n");
  while(x < 11)do{
      afficher("%d : %d\n", x, fibo(x));
      x := x+1;
  }
}
