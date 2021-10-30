/* ----- Prototypes des fonctions concernant la table lexicographique ----- */

#ifndef TAB_REGION_H_
#define TAB_REGION_H_

#include "../../arbres/inc/arbres.h"
#define MAX_TAB_REGION 40

typedef struct tabRegion{
  int taille; /*Taille de la zone de données associée dans la pile d'execution*/
  int NIS; /*Niveau d'imbrication statique de la région*/
  arbre arbre_region; /*Pointeur vers l'arbre de la région*/
}tabRegion;

/*Initialise la table des régions*/
void init_tab_region();

/*----------------------------------------------------------------------------
  Utilité : Insère dans la table des régions de la taille et du NIS de la région
            courante.
  Paramatères : - taille : taille de la région à l'exécution.
                - nis : niveau d'imbrication statique de la région.
  ----------------------------------------------------------------------------*/
void inserer_tab_region(int taille, int nis);

/*----------------------------------------------------------------------------
  Utilité : Insère dans la table des régions de l'arbre de la région
            courante.
  Paramatère : - a : arbre de la région  en question/
  ----------------------------------------------------------------------------*/
void inserer_arbre_tab_region(arbre a);

/*Affiche la table des régions*/
void afficher_tab_region();

// Charge la table lexico à partir du texte intermédiaire
void charger_table_region(FILE *fic);

#endif
