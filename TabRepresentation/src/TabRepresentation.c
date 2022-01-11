#include <stdlib.h>
#include <stdio.h>
#include "../inc/TabRepresentation.h"
#include "../../TabLexico/inc/TabLexico.h"
#include "../../inc/fct_aux_yacc.h"

int TableRepresentation[MAX_TAB_RPZ];
int premier_indice_var;
int indice_libre;

/*Initialiser la table des représentation*/
void init_tab_representation_type(){
  int i;
  indice_libre = 0;
  for(i=0; i<MAX_TAB_RPZ; i++){
    TableRepresentation[i] = -1 ; /*Case vide*/
  }
}

/*----------------------------------------------------------------------------
 Utilité : Insère les caractèristique d'un types, d'une procédure, ou d'une fonction
 et renvoie l'indice de la premiere case qui était vide.
  Paramètres : - type : vaut le numéro de déclaration du type du lexème OU le nombre
                 de champs/paramètre/dimension, OU le type de retour d'une fonction
              - num_lexico : vaut le numéro lexico du lexeme, OU -1 si on veut juste
                remplir la/les premières caractéristique
              - nature : précise la nature.
 ----------------------------------------------------------------------------- */
int inserer_tab_representation_type(int type, int num_lexico, int nature){

  switch (nature) {
    case TYPE_STRUCT:
      if(num_lexico == -1){ /*Signifie qu'on veut remplir la toute premiere case
                            c-a-d le nombre de champs de la structure*/
        TableRepresentation[indice_libre] = type;
        indice_libre +=1;

        return indice_libre-1;

      }else{ /*C'est qu'on est face à un champs de la structure */
        TableRepresentation[indice_libre] = type;
        TableRepresentation[indice_libre + 1] = num_lexico;
        TableRepresentation[indice_libre+ 2] = -11; /*Deplacement à l'execution*/
        indice_libre += 3;
        return (indice_libre - 3);
      }
      break;
    case TYPE_TAB:
      /*Soit le type des éléments du tableau, soit la borne inf d'une des dimensions*/
      TableRepresentation[indice_libre] = type;
      /*Soit le nombre de dimension, soit la borne sup d'une des dimensions*/
      TableRepresentation[indice_libre+ 1] = num_lexico;
      indice_libre += 2;
      return (indice_libre-2);
      break;
    case FCT:
      /*Soit le type de retour de la fonction, soit le type d'un des paramètres*/
      TableRepresentation[indice_libre] = type;
      /*Soit le nombre de paramètre, soit le numéro lexico d'un des paramètres*/
      TableRepresentation[indice_libre+1] = num_lexico;
      indice_libre +=2;
      return (indice_libre-2);
      break;
    case PROC:
      if(num_lexico == -1){ /*On veut rentrer le nombre de paramètre*/
        TableRepresentation[indice_libre] = type;
        indice_libre+=1;
        return indice_libre-1;
      }else{/*Sinon c'est qu'on est face à un parametre de la procédure*/
        /*Le type de ce paramètre*/
        TableRepresentation[indice_libre] = type;
        /*Son numéro lexicographique*/
        TableRepresentation[indice_libre + 1] = num_lexico;
        indice_libre +=2;
        return indice_libre-2;
      }
      break;
    default:
      fprintf(
        stderr,
        "Problème de nature dans l'insertion dans la table des représentations des types \n"
      );
      exit(-1);
  }

}

/*----------------------------------------------------------------------------
 Utilité : Insère à l'indice donné, la valeur donnée.
  Paramètres : - indice : indice en question.
              - valeur : valeur à inserer à l'indice donné.
 ----------------------------------------------------------------------------- */
void stocker_table_representation(int indice, int valeur){
  TableRepresentation[indice] = valeur;
}

/*----------------------------------------------------------------------------
 Utilité : Retourne le champs, à l'indice donnée, dans la table des réprésentation
          des types.
  Paramètre : - indice : indice en question.
 ----------------------------------------------------------------------------- */
 int valeur_tab_representation(int indice){
   return TableRepresentation[indice];
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

/*----------------------------------------------------------------------------
 Utilité : Retourne la valeur de la variable globale premier_indice.
 ----------------------------------------------------------------------------- */
int premier_indice(){
   return premier_indice_var;
}

/*----------------------------------------------------------------------------
  Utilité : Change la valeur de la variable globale premier_indice par la valeur
            donnée.
  Paramètre : - valeur : la valeur en question.
----------------------------------------------------------------------------- */
void change_premier_indice(int valeur){
  premier_indice_var = valeur;
}

/*----------------------------------------------------------------------------
  Utilité : Ajoute la valeur donnée dans la table.
  Paramètre : - valeur : la valeur en question.
----------------------------------------------------------------------------- */
void ajouter_table_represention(int valeur){
  TableRepresentation[indice_libre] = valeur;
  indice_libre+=1;
}

/*----------------------------------------------------------------------------
  Utilité : Renvoie la donnée contenue à l'index indice.
  Paramètre : - indice : indice que de la table dont on veut connaitre la donnée
----------------------------------------------------------------------------- */
int valeur_tab_types(int indice){
  return TableRepresentation[indice];
}

/*----------------------------------------------------------------------------
  Utilité : Vérifie la sémantique d'une structure : si i l n'y pas plusieurs
  champs de même lexème.
  Paramètre : - _premier_indice : indice que de la table dont on veut connaitre la donnée
----------------------------------------------------------------------------- */
int verif_surcharge_struct(int premier_indice, int nb_ligne, int nom_struct){
  int i, j;
  int nb_champs;
  int indice, indice_bis;

  indice = 0;

  nb_champs = TableRepresentation[premier_indice];
  for(i = 2 ; i<3*nb_champs +1; i= i+3){
    indice += 1;
    indice_bis = 0;
    for(j=2 ; j<3*nb_champs+1; j = j+3){
      indice_bis += 1;
      /*Si on a deux numéros lexicographique identique pour deux champs différents*/
      if(i != j){
        if(TableRepresentation[premier_indice+i] == TableRepresentation[premier_indice+j]){
          char erreur[400];
          sprintf(erreur,
          "Le champs numéro %d (%s) et le champs numéro %d (%s) de la structure %s déclarée ligne %d portent le même nom",
          indice,
          lexeme(TableRepresentation[premier_indice+i]),
          indice_bis,
          lexeme(TableRepresentation[premier_indice+j]),
          lexeme(nom_struct),
          nb_ligne);

          print_erreur_semantique(erreur);
          return -1;
        }
      }
    }
  }

  return 0;
}

// Charge la table des représentations à partir du texte intermédiaire
void charger_table_representation(FILE *fic){
  int i = 0, retour = 0, indice;
  retour = fscanf(fic, "%d|", &indice);
  for(i = 0; i < indice; i++){
    if(retour == -1){
      fprintf(stderr, "Erreur chargement table representation\n");
      exit(-1);
    }
    retour = fscanf(fic, "%d|", &TableRepresentation[i]);
  }
}
