// Module de gestion des entrées sorties du programme CPYRR

#ifndef IO_CPYRR_H_
#define IO_CPYRR_H_

#include "../inc/blob.h"
#include "../inc/pile_exec.h"
#include "../../arbres/inc/arbres.h"

extern pilex pile_exec_g;
extern int reg_actu_g;

void io_affiche(ninja format, arbre args);

void io_lire(arbre vars);

void err_exec(char *msg);

#endif