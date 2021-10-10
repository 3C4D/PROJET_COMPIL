// Fonction principale

#include <stdlib.h>
#include <stdio.h>
#include "../inc/arbres.h"

int main(){

  arbre a = creer_noeud(5, -1), b = creer_noeud(6, -1);
  arbre c = creer_noeud(7, -1), d = creer_noeud(8, -1);

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
