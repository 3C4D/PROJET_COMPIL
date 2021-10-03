// Prototypes des fonctions relatives aux arbres
// Auteurs : Réalisé une fois par tous les membres du groupe

#ifndef ARBRES_H_
#define ARBRES_H_

typedef struct arbre{
  int num_noeud;
  struct arbre *fils_gauche;
  struct arbre *frere_droit;
}* arbre;


// Crée un arbre vide
arbre creer_arbre_vide();

// Renvoie 1 si l'arbre est vide, 0 sinon
int est_vide(arbre a);

// Crée un noeud avec le numéro de ce noeud
arbre creer_noeud(int num_noeud);

// Concaténation du pere et du fils
arbre concat_pere_fils(arbre pere, arbre fils);

// Concaténation du pere et du frere
arbre concat_pere_frere(arbre pere, arbre fils);

// Permet d'afficher un arbre de dans le teminal
void afficher_arbre(arbre a);

#endif
