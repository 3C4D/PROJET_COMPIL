// Fonctions relatives aux arbres
// Auteurs : Réalisé une fois par tous les membres du groupe

#include <stdlib.h>
#include <stdio.h>
#include "../inc/arbres.h"
#include "../../TabLexico/inc/TabLexico.h"

// Crée un arbre vide
arbre creer_arbre_vide(){
  return NULL;
}

// Renvoie 1 si l'arbre est vide, 0 sinon
int est_vide(arbre a){
  return (a == NULL);
}

// Crée un noeud avec ses caractéristiques
arbre creer_noeud(int numlex, int numdecl, int nature, int val_e, int val_r){
  arbre a = malloc(sizeof(struct arbre));

  a->numlex = numlex;
  a->numdecl = numdecl;
  a->nature = nature;
  a->entier = val_e;
  a->reel = val_r;
  a->fils_gauche = creer_arbre_vide();
  a->frere_droit = creer_arbre_vide();

  return a;
}

// Concaténation du pere et du fils
arbre concat_pere_fils(arbre pere, arbre fils){
  if(!est_vide(fils)){
    pere->fils_gauche = fils;
  }
  return pere;
}

// Concaténation du pere et du frere
arbre concat_pere_frere(arbre pere, arbre frere){
  if(!est_vide(frere)){
    pere->frere_droit = frere;
  }
  return pere;
}

// Permet d'afficher un noeud (ie un arbre) récursivement
void aff_noeud(arbre a, int prof){
  int i;

  if(!est_vide(a)){   // Si le noeud n'est pas vide :
    for (i = 0; i < prof; i++){
      // On affiche le nombre d'espace necessaire
      printf("  ");
    }

    if(a->numlex > 0){
      printf(
        "|+| (%s), %d, %d, %d, %f\n",
        lexeme(a->numlex),
        a->numdecl,
        a->nature,
        a->entier,
        a->reel
      );
    }
    else{
      printf(
        "|+| %d, %d, %d, %d, %f\n",
        a->numlex,
        a->numdecl,
        a->nature,
        a->entier,
        a->reel
      );
    }

    aff_noeud(a->frere_droit, prof+1);  // On affiche le frere droit
    aff_noeud(a->fils_gauche, prof+1);  // On affiche le fils gauche
  }
  else{
    for (i = 0; i < prof; i++){
      // On affiche le nombre d'espace necessaire
      printf("   ");
    }
    printf("null\n");
  }
}

// Permet d'afficher un arbre de dans le teminal
void afficher_arbre(arbre a){
  aff_noeud(a, 0);
}
