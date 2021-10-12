#ifndef TABDECLA_H
#define TABDECLA_H
#define TYPE_STRUCT 1
#define TYPE_TAB 2 /*Type tableau*/
#define VAR 3 /*Variable*/
#define PARAMETRE 4
#define PROC 5 /*Procédure*/
#define FCT 6 /*Fonctions*/

typedef struct tabDecla{
  int nature;
  int suivant; /*indice dans la table du prochain lexème de même nom*/
  int num_region;
  int description; /*indice, dans la table de représentation des types, de la
                    description du lexeme*/
  int exec; /*Information sur l'exécution*/
}tabDecla;

/*Initialise la table des déclarations*/
void init_tab_decla();

/*Retourne le numéro dans la table des déclaration du lexème courant*/
int inserer_tab_declaration(int num_lexico, int nature, int num_region, int num_represention_type, int nb_ligne);

/*Affiche la table des déclarations*/
void afficher_tab_declaration();

#endif
