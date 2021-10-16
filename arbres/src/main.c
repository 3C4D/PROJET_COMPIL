// Fonction principale

#include <stdlib.h>
#include <stdio.h>
#include "../inc/arbres.h"

int main(){

  arbre a = creer_noeud(2, 3, 4, 5, -1.5), b = creer_noeud(2, 1, 5, 5, -1.5);
  arbre c = creer_noeud(3, 2, 3, 5, -1.5), d = creer_noeud(1, 1, 3, 4, -1.5);

  a = concat_pere_fils(a, b);
  afficher_arbre(a);
  printf("###################\n\n");
  b = concat_pere_frere(b, c);
  afficher_arbre(a);
  printf("###################\n\n");
  c = concat_pere_frere(c, d);
  afficher_arbre(a);
  printf("###################\n\n");

  exit(0);
}
