cpyrr

type typeT : struct
    ch1 : int;
fstruct

var x : int;

//Procédure avec instruction de retour
/*proc p1(pp : int){
  return 0;
}*/

//Type de retour non simple
/*func f1(ss:int) return int
    var retour : typeT;
    {
    return retour;
    }
*/

//Oublie d'instruction de retour
func f2(para:int) return int
    //Instruction de retour vide
/*    func f2(para: int) return int{
    return ;
  } */
    {
    //Appel d'une procédure qui n'existe pas
    //p45();
    void;
    return 0;
  }

/*
func p1(para:int) return int{
 return 0;
}
*/

{
  /*
    //Mauvais type de paramètre d'une fonction
    x := f1(4);

    //Procédure dans une expression
    x:=f2(0);

    //Nombre de paramètre incorrecte
    p1();
    p1(5,8);
  */
  void;
}
