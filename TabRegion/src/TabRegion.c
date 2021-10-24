#include <stdlib.h>
#include <stdio.h>
#include "../inc/TabRegion.h"
#include "../../inc/fct_aux_yacc.h"

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
  printf("\n######################################   TABLE DES REGIONS   ##############################################\n");
  printf("/----------+--------+-----+-------+\\\n");
  printf("Num région | Taille | NIS | Arbre \n");
  printf("+----------+--------+-----+-------+\n" );
  i=0;
  while(TableRegion[i].taille != -1){
    printf("%-11d | %-8d | %-5d | \n",i, TableRegion[i].taille, TableRegion[i].NIS);
    i++;
  }
  printf("\\----------+--------+-----+-------/\n" );

}
