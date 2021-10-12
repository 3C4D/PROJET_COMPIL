// Prototypes des fonctions concernant la table lexicographique

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

//Calcul le hashcode du lexeme
int calcul_hashcode(char * lexeme);

// Insere le lexème dans la table lexico, retourne le numero lexicographique
int inserer_tab_lex(char *lexeme);

// Affiche la table lexicographique
void affiche_table_lexico();


// Initialise la table lexicographique
void init_table_lexico();

#endif
