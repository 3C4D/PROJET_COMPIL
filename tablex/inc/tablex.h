// Prototypes des fonctions concernant la table lexicographique
// Auteurs : Réalisé une fois par tous les membres du groupe

#ifndef TABLEXICO_H_
#define TABLEXICO_H_

typedef struct cell_lexeme{
  int longueur;
  char *lexeme;
  struct cell_lexeme *suivant;
}cell_lexeme;

// Retourne le hash-code du lexème
int hash_code(char *lexeme);

// Insere le lexème dans la table lexico, retourne le numero lexicographique
int inserer(char *lexeme);

// Retourne le lexème associé à ce numéro lexicographique
char *lexeme(int num_lexico);

// Affiche la table lexicographique
void affiche_table_lexico();

// Initialise la table lexicographique
void init_table_lexico();

#endif
