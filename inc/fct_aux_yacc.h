// Prototypes des fonctions auxiliaires utilisées dans le programme YACC

#ifndef FCT_AUX_YACC_H_
#define FCT_AUX_YACC_H_

#define MAX_REGION 40
#define MAX_FORMAT 40

int tab_format[MAX_FORMAT+1];
int pile_region[MAX_REGION+1];

// fonction permettant de déterminer combien et quels formats simples se
// trouvent dans une chaine de caractère
void format(char *str);

// Initialise la pile de région
void init_pile_region();

// Empile une region
void empiler_pile_region(int region);

// Dépile une région
int depiler_pile_region();

// Retourne la tête de la pile des regions
int tete_pile_region();

// Renvoie 1 si la région est dans la pile des régions, 0 sinon
int est_dans_pile_region(int region);

#endif
