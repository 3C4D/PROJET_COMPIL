/* ----- Prototypes des fonctions concernant la table lexicographique ----- */

#ifndef TAB_REGION_H_
#define TAB_REGION_H_

#include "../../arbres/inc/arbres.h"
#define MAX_TAB_REGION 40

typedef struct tabRegion{
  char * nom_region;
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

/*----------------------------------------------------------------------------
  Utilité : Insère dans la table des régions de le nom de la région
            courante.
  Paramatère : -nom : nom de la région  en question.
  ----------------------------------------------------------------------------*/
void inserer_nom_region_tab_region(char * nom);

/*Affiche la table des régions*/
void afficher_tab_region();

// Donne le NIS d'une région
int nis_reg(int reg_num);

// Donne la taille d'une région
int taille_reg(int reg_num);

//Donne le nom de la région
char * nom_reg(int reg_num);

// Charge la table lexico à partir du texte intermédiaire
void charger_table_region(FILE *fic);

arbre arbre_reg(int i);

#endif
