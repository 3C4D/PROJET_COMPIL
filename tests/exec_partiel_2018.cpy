cpyrr

type tab : array[1_3] of int ;
type s : struct
ch1 : int ;
ch2 : tab ;
ch3 : bool ;          fstruct
var b : bool ;
var s1 : s ;
var t : int ;
proc p5(a : int)
    var x : int ; var s2 : s ;

    proc p2
    var y : int ;
    {
    y := x ;
    }

    proc p1
        var w : int ; var y : bool ; var s3 : s ;
        proc p3(a : int)
            var z : int ; var x : float ;
            {
            if (a < 0) then
                {p3(a+1);}
                else{ p2();}
            }
        {
        s3.ch3 := true ; s3.ch1 := 74 ;
        t := -3 ;
        x := t ;
        p3(x+1);
        }
 {
  x := a ;
  p1();
  }
proc p4(x : int)
    var z : float ;
{
p5(x) ;
}
{
 s1.ch1 := 42 ;
s1.ch2[1] := 21 ; s1.ch2[2] := 73 ; s1.ch2[3] := 34 ;
s1.ch3 := false ;
 p4(s1.ch1) ;
}
