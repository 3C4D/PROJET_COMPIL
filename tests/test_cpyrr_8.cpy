cpyrr
/*
  Programme de test numéro 5 : fonction , booleens, tableaux, structures
*/

// Quelques déclarations utiles de tous types
type monTab56 : array [5_6,2_7] of int;
type maStruct88 : struct
  ch1:int;
fstruct

type maStruct89 : struct
  ch1:int;
  ch2:char;
  ch4:int;
fstruct

type pourquoi : struct
  simple:int;
  basique:char;
  quoi:monTab56;
  jpp:maStruct89;
  ok:bool;
fstruct

type pleurerDuSang : array [1_6,4_7,2_10] of pourquoi;

// Quelques déclarations de variables
var x42b : int;
var y12 : bool;
var variableInutile : float;
var variableInutile2 : char;
var bonjour: maStruct89;
var tab: monTab56;
var cdur: pourquoi;
var hardcore: pleurerDuSang;
var wow: int;

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
        void;
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
}

{
  // On pousse le vice
  cdur.simple := 20;
  cdur.quoi[6][3] := 9;
  hardcore[6][6][6].jpp.ch4 := 999;
  // affectation arithmérique
  x42b := (12 + (4 - 8 % 12) * 6);

}
