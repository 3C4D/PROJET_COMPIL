// Module de gestion des entrées sorties du programme CPYRR

#ifndef IO_CPYRR_H_
#define IO_CPYRR_H_

#include "../inc/blob.h"
#include "../inc/pile_exec.h"
#include "../../arbres/inc/arbres.h"

/* Variable globale et externe au fichier */
extern pilex pile_exec_g;
extern int reg_actu_g;

// Affiche sur la sortie standard les variables données par args selon le format 
void io_affiche(ninja format, arbre args);

// Lit sur l'entrée standard les variables données par vars
void io_lire(arbre vars);

// Affiche une erreur d'exécution
void err_exec(char *msg);

#endif