cpyrr

  type string : array [0_15] of char;

  var x : bool;
  var y : int;
  var z : char;
  var w : float;

  var s : string;

  // Récupère la formule sur l'entrée standard
  proc getStr
    var c:char;
    var i:int;
    {
      i := 0;
      lire(c);
      while ((c != '$') and (i < 256)) do{
        s[i] := c;
        i := i + 1;
        lire(c);
      }
    }

  // Affiche le contenu de s
  proc showStr
    var i:int;
    {
      afficher("Contenu du texte: ");
      i := 0;
      while ((i < 256) and (s[i] != '\0')) do{
        afficher("%c", s[i]);
        i := i + 1;
      }
      afficher("\n");
    }

{
  lire(x, y, z, w);
  afficher("entrée: %b %d %c %f\n", x, y, z, w);

  getStr();
  showStr();
}
