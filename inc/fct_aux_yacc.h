// Prototypes des fonctions auxiliaires utilisées dans le programme YACC

#ifndef FCT_AUX_YACC_H_
#define FCT_AUX_YACC_H_

#include "../TabRegion/inc/TabRegion.h"

#define MAX_REGION 40
#define MAX_FORMAT 40

#define TYPE_INT 0
#define TYPE_FLOAT 1
#define TYPE_BOOL 2
#define TYPE_CHAR 3
#define TYPE_STR 4

#define INIT 0
#define STRUCTURE 1
#define DIMENSION 2
#define VAR_SIMPLE 3

// Fonction d'usage du compilateur
void usage(char *s);

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

// Vérification de la cohérence des types pour une expression renvoyant un
// résultat numérique (ou caractère), renvoie le type final, -1 si erreur
int verif_type_expr_arithm(int type_g, int type_d, int nb_ligne);

// Vérification de la cohérence des types pour une expression renvoyant un
// booleen
int verif_type_expr_bool(int type_g, int type_d, int nb_ligne);

// Vérifie si un appel de fonction ou procédure, est correctement fait
int verif_arg_appel(int num_decla, int tab_arg_appel[], int nb_ligne);

// Retourne la valeur du dernier déplacement
int deplacement();

// Modifie la valeur du champs deplacement_var
void change_deplacement(int valeur);

// Retourne la valeur du dernier deplacement_struct
int deplacement_struct();

// Modifie la valeur du champs deplacement_struct
void change_deplacement_struct(int valeur);

// Modifie la valeur de nis_region
void change_NIS(int valeur);

// Renvoie la valeur de nis_region
int nis();

// Analyse les options passées au compilateur et lève les flags adéquats,
// renvoie eventuellement l'index du fichier output dans argv, sinon -1
int analyse_options(char *argv[], int *flags);

// Affiche une erreur sémantique dans le terminal
void print_erreur_semantique(char *erreur);
#endif
