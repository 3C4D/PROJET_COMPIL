// Module de gestion de l'execution

#ifndef EXEC_CPYRR_H_
#define EXEC_CPYRR_H_

#include <stdlib.h>

#include "../../arbres/inc/arbres.h"
#include "../inc/blob.h"

typedef struct{
  // Decalage de la variable
  int dec; 
  // Type de variable
  types nat;
} var_info;


bool exec_arbre(arbre a);
void execution(FILE *fic);
var_info info_pile_var(arbre a);

#endif