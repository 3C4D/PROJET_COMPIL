/* ----- Prototypes des fonctions concernant la table des déclarations ----- */

#ifndef TABDECLA_H
#define TABDECLA_H

#define MAX_TAB_DECLA 5000

#define TYPE_BASE 0
#define TYPE_STRUCT 1
#define TYPE_TAB 2 /*Type tableau*/
#define VAR 3 /*Variable*/
#define PARAMETRE 4
#define PROC 5 /*Procédure*/
#define FCT 6 /*Fonctions*/
#define APPEL 7 /* Appel */

typedef struct tabDecla{
  int nature;
  int suivant; /*indice dans la table du prochain lexème de même nom*/
  int num_region;
  int description; /*indice, dans la table de représentation des types, de la
                    description du lexeme*/
  int exec; /*Information sur l'exécution*/
}tabDecla;

tabDecla TableDeclaration[MAX_TAB_DECLA];

/*Initialise la table des déclarations*/
void init_tab_decla();

/*-----------------------------------------------------------------------------
  Utilité fonction : Retourne le numéro dans la table des déclaration du lexème
                    courant
  Paramètres : - num_lexico : numéro lexicographique du lexeme courant
              - nature
              - num_region
              - num_represention_type : (Variable ou paramatère) numéro de
                déclaration du type du lexème
               courant OU (procédure, fonction, structure, tableau) l'indice dans
               la table des représentation
              - nb_ligne : numéro de la ligne à laquelle on est.
 -----------------------------------------------------------------------------*/
int inserer_tab_declaration(int num_lexico, int nature, int num_region,
                            int num_represention_type,
                              int nb_ligne);


/*----------------------------------------------------------------------------
Utilité : Rempli le champs exec pour une fonction/procédure avec le num_region_engendree
Paramètre :  num_region_engendree : numéro de la région engendrée par la
                                    prodédure/fonction en question.
----------------------------------------------------------------------------- */
void inserer_exec_tab_decla(int num_decla, int num_region_engendree);

/*Affiche la table des déclarations*/
void afficher_tab_declaration();

/*----------------------------------------------------------------------------
  Utilité : Renvoie le numéro de déclaration du lexème si il est déclaré, -1
  sinon.
  Paramatères : - num_lexico : numéro du lexème en question.
                - nature : nature du lexème en question (si c'est une procédure,
               fonction, ...)
               - region_particuliere : deux cas :
                  * egal à -1, dans ce cas on cherche le numéro de déclaration
                    du lexème (si il est déclaré) dans n'importe quelle région
                    présente dans la pile des régions.
                  * égal à la région courante , dans ce cas, on regarde si le
                  le lexème est déjà déclaré dans cette région particuliere;

  ----------------------------------------------------------------------------*/
int num_decla(int num_lexico, int nature, int region_particuliere);

/*----------------------------------------------------------------------------
 Utilité : Retourne le champs décription à l'indice donnée dans la table des
          déclarations.
  Paramètre : - indice : indice en question.
 ----------------------------------------------------------------------------- */
 int valeur_description_tab_decla(int indice);

 /*----------------------------------------------------------------------------
  Utilité : Renvoie le numéro de région d'une certaine déclaration
   Paramètre : - num_decla : numéro de déclaration en question
  ----------------------------------------------------------------------------- */
 int region(int num_decla);

 /*----------------------------------------------------------------------------
  Utilité : Renvoie la nature d'une certaine déclaration
   Paramètre : - num_decla : numéro de déclaration en question
  ----------------------------------------------------------------------------- */
 int nature(int num_decla);

 /*----------------------------------------------------------------------------
  Utilité : Renvoie le champs execution d'une certaine déclaration
   Paramètre : - num_decla : numéro de déclaration en question
  ----------------------------------------------------------------------------- */
 int valeur_exec_tab_decla(int num_decla);

 /*----------------------------------------------------------------------------
  Utilité :  Renvoie le numéro de déclaration d'une variable
   Paramètre : - numlex : numéro léxicographique du lexeme
  ----------------------------------------------------------------------------- */
 int num_decla_variable(int numlex);



#endif
