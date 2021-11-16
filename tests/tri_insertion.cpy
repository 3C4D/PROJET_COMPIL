cpyrr

type deuxInt : struct
  ch1:int;
  ch2:int;
fstruct

type tabInt : array[0_7] of deuxInt;

var tab:tabInt;

proc afficherTab
var i:int;
var tmp:int;
{
    i := 0;
    while(i != 8)do{
        tmp := tab[i].ch1+tab[i].ch2;
        afficher("%d ", tmp);
        i := i+1;
    }
    afficher("\n");
}

func estPlusGrand(x:int; y:int) return bool
{
    if((tab[x].ch1+tab[x].ch2) > (tab[y].ch1+tab[y].ch2))then{
        return true;
    }
    return false;
}

proc rotation(x:int; y:int)
var tmp:deuxInt;
{
    tmp.ch1 := tab[y].ch1;
    tmp.ch2 := tab[y].ch2;
    while(y != x)do{
        tab[y].ch1 := tab[y-1].ch1;
        tab[y].ch2 := tab[y-1].ch2;
        y := y - 1;
    }
    tab[x].ch1 := tmp.ch1;
    tab[x].ch2 := tmp.ch2;
}

func dicho(g:int; d:int; x:int) return int
var m:int;
{
    if g = d then{
        return g;
    }

    m := (d+g)/2;
    if estPlusGrand(x, m) then{
        return dicho(m+1, d, x);
    }
    else{
        return dicho(g, m, x);
    }
}

proc TID
var i:int;
var k:int;
{
    i := 1;
    while(i < 8)do{
        if estPlusGrand(i-1, i) = true then{
            afficherTab();
            k := dicho(0, i-1, i);
            rotation(k, i);
        }
        i := i+1;
    }
}

proc remplirTab{
    tab[0].ch1 := 5;
    tab[0].ch2 := 7;
    tab[1].ch1 := 15;
    tab[1].ch2 := 2;
    tab[2].ch1 := 3;
    tab[2].ch2 := 0;
    tab[3].ch1 := 64;
    tab[3].ch2 := 12;
    tab[4].ch1 := 2;
    tab[4].ch2 := 7;
    tab[5].ch1 := 7;
    tab[5].ch2 := 1;
    tab[6].ch1 := 2;
    tab[6].ch2 := 6;
    tab[7].ch1 := 3;
    tab[7].ch2 := 0;
}

{
    remplirTab();
    afficherTab();
    TID();
    afficherTab();
}
