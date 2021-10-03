// Fonction principale de test du prototype de table lexicographique

#include <stdlib.h>
#include <stdio.h>
#include "../inc/tablex.h"

int main(void){
  init_table_lexico();
  affiche_table_lexico();
  printf("\ntest :\n");
  inserer("bonjour");
  inserer("je");
  inserer("x42b");
  inserer("y12");
  inserer("asterix");
  inserer("obelix");
  inserer("xobeli");
  inserer("barnabe");
  affiche_table_lexico();
  exit(0);
}
