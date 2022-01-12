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
        if estPlusGrand(i-1, i) then{
            afficherTab();
            k := dicho(0, i-1, i);
            rotation(k, i);
        }
        i := i+1;
    }
}

proc remplirTab
    var i : int;
{
    i := 0;
    while(i < 8) do{
        lire(tab[i].ch1);
        lire(tab[i].ch2);
        i := i+1;
    }
}

{
    remplirTab();
    afficherTab();
    TID();
    afficherTab();
}
