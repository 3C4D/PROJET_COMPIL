cpyrr

type t1 : array[5_20,2_4,6_9] of int;
type t2 : struct
    ch1 : int;
    ch2 : t1;
fstruct
type t3 : array[1_5] of t2;
type t4 : struct
    ch1 : t3;
    ch2 : int;
fstruct
var x : int;
var a : bool;
var t : t4 ;
var y : float;

proc p18(x: int; y : int)
    var z : int;
    proc p24(a:float; b:bool)
        type t2 : array[1_12] of t4;
        var yy : float;
        var t1 : float;
    {
        t1 := 2.0 * a;
        yy := a * 3.14;
        y :=  12/2;
    }

    proc p7(a : int)
        var z : int;
        var u : float;
        {
            if( (a >= 1) and (a <= 5) )then{
                while(a > 1)do{
                t.ch1[a].ch2[z*2][3][x*(y+2)] := 0;
                p24(u-10.5, false);
                a := a - 1;
                }
            }else{
                a := y;
                x := 2*a;
            }
        }
    {
        p7(3);
    }

{
    p18(1,1);
}
