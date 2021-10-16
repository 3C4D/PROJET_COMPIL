/*- Prototypes des fonctions concernantla table des représentations des types -*/
#ifndef  TAB_REPRESENTATION_H
#define TAB_REPRESENTATION_H

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
 ----------------------------------------------------------------------------- */
int inserer_tab_representation_type(int type, int num_lexico);

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


#endif
