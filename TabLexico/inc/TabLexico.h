/* ----- Prototypes des fonctions concernant la table lexicographique ----- */

#ifndef TABLEXICO_H_
#define TABLEXICO_H_

#define MAX_TAB_LEX 500

int TableHC[32];

typedef struct tabLex{
  int longueur;
  char * lexeme;
  int suivant;
}tabLex;

tabLex TableLexico[MAX_TAB_LEX];

/*----------------------------------------------------------------------------
  Utilité : Renvoie le HashCode du lexème
  Paramatère : - lexeme : le lexeme en question
  ----------------------------------------------------------------------------*/
int calcul_hashcode(char * lexeme);

/* Initialise la table lexicographique */
void init_table_lexico();

/*----------------------------------------------------------------------------
  Utilité : Insere le lexème dans la table lexico, et retourne le numero
            lexicographique.
  Paramatère : - lexeme : le lexeme en question
  ----------------------------------------------------------------------------*/
int inserer_tab_lex(char *lexeme);

/* Affiche la table lexicographique */
void affiche_table_lexico();



#endif
