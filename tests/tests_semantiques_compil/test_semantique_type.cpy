cpyrr

//Surchage dans une structure
type s1 : struct
    ch1 : int;
    ch2 : int;
    ch1 : int;
fstruct

//Bornes inversées
type t1 : array[1_5,5_4,2_5] of int;

type t1B : array[1_5,4_5,2_4] of int;

//Surcharge de type
//type t1 : array[2_5] of int;
type t1 : struct
    ch1 : int;
    ch2: int;
fstruct


//Un champs avec un type indeclarée
type s2 : struct
    tt : svide;
fstruct
//Un taleau de type non déclaré
//type tab : array[5_10] of svide2;

var x : t1B;

{
    //Manque d'indice dans le tableau
    x[5][5] := 5;
    //Trop d'indice dans la tableau
    x[5][5][3][6] := 5;
}
