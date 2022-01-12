cpyrr

var a : float;
var b : float;
var Nbis : int ;
var N : float ;
var integraleRectangleBas : float;
var integraleRectangleHaut : float;
var integrale : float;

func f(x : float) return float{
    return x*x;
}

//Pour faire une approximation par la méthode des rectangles
func integral(a: float; b:float; NBis: int; N:float; side:bool) return float
    var pas : float;
    var x : float;
    var somme : float;
    var i : int;
    {
        pas := (b-a) / N;
        x := a;
        somme := 0.0;
        i := 0;

        while(i != NBis) do{
            if side then
            {
                somme := somme + f(x);
            }
            x := x + pas;
            if(not side) then{
                somme := somme + f(x);
            }
            i := i + 1;
        }
        return (b-a)*somme/N;
    }

//Pour faire une approximation par la mathode des trapèzes
func integrale2(a: float; b:float; NBis: int; N:float) return float
    var pas : float;
    var x : float;
    var somme : float;
    var i : int;
    {
        pas := (b-a) / N;
        somme := (f(a) + f(b))/ 2.0;
        i := 0;

        while(i != (NBis - 1)) do{
            x := x + pas;
            somme := somme + f(x);
            i := i +1;
        }

        return (b-a)*somme/N;
    }

{
    a := 0.0;
    b := 1.0;
    Nbis := 100;
    N := 100.0;
    afficher("Calcul de l'integrale de la fonction f : x -> x*x par la méthode des rectangles. \n");
    integraleRectangleHaut := integral(a, b, Nbis, N, true);
    integraleRectangleBas := integral(a, b, Nbis, N, false);
    
    integrale := (integraleRectangleBas + integraleRectangleHaut)/ 2.0;
    afficher("L'integrale de f est  : %f \n \n", integrale);


    afficher("Calcul de l'integrale de la fonction f : x -> x*x par la méthode des trapèzes. \n");
    integrale := integrale2(a, b, Nbis, N);
    afficher("L'integrale de f est : %f \n", integrale);
}
