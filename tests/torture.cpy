cpyrr


type t : struct
    t : int;
fstruct

var t : t;

proc t (t:int)
    type t : array[1_10] of t;
    {
        void;
    }

func t (t :int) return int
    {
    return t;
    }

func f(t : int; tt : bool) return int
    {
        return t;
    }

func g (g : int; t : int) return int
    {
    return g;
    }
func k(k :int; kk : int) return int
    {
    return k;
    }

proc torture1
    type tabl : array[0_12] of float;

    type sss : struct
        ch2 : tabl;
    fstruct
    type s : struct
        ch4 : sss;
    fstruct
    type ss : struct
        ch2 : s;
    fstruct

    type aie : array[1_12, 0_12] of ss;

    type x : struct
        ch1 : int;
    fstruct
    type x2: struct
        ch1 : aie;
    fstruct
    type tt : struct
        ch3 : x2;
    fstruct

    type t : array[-15_15, 42_42] of tt;

    type yt : struct
        ch2b : x;
    fstruct

    type y : array[0_10] of yt;

    var tab : t;
    var x : x;
    var y422 : int;
    var y : y;
    var a : int;
    var b : int;
    var z : int;
    var x12 : int;
    var z42 : int;
    var a42 : int;
    {
    tab[x.ch1+(y422 + f(y[3][z42].ch2b.ch1 ,(a=b+2*z)) - 1)][42].ch3.ch1[3][a42].ch2.ch4.ch2[f(g(k(3,g(3,14)),x12), false)+1] := 3.14 ;
    }

{
torture1();
}
