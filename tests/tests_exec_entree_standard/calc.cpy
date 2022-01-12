cpyrr

/*
    Calculatrice pour une notation polonaise inverse
    La formule entrée doit se terminer par un $ 
    et chaque élément séparé par un ;
*/

// Définition des type
type lstChr : array[0_255] of char;
type lstEnt : array[0_255] of int;

type pile : struct
  taille:int;
  pile:lstEnt;
fstruct

// Définition des variables
var p:pile;
var input:lstChr;
var i:int;

// Initialise la pile
proc init
  {
    p.taille := -1;
  }

// Ajoute une valeuer à la pile
proc push(val:int)
  {
    if (p.taille < 255) then{
      p.pile[p.taille + 1] := val;
      p.taille := p.taille + 1;
    }
  }

// Retire une valeur de la pile et renvoie celle-ci
func pop return int
  var ret:int;
  {
    if (p.taille >= 0) then{
      ret :=  p.pile[p.taille];
      p.taille := p.taille - 1;
      return ret;
    } else {
      return -1;
    }
  }

// Renvoie a^b
func pow(a:int; b:int) return int
  {
    if (b = 0) then { return 1; }
    return a * pow(a, b - 1);
  }

// Convertie la représentation d'un caractère de chiffre en sa valeur réelle
func chr2digit(c:char) return int
  {
    if (c = '0') then {return 0;}
    if (c = '1') then {return 1;}
    if (c = '2') then {return 2;}
    if (c = '3') then {return 3;}
    if (c = '4') then {return 4;}
    if (c = '5') then {return 5;}
    if (c = '6') then {return 6;}
    if (c = '7') then {return 7;}
    if (c = '8') then {return 8;}
    if (c = '9') then {return 9;}
    else {return 0;}
  }

// Renvoie true si le caratère est un chiffre, false sinon
func isDigit(c:char) return bool
  {
    return ((c = '0') or (c = '1') or (c = '2') or (c = '3') or (c = '4') or 
            (c = '5') or (c = '6') or (c = '7') or (c = '8') or (c = '9'));
  }

// Lance l'analyse de la formule
func run return int
  var cursor:int;
  var chr:char;
  var ent:int;
  var lval:int;
  var rval:int;
  var op:char;
  
  // Ajoute un nombre de la formule à la pile
  proc addInt
    var i:int;
    {
      while (isDigit(input[cursor])) do {
        i := i * 10 + chr2digit(input[cursor]);
        cursor := cursor + 1;
      }

      push(i);
    }

  // Applique l'opération adéquate
  proc opTime(op:char)
    {
      rval := pop();
      lval := pop();

      if (op = '+') then {
        push(lval + rval); return;
      }
      if (op = '-') then {
        push(lval - rval); return;
      }
      if (op = '*') then {
        push(lval * rval); return;
      }
      if (op = '/') then {
        push(lval / rval); return;
      }
      if (op = '%') then {
        push(lval % rval); return;
      }
      if (op = '^') then {
        push(pow(lval, rval)); return;
      }
    }

  {
    cursor := 0;

    // Tant qu'il y a encore des caractère dans la formule
    while ((cursor <= 255) and (input[cursor] != '\0')) do {
      // NB: ';' = séparateur
      if (input[cursor] != ';') then {
        if (isDigit(input[cursor])) then {
          addInt();
        } else {
          opTime(input[cursor]);
          cursor := cursor + 1;
        }
      } else {
        cursor := cursor + 1;
      }
    }

    return pop();
  }

  // Récupère la formule sur l'entrée standard
  proc getInput
    var c:char;
    var i:int;
    {
      i := 0;
      lire(c);
      while ((c != '$') and (i < 256)) do{
        input[i] := c;
        i := i + 1;
        lire(c);
      }
    }

{
  getInput();
  init();
  afficher("resultat: %d\n", run());
}
