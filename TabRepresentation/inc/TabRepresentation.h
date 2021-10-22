/*- Prototypes des fonctions concernantla table des représentations des types -*/
#ifndef  TAB_REPRESENTATION_H
#define TAB_REPRESENTATION_H

#include "../../TabDecla/inc/TabDecla.h"

#define MAX_TAB_RPZ 300

int TableRepresentation[MAX_TAB_RPZ];
int premier_indice_var;

/*Initialiser la table des représentation*/
void init_tab_representation_type();

/*----------------------------------------------------------------------------
 Utilité : Insère les caractèristique d'un types, d'une procédure, ou d'une fonction
 et renvoie l'indice de la dernière case non vide
  Paramètres : - type : vaut le numéro de déclaration du type du lexème OU le nombre
                 de champs/paramètre/dimension, OU le type de retour d'une fonction
              - num_lexico : vaut le numéro lexico du lexeme, OU -1 si on veut juste
                remplir la/les premières caractéristique
              - nature : précise la nature.
 ----------------------------------------------------------------------------- */
int inserer_tab_representation_type(int type, int num_lexico, int nature);

/*----------------------------------------------------------------------------
 Utilité : Insère à l'indice donné, la valeur donnée.
  Paramètres : - indice : indice en question.
              - valeur : valeur à inserer à l'indice donné.
 ----------------------------------------------------------------------------- */
void stocker_table_representation(int indice, int valeur);

/*----------------------------------------------------------------------------
 Utilité : Retourne le champs, à l'indice donnée, dans la table des réprésentation
          des types.
  Paramètre : - indice : indice en question.
 ----------------------------------------------------------------------------- */
 int valeur_tab_representation(int indice);

/*----------------------------------------------------------------------------
  Utilité : Affiche la partie rempli de la table des représentations des types
  ----------------------------------------------------------------------------*/
void afficher_tab_representation();

/*----------------------------------------------------------------------------
 Utilité : Retourne la valeur de la variable globale premier_indice.
 ----------------------------------------------------------------------------- */
int premier_indice();

 /*----------------------------------------------------------------------------
  Utilité : Change la valeur de la variable globale premier_indice par la valeur
            donnée.
  Paramètre : - valeur : la valeur en question.
  ----------------------------------------------------------------------------- */
void change_premier_indice(int valeur);

/*----------------------------------------------------------------------------
  Utilité : Renvoie la donnée contenue à l'index indice.
  Paramètre : - indice : indice que de la table dont on veut connaitre la donnée
----------------------------------------------------------------------------- */
int valeur_tab_types(int indice);

/*----------------------------------------------------------------------------
  Utilité : Vérifie la sémantique d'une structure : si i l n'y pas plusieurs
  champs de même lexème.
  Paramètre : - indice : indice que de la table dont on veut connaitre la donnée
----------------------------------------------------------------------------- */
int verif_surchage_struct(int premier_indice, int nb_ligne);

#endif
