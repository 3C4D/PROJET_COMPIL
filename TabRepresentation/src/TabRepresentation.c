#include <stdlib.h>
#include <stdio.h>
#include "../inc/TabRepresentation.h"

/*Initialiser la table des représentation*/
void init_tab_representation_type(){
  int i;
  for(i=0; i<MAX_TAB_RPZ; i++){
    TableRepresentation[i] = -1 ; /*Case vide*/
  }
}

/*----------------------------------------------------------------------------
 Utilité : Insère les caractèristique d'un types, d'une procédure, ou d'une fonction
 et renvoie l'indice de la dernière case non vide
  Paramètres : - type : vaut le numéro de déclaration du type du lexème OU le nombre
                 de champs/paramètre/dimension, OU le type de retour d'une fonction
              - num_lexico : vaut le numéro lexico du lexeme, OU -1 si on veut juste
                remplir la/les premières caractéristique
 ----------------------------------------------------------------------------- */
int inserer_tab_representation_type(int type, int num_lexico){
  int premier_indice; /*Indice dans la table des représentation de la première
                       case vide*/
  premier_indice =0;

  /*On cherche la première case vide dans TableRepresentation*/
  while(TableRepresentation[premier_indice] != -1){ /*Tant que la case est prise*/
    premier_indice++; /*On incrémente l'indice*/
  }

  /*Valeur du premier champs : nombre de champs, ou le numéro du type d'un champs*/
  TableRepresentation[premier_indice] = type;

  /*Si on ne rempli pas les premières cases de la table avec nombre champs etc*/
  if(num_lexico != -1){
    TableRepresentation[premier_indice + 1] = num_lexico;
    return (premier_indice+1);
  }else{
    return premier_indice;
  }

}


/*----------------------------------------------------------------------------
  Utilité : Affiche la partie rempli de la table des représentations des types
  ----------------------------------------------------------------------------*/
void afficher_tab_representation(){
  int i=0;
  printf("\n---------------- TABLE REPRESENTATION ---------------- \n");
  while(TableRepresentation[i]!=-1){
    printf("| %d |", TableRepresentation[i]);
    i++;
  }
  printf("\n");
}
