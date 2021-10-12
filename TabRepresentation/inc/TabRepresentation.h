#ifndef  TAB_REPRESENTATION_H
#define TAB_REPRESENTATION_H

#define MAX_TAB_RPZ 300

int TableRepresentation[MAX_TAB_RPZ];

/*Initialiser la table des représentation*/
void init_tab_representation_type();

/*----------------------------------------------------------------------------
 Utilité : Insère les caractèristique d'un types, d'une procédure, ou d'une fonction
 et renvoie l'indice de la dernière case non vide
  Paramètres : - type : vaut le numéro de déclaration du type du lexème OU le nombre
                 de champs/paramètre/dimension, OU le type de retour d'une fonction
              - num_lexico : vaut le numéro lexico du lexeme, OU -1 si on veut juste
                remplir la/les premières caractéristique
 ----------------------------------------------------------------------------- */
int inserer_tab_representation_type(int type, int num_lexico);

/*----------------------------------------------------------------------------
  Utilité : Affiche la partie rempli de la table des représentations des types
  ----------------------------------------------------------------------------*/
void afficher_tab_representation();

#endif
