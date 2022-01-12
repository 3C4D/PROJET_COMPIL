cpyrr

/*
    Test Out of Bound
*/

type tab : array[-1_1,0_2,-3_-1] of int;

var x:int;
var t:tab;

func mod(x:int; y:int) return int{
  return x % y;
}

{
    x := 5;
    t[-1][0][-3] := x / 2;
    t[0][x/5][-1] := x;
    t[0][x/5][-2] := x;
    //t[-x][x/5][-1] := 1; // Err dim 1
    //t[1][-1][-2] := 1; // Err dim 2
    //t[1][1][1] := 1; // Err dim 3
}
