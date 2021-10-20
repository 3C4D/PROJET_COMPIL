cpyrr
/*
  Programme de test numéro 5 : fonction , booleens, tableaux, structures
*/
// On cherche à calculer un terme de la suite de fibonnacci en itératif
func fibo(numeroTerme:int) return int
var terme1 : int;
var terme2 : int;
var termeTemp : int;
var nbTerme : int;
{
    if numeroTerme <= 0
    then{
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
      }
    }
  return terme2;
}
proc fibo(numeroTerme:int)
var terme1 : int;
var terme2 : int;
var termeTemp : int;
var nbTerme : int;
{
    if numeroTerme <= 0
    then{
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
      }
    }
  return terme2;
}
// Quelques déclarations utiles de tous types
var x42b : int;
var y12 : bool;
var variableInutile : float;
var variableInutile2 : char;
type monTab56 : array [5_6,7_2] of int;
type maStruct88 : struct
  ch1:str[50]
fstruct
type maStruct89 : struct
  ch1:int;
  ch2:char;
  ch3:str[60];
  ch4:maStruct88
fstruct

var bonjour: maStruct89;
{
  // affectation arithmérique
  x42b := (12 + (4 - 8 % 12) * 6);
  // booleen
  y12 := (true and ((false or 1) and 2));
  // float
  variableInutile := 3.75*(8+(6.789/1.6));
  // caractère
  variableInutile2 := 's';
  // struct
  bonjour.ch1 := x42b+3*(6%2);
  bonjour.ch2 := variableInutile2;
  bonjour.ch3 := "sa"+"lur";
  // chaine
  bonjour.ch4.ch1 := "salut";
  // tableau
  monTab56[x42b+2*(4+6%28)] := 2;
  monTab56[fibo(x42b)] := x42b-85;
  // On appelle notre fonction
  afficher("%d\n", fibo(x42b));
  afficher("%d\n", fibo(x42b + 5 - (6%(3/5))));
  afficher("%d\n", fibo(6));
}
