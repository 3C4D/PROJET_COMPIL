#ifndef TABDECLA_H
#define TABDECLA_H

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
int inserer_tab_declaration(char *lexeme, int nature, int num_region, int nb_champs, int type, int num_represention_type);

/*Affiche la table des déclarations*/
void afficher_tab_declaration();

#endif
