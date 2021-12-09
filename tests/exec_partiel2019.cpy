cpyrr

type s : struct
ch1 : int ;
ch2 : float;
ch3 : bool ;
fstruct
var b : bool ;
var s1 : s ;
var t : int ;

proc p1
    var x : int ; var s2 : s ;

    proc p2
    var y : int ;
    {
    y := x ;
    }

    proc p5
        var w : int ; var y : bool ; var s3 : s ;
        proc p7(a : bool)
            proc p3(a : int)
                var z : int ;
            {
            if (a > 20) then
                {p3(a-10);}
                else{ p2();}
            }
        {
        t := 42;
        x := t ;
        p3(x-5);
        }
    {
    s3.ch2 := 12.34; s3.ch1 := 42; s3.ch3 := true;
    p7(s3.ch3);
    }
{
p5();
}

proc p4
    var z : float ;
{
p1() ;
}
{
 s1.ch1 := 99;
s1.ch2 := 3.14;
s1.ch3 := false ;
 p4();
}
