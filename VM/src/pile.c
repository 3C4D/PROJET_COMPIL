#include <stdlib.h>
#include <string.h>

#include "../inc/pile.h"
#include "../inc/gest_mem.h"

// Crée et initialise un objet pile
pile init_pile(int taille){
  pile p = safe_malloc(sizeof (struct pile_s));
  p->contenu = safe_malloc(sizeof (blob) * taille);
  p->base = 0;
  p->sommet = -1;
  p->espace = taille;

  return p;
}

// Libère l'espace occupé par l'objet pile
void liberer_pile(pile p){
  if (p != NULL){
    free(p->contenu);
    free(p);
  }
}

// Vérifie qu'il y ait assez d'espace pour empiler
void verif_espace(pile p){
  if (p->sommet >= p->espace - 1){
    while (p->sommet >= p->espace - 1){
      p->espace *= 2;
    }
    p->contenu = safe_realloc(p->contenu, p->espace * sizeof (blob));
  }
}

// Retourne 1 si la pile est vide 0 sinon
int pile_vide(pile p){
  return (p->sommet == -1);
}

// Empile un élément
void empiler(blob elem, pile p){
  verif_espace(p);
  p->contenu[++p->sommet] = elem;
}

// Dépile un élément
blob depiler(pile p){
  if (p->sommet >= 0){
    return p->contenu[p->sommet--];
  } else {
    return -1;
  }
}

// Empile l'espace de n éléments
void empiler_plrs(int n, pile p){
  void *deb;
  p->sommet += n;
  verif_espace(p);
  deb = (void *) (p->contenu + p->sommet - (n - 1));
  memset(deb, 0, sizeof (blob) * n);
}

// Depile l'espace de n éléments
void depiler_plrs(int n, pile p){
  if (n > p->sommet + 1){ n = p->sommet + 1; }

  p->sommet -= n;
  verif_espace(p);
}

// Modifie la valeur à l'index i
void modif_val(blob val, int i, pile p){
  if (i <= p->sommet && i >= 0){
    p->contenu[i] = val;
  }
}

// Récupère la valeur à l'index i
blob recup_val(int i, pile p){
  if (i <= p->sommet  && i >= 0){
    return p->contenu[i];
  } else {
    return 0;
  }
}

// Déplace la base courante de la pile
void depl_base(int nouv_bc, pile p){
  if (nouv_bc <= p->sommet){
    p->base = nouv_bc;
  } else {
    p->base = p->sommet;
  }
}

// Donne la position de la base d'une pile
int pos_base(pile p){
  return p->base;
}

// Donne la position du sommet d'une pile
int pos_som(pile p){
  return p->sommet;
}

