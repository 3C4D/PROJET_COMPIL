// Fonctions auxiliaires utilisées dans le programme LEX

#include <stdlib.h>
#include <stdio.h>

extern int nb_ligne;

// Conserve la cohérence de la variable nb_ligne au regard des commentaires
// multi-lignes
void calcul_nb_ligne_comm(char *comm){
  while(*comm != '\0'){
    if(*comm == '\n'){
      nb_ligne++;
    }
    comm++;
  }
}
