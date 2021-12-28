#ifndef EVAL_CPYRR_H_
#define EVAL_CPYRR_H_

#include "pile_exec.h"
#include "../../arbres/inc/arbres.h"

/* Variable globale et externe au fichier */
extern pilex pile_exec_g;
extern int reg_actu_g;
extern ninja retval_g;

// Évalue la valeur de l'arbre a de manière récursive
ninja eval_arbre(arbre a);

#endif