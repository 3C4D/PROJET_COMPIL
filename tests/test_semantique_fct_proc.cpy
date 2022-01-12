cpyrr

type typeT : array[5_45] of int;

var x : int;

//Procédure avec instruction de retour
proc p1(pp : int){
    return 4;
}

//Type de retour non simple
func f1(ss:int) return int
    var retour : typeT;
    {
    return 0;
    }

//Oublie d'instruction de retour
func f2(para:int) return int
    //Instruction de retour vide
    func f2(para: int) return int{
    return ;
    }
    {
    //Appel d'une procédure qui n'existe pas
    p45();
    }

//func f2(para:int){
//void;
//}

{
    //Mauvais type de paramètre d'une fonction
    x := f1(4.5);

    //Procédure dans une expression
    x:=p1(0);

    //Mauvais type de paramètre d'une procédure
    p1(5.2);

    //Nombre de paramètre incorrecte
    p1();
    p1(5,8);


}
