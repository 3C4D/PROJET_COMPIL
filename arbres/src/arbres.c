// Fonctions relatives aux arbres
// Auteurs : Réalisé une fois par tous les membres du groupe

#include <stdlib.h>
#include <stdio.h>
#include "../inc/arbres.h"
#include "../../TabLexico/inc/TabLexico.h"
#include "../../inc/macros_arbres.h"

// Crée un arbre vide
arbre creer_arbre_vide(){
  return NULL;
}

// Renvoie 1 si l'arbre est vide, 0 sinon
int est_vide(arbre a){
  return (a == NULL);
}

// Crée un noeud avec ses caractéristiques
arbre creer_noeud(int numlex, int numdecl, int nature, int val_e, double val_r){
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

// Permet d'afficher la nature d'un noeud
void aff_nature_noeud(int nature){
  switch(nature){
    case A_LISTE_INSTR : printf("A_LISTE_INSTR"); break;
    case A_AFFECTATION : printf("A_AFFECTATION"); break;
    case A_SI_ALORS : printf("A_SI_ALORS"); break;
    case A_SI_ALORS_SINON : printf("A_SI_ALORS_SINON"); break;
    case A_TANT_QUE : printf("A_TANT_QUE"); break;
    case A_AFFICHER : printf("A_AFFICHER"); break;
    case A_LIRE : printf("A_LIRE"); break;
    case A_APPEL_PROC : printf("A_APPEL_PROC"); break;
    case A_APPEL_FCT : printf("A_APPEL_FCT"); break;
    case A_RETOURNE : printf("A_RETOURNE"); break;
    case A_LISTE_ARG : printf("A_LISTE_ARG"); break;
    case A_LISTE_VAR : printf("A_LISTE_VAR"); break;
    case A_VARIABLE : printf("A_VARIABLE"); break;
    case A_EXPRESSION : printf("A_EXPRESSION"); break;
    case A_PLUS : printf("A_PLUS"); break;
    case A_MOINS : printf("A_MOINS"); break;
    case A_MULT : printf("A_MULT"); break;
    case A_DIV : printf("A_DIV"); break;
    case A_MODULO : printf("A_MODULO"); break;
    case A_ET : printf("A_ET"); break;
    case A_OU : printf("A_OU"); break;
    case A_NON : printf("A_NON"); break;
    case A_EGAL : printf("A_EGAL"); break;
    case A_DIFFERENT : printf("A_DIFFERENT"); break;
    case A_SUP : printf("A_SUP"); break;
    case A_SUP_EGAL : printf("A_SUP_EGAL"); break;
    case A_INF : printf("A_INF"); break;
    case A_INF_EGAL : printf("A_INF_EGAL"); break;
    case A_CONCAT : printf("A_CONCAT"); break;
    case A_CSTE_ENT : printf("A_CSTE_ENT"); break;
    case A_CSTE_REEL : printf("A_CSTE_REEL"); break;
    case A_CSTE_CHAR : printf("A_CSTE_CHAR"); break;
    case A_CSTE_CHAINE : printf("A_CSTE_CHAINE"); break;
    case A_TRUE : printf("A_TRUE"); break;
    case A_FALSE : printf("A_FALSE"); break;
    case A_VIDE : printf("A_VIDE"); break;
    case A_CHAMP : printf("A_CHAMP"); break;
    case A_TAB : printf("A_TAB"); break;
    case A_VAR : printf("A_VAR"); break;
    default : printf("INCONNU"); break;
  }
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
        "|+| (%s), %d, ",
        lexeme(a->numlex),
        a->numdecl
      );
      aff_nature_noeud(a->nature);
      printf(", %d, %f\n",
        a->entier,
        a->reel
      );
    }
    else{
      printf(
        "|+| (%d), %d, ",
        a->numlex,
        a->numdecl
      );
      aff_nature_noeud(a->nature);
      printf(", %d, %f\n",
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

// serialize
void serialize(FILE *fic, arbre a){
  if(est_vide(a)){
    fprintf(fic, "$|")
  }

  else{
    fprintf(
      fic,
      "%d|%d|%d|%d|%f",
      a->numlex,
      a->numdecl,
      a->nature,
      a->entier,
      a->reel
    );
  }

  serialize(a->fils_gauche);
  serialize(a->frere_droit);
}

arbre deserialize(tab_arbre t){
  arbre a = creer_arbre_vide();
  deserialize_aux(tab_arbre t, a);
  return a;
}

void deserialize_aux(tab_arbre **t, arbre a){
  if(t[0] != NULL){
    a = creer_noeud(
      **t.numlex
      **t.numdecl
      **t.nature
      **t.entier
      **t.reel
    );

    *t += 1;
    a->fils_gauche = deserialize_aux(t, a->fils_gauche);
    *t += 1;
    a->fils_droit = deserialize_aux(t, a->frere_droit);
  }
}
