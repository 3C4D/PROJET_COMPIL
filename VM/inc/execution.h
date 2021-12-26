// Module de gestion de l'execution

#ifndef EXEC_CPYRR_H_
#define EXEC_CPYRR_H_

#include <stdlib.h>

#include "../../arbres/inc/arbres.h"
#include "../inc/blob.h"

// Struture décrivant les informations sur une variabale dans la pile
typedef struct{
  // Decalage de la variable
  int dec; 
  // Type de variable
  types nat;
} var_info;


// Exécute récursivement l'arbre a
bool exec_arbre(arbre a);

// Execute le fichier de texte intermediare fic
void execution(FILE *fic);

// Donne les information sur la variable décrite par l'arbre a
var_info info_pile_var(arbre a);

#endif