// Fonction principale de test du prototype de table lexicographique

#include <stdlib.h>
#include <stdio.h>
#include "../inc/TabLexico.h"

int main(void){
  init_table_lexico();
  affiche_table_lexico();
  printf("\ntest :\n");
  inserer_tab_lex("bonjour");
  inserer_tab_lex("je");
  inserer_tab_lex("x42b");
  inserer_tab_lex("y12");
  inserer_tab_lex("asterix");
  inserer_tab_lex("obelix");
  inserer_tab_lex("xobeli");
  inserer_tab_lex("barnabe");
  affiche_table_lexico();
  exit(0);
}
