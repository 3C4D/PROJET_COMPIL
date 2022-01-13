cpyrr

/*
    Test de la pile avec l'algorithme d'Euclide
*/

  var x:int;
  var y:int;

  func pgcd(x:int; y:int) return int
    {
      if ((y = 0)) then { return x; }
      return pgcd(y, x%y);
    }

{
    x := 21;
    y := 15;

    afficher("PGCD(15,21) = %d\n", pgcd(x,y));
}
