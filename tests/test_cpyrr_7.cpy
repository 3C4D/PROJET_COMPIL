cpyrr
// Declaration de type de base

var essaiI : int;
var essaieB : bool;
var essaieF: float;
var essaieC: char;

// Declaration de type
type tab0 : array [0_12] of nf;

type tab1 : array [1_6,2_7] of int;
type tab2 : array[2_50] of tab1;

type maStruct1 : struct
  ch1:int;
  ch2: tab1
fstruct

type maStruct2 : struct
  ch1: maStruct1;
  ch2:char;
  ch4: tab2
fstruct

type tab3 : array [1_52] of maStruct1;

var bonjour: maStruct2;
var tab: tab1;

proc p1(coucou:int)
    type tab3 : array [1_5] of int;
    var x : tab3;
{
    void;
}

{
void;
}
