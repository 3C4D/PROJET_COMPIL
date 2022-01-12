cpyrr
var x : float;
{
    //FONCTION AFFICHER
    //Format qui n'existe pas
    afficher("%p");

    //Format incompatible
    afficher(" %f %d", x,x);

    //Format en trop
    afficher("%d %d %d", x);

    //Argument en trop
    afficher("%d",x,x);

    //FONCTION LIRE

}
