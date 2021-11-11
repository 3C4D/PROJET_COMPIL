// Module implantant le TAD de la pile

#ifndef PILE_H_
#define PILE_H_

#include "blob.h"

struct pile_s {
  blob *contenu;
  int espace;
  int base;
  int sommet;
};

typedef struct pile_s *pile;

pile init_pile(int taille);
void liberer_pile(pile p);
void verif_espace(pile p);
int pile_vide(pile p);
void empiler(blob elem, pile p);
blob depiler(pile p);
void empiler_plrs(int n, pile p);
void depiler_plrs(int n, pile p);
void depl_base(int nouv_bc, pile p);
void modif_val(blob val, int i, pile p);

// Récupère la valeur à l'index i
blob recup_val(int i, pile p);

// Donne la position de la base d'une pile
int pos_base(pile p);

// Donne la position du sommet d'une pile
int pos_som(pile p);

#endif