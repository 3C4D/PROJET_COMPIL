#include <stdlib.h>
#include <stdio.h>
#include "../inc/TabRegion.h"
#include "../../inc/fct_aux_yacc.h"

tabRegion TableRegion[MAX_TAB_REGION];

/*Initialise la table des régions*/
void init_tab_region(){
  int i;
  for(i=0; i<MAX_TAB_REGION; i++){
    TableRegion[i].taille = -1;
    TableRegion[i].NIS = -1;
    TableRegion[i].arbre_region = NULL;
  }
}

/*----------------------------------------------------------------------------
  Utilité : Insère dans la table des régions de la taille et du NIS de la région
            courante.
  Paramatères : - taille : taille de la région à l'exécution.
                - nis : niveau d'imbrication statique de la région.
  ----------------------------------------------------------------------------*/
void inserer_tab_region(int taille, int nis){
  int region  = tete_pile_region();

  TableRegion[region].taille = taille + nis;
  TableRegion[region].NIS = nis;
}

/*----------------------------------------------------------------------------
  Utilité : Insère dans la table des régions de l'arbre de la région
            courante.
  Paramatère : - a : arbre de la région  en question/
  ----------------------------------------------------------------------------*/
void inserer_arbre_tab_region(arbre a){
  int region = tete_pile_region();

  TableRegion[region].arbre_region = a;
}

/*Affiche la table des régions*/
void afficher_tab_region(){
  int i;
  printf("\n######   TABLE DES REGIONS   ######\n");
  printf("/------------+--------+-----+-------+\\\n");
  printf("| Num région | Taille | NIS | Arbre |\n");
  printf("+------------+--------+-----+-------+\n" );
  i=0;
  while(TableRegion[i].taille != -1){
    printf("|     %-6d |   %-4d |  %-2d |       |\n",i, TableRegion[i].taille, TableRegion[i].NIS);
    i++;
  }
  printf("\\------------+--------+-----+-------/\n" );
}

// Charge la table lexico à partir du texte intermédiaire
void charger_table_region(FILE *fic){
  int i = 0, j, retour = 0;
  tab_arbre tab[2000];
  do{
    retour = fscanf(fic, "%d|%d|", &TableRegion[i].taille, &TableRegion[i].NIS);

    if(TableRegion[i].NIS != -1){
      j = 0;
      do{
        retour = fscanf(
          fic,
          "%d|%d|%d|%d|%lf|",
          &tab[j].numlex,
          &tab[j].numdecl,
          &tab[j].nature,
          &tab[j].entier,
          &tab[j].reel
        );
        j++;
      }while(retour != -1 && tab[j-1].nature != -99);
      TableRegion[i].arbre_region = charger_arbre(tab);
    }
    i++;
  }while(retour != -1 && TableRegion[i-1].NIS != -1);
}
