#ifndef EVAL_CPYRR_H_
#define EVAL_CPYRR_H_

#include "pile_exec.h"
#include "../../arbres/inc/arbres.h"

extern pilex pile_exec_g;
extern int reg_actu_g;
extern ninja retval_g;

ninja eval_arbre(arbre a);

#endif