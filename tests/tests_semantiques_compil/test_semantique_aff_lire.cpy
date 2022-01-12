cpyrr

type typeExemple : struct
    ch1:int;
    ch2:float;
fstruct

type tab : array[-5_6, -40_50] of typeExemple;

type tabOfTab : array[2_5, -4_8] of tab;

var x : float;
var essai : tabOfTab;

{
    //FONCTION AFFICHER
    //Format qui n'existe pas
    afficher("%p");

    //Format incompatible
    //afficher(" %f %d", x,x);

    //Format en trop
    //afficher("%d %d %d", x);

    //Argument en trop
    //afficher("%d",x,x);

    //FONCTION LIRE
    //Type non simple
    //lire(essai[3][4][5][6]);
}
