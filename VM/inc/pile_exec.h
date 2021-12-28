// Module implantant le TAD de la pile d'execution

#ifndef PILE_EXEC_H_
#define PILE_EXEC_H_

#include "blob.h"

#define LIMITE_DEBUG 100

typedef struct mem_s {
  types nat;
  int id;
  blob data;
} mem;

typedef struct pilex_s {
  mem *pile;
  int espace;
  int base;
  int sommet;
} *pilex;

// Initialise un fragment de pile
mem mem_init(blob data, types nat, int id);

// Initialise un objet pile d'execution
pilex pilex_init(int taille);
// Libère l'espace occupé par l'objet pile d'execution
void pilex_liberer(pilex px);

// Retourne 1 si la pile d'execution est vide 0 sinon
int pilex_vide(pilex px);
// Empile un élément
void pilex_emp(mem m, pilex px);
// Dépile un élément
mem pilex_dep(pilex px);
// Empile un espace vide de n éléments
void pilex_empn(int n, pilex px);
// Depile un espace de n éléments
void pilex_depn(int n, pilex px);

// Modifie la memoire à l'index i
void pilex_modval(mem val, int i, pilex px);
// Modifie la memoire en sommet de pile
void pilex_modsom(mem val, pilex px);
// Modifie la memoire à la base + un decalage dec
void pilex_modbase(mem val, int dec, pilex px);

// Récupère la memoire à l'index i
mem pilex_recval(int i, pilex px);
// Récupère la memoire en sommet de pile
mem pilex_recsomval(pilex px);
// Récupère la memoire à la base + un decalage dec
mem pilex_recbaseval(int dec, pilex px);

// Déplace la base courante de la pile d'execution
void pilex_deplbase(int nouv_bc, pilex px);
// Donne la position de la base d'une pile d'execution
int pilex_posbase(pilex px);
// Donne la position du sommet d'une pile d'execution
int pilex_possom(pilex px);

//Affiche le contenu de la pile d'execution
void pilex_aff(pilex px, int lim);

#endif