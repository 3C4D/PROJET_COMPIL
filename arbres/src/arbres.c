// Fonctions relatives aux arbres
// Auteurs : Réalisé une fois par tous les membres du groupe

#include <stdlib.h>
#include <stdio.h>
#include "../inc/arbres.h"
#include "../../tablex/inc/tablex.h"

// Crée un arbre vide
arbre creer_arbre_vide(){
  return NULL;
}

// Renvoie 1 si l'arbre est vide, 0 sinon
int est_vide(arbre a){
  return (a == NULL);
}

// Crée un noeud avec le numéro de ce noeud
arbre creer_noeud(int num_noeud){
  arbre a = malloc(sizeof(struct arbre));

  a->num_noeud = num_noeud;
  a->fils_gauche = creer_arbre_vide();
  a->frere_droit = creer_arbre_vide();

  return a;
}

// Concaténation du pere et du fils
arbre concat_pere_fils(arbre pere, arbre fils){
  pere->fils_gauche = fils;
  return pere;
}

// Concaténation du pere et du frere
arbre concat_pere_frere(arbre pere, arbre frere){
  pere->frere_droit = frere;
  return pere;
}

// Permet de connaître récursivement la profondeur d'un arbre
int profondeur_arbre(arbre a){
  if(est_vide(a)){  // Si l'arbre est vide, on renvoie 0
    return 0;
  }
  // Sinon sinon on renvoie la profondeur du fils le plus profond + 1
  if(profondeur_arbre(a->frere_droit) > profondeur_arbre(a->fils_gauche)){
    return 1+profondeur_arbre(a->frere_droit);
  }
  else{
    return 1+profondeur_arbre(a->fils_gauche);
  }
}


// Permet d'afficher un noeud (ie un arbre) récursivement
void aff_noeud(arbre a, int prof, int max_prof){
  int i;

  if(!est_vide(a)){   // Si le noeud n'est pas vide :
    aff_noeud(a->frere_droit, prof+1, max_prof); // On affiche le frere droit
    for (i = 0; i < prof; i++){
      // On affiche le nombre d'espace necessaire
      printf("    ");
    }

    printf("%s <\n", lexeme(a->num_noeud));

    aff_noeud(a->fils_gauche, prof+1, max_prof); // On affiche le fils gauche
  }
  else{                 // Sinon (ie si le noeud est vide) :
    for (i = 0; i < prof; i++) {
      // On affiche le nombre d'espace necessaire
      printf("    ");
    }
    printf("NULL\n");     // On affiche NULL puisque le noeud est vide
  }
}

// Permet d'afficher un arbre de dans le teminal
void afficher_arbre(arbre a){
  aff_noeud(a, 0, profondeur_arbre(a));
}
