// Fonctions auxiliaires utilisées dans le programme YACC

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "../inc/fct_aux_yacc.h"
#include "../TabDecla/inc/TabDecla.h"
#include "../TabRepresentation/inc/TabRepresentation.h"
#include "../TabRegion/inc/TabRegion.h"
#include "../inc/couleur.h"

#define MAX_IMBR_VAR 30

int tab_format[MAX_FORMAT+1];
int pile_region[MAX_REGION+1];
int pile_variable[MAX_IMBR_VAR+1];
int deplacement_var[MAX_REGION];
int deplacement_structure;
int nis_region;
int nb_ligne = 1;
FILE *programme;
int ligne_act = 0;

// Affiche une erreur sémantique dans le terminal
void print_erreur_semantique(char *erreur){
  int i;
  char c = '\0';
  // Plus d'une erreur sur une ligne, on passe
  if(ligne_act >= nb_ligne){
    return;
  }

  // On egraine jusqu'à la ligne
  for(i = ligne_act; i < nb_ligne-1; i++){
    c = '\0';
    while(c != '\n'){
      c = fgetc(programme);
    }
  }
  ligne_act = nb_ligne;

  couleur(MAGENTAGRAS);
  // On imprime la ligne précédée du numéro de ligne
  fprintf(stderr, "\nErreur sémantique : %s\n", erreur);
  couleur(BLANCGRAS);
  fprintf(stderr, " %d |  ", nb_ligne);
  couleur(RESET);
  c = '\0';
  c = fgetc(programme);
  while(c != '\n'){
    fprintf(stderr, "%c", c);
    c = fgetc(programme);
  }
  fprintf(stderr, "\n\n");
}

// Fonction d'usage du compilateur
void usage(char *s){
  fprintf(stderr,"\n%s [OPTIONS] <prog_cpyrr>\n", s);
  fprintf(stderr,"     * [OPTIONS] :\n");
  fprintf(
    stderr,
    "         * o <output> : précision du fichier d'ouput (défaut : a.out)\n"
  );
  fprintf(stderr,"         * l : afficher table decla\n");
  fprintf(stderr,"         * d : afficher table decla\n");
  fprintf(stderr,"         * t : afficher table types\n");
  fprintf(stderr,"         * r : afficher table regions\n");
  fprintf(stderr,"         * a : afficher arbres\n");
  fprintf(stderr, "     * <prog_cpyrr> : programme cpyrr\n\n");
  exit(-1);
}

// Initialise la pile de région
void init_pile_variable(){
  pile_variable[0] = 0;
}

// Indique si la pile des variables est vide
int est_vide_pile_variable(){
  return (pile_variable[0] == 0);
}

// Empile une variable
void empiler_pile_variable(int variable){
  if(pile_variable[0] == MAX_IMBR_VAR){ // Vérification du nombre de variables
    fprintf(stderr, "Erreur, trop d'éléments dans la pile des régions.\n");
    exit(-1);
  }
  pile_variable[0]++;
  pile_variable[pile_variable[0]] = variable;
}

// Dépile une région
int depiler_pile_variable(){
  pile_variable[0]--;
  return pile_variable[pile_variable[0]+1];
}

// Retourne la tête de la pile des variables
int tete_pile_variable(){
  return pile_variable[pile_variable[0]];
}

// Initialise la pile de région
void init_pile_region(){
  pile_region[0] = 1; // Une région dans la pile pour le moment
  pile_region[1] = 0; // Region 0
}

// Empile une region
void empiler_pile_region(int region){
  if(pile_region[0] == MAX_REGION){ // Vérification du nombre de régions
    fprintf(stderr, "Erreur, trop d'éléments dans la pile des régions.\n");
    exit(-1);
  }
  pile_region[0]++;
  pile_region[pile_region[0]] = region;
}

// Dépile une région
int depiler_pile_region(){
  pile_region[0]--;
  return pile_region[pile_region[0]+1];
}

// Retourne la tête de la pile des regions
int tete_pile_region(){
  return pile_region[pile_region[0]];
}

// Renvoie 1 si la région est dans la pile des régions, 0 sinon
int est_dans_pile_region(int region){
  int i;

  for(i = 1; i<pile_region[0]+1; i++){ //On regarde chaque élément de la pile
    if(pile_region[i] == region){ // On regarde si region en fait partie
      return 1;
    }
  }

  return 0;
}

// Vérification de la cohérence des types pour une expression renvoyant un
// résultat numérique (ou caractère), renvoie le type final, -1 si erreur
int verif_type_expr_arithm(int type_g, int type_d, int nb_ligne){
  // L'une des composantes est booleenne
  if(type_g == TYPE_BOOL || type_d == TYPE_BOOL){
    print_erreur_semantique(
      "opérateur arithmétique impossible sur un booleen."
    );
    return -1;
  }

  if(type_g == TYPE_INT && type_d == TYPE_INT){
   return TYPE_INT;
  }
  if(type_g == TYPE_FLOAT && type_d == TYPE_FLOAT){
   return TYPE_FLOAT;
  }
  if(type_g == TYPE_CHAR && type_d == TYPE_CHAR){
   return TYPE_CHAR;
  }
  else{
    print_erreur_semantique("opérandes de l'expression de types différents.");
    return -1;
  }
}

// Vérification de la cohérence des types pour une expression renvoyant un
// booleen
int verif_type_expr_bool(int type_g, int type_d, int nb_ligne){
  // L'une des composantes est réelle
  if(type_g == TYPE_FLOAT || type_d == TYPE_FLOAT){

    return -1;
  }
  return 2;
}

//Vérifie si un appel de fonction ou procédure, est correctement fait
int verif_arg_appel(int num_decla, int tab_arg_appel[], int nb_ligne){
  int indice;
  int nb_arg;
  int i;

  if(nature(num_decla) ==  PROC){
      nb_arg = valeur_tab_representation(valeur_description_tab_decla(num_decla));
      indice = valeur_description_tab_decla(num_decla)+1;
  }else{
    nb_arg = valeur_tab_representation(valeur_description_tab_decla(num_decla)+1);
    indice = valeur_description_tab_decla(num_decla)+2;
  }

  /*On vérifie que le nombre d'argument est le même que le nombre de parametre*/
  if(nb_arg == tab_arg_appel[0]){
    for(i=1; i<nb_arg+1; i++){
      /*On vérifie que le type de chaque argument correspond au type du parametre*/
      if(tab_arg_appel[i] != valeur_tab_representation(indice)){
        print_erreur_semantique("paramètre de mauvais type dans l'appel.");
        return -1;
      }
      indice += 2;
    }
  }else{
    print_erreur_semantique("nombre de paramètre de l'appel incorrect.");
    return -1;
  }
  return 0;
}

//Retourne la valeur du dernier déplacement
int deplacement(){
  return deplacement_var[tete_pile_region()];
}

//Modifie la valeur du champs deplacement_var
void change_deplacement(int valeur){
  deplacement_var[tete_pile_region()] += valeur;
}

//Retourne la valeur du dernier deplacement_struct
int deplacement_struct(){
  return deplacement_structure;
}

//Modifie la valeur du champs deplacement_struct
void change_deplacement_struct(int valeur){
  deplacement_structure = valeur;
}

//Modifie la valeur de nis_region
void change_NIS(int valeur){
  nis_region += valeur;
}

//Renvoie la valeur de nis_region
int nis(){
  return nis_region;
}

// Analyse les options passées au compilateur et lève les flags adéquats
int analyse_options(char *argv[], int *flags){
  int fic = -1;
  int nb_output = 0;
  int i = 1;

  while(argv[i+1] != NULL){
    if(!strcmp("l", argv[i])){    // Lexico
      flags[0]++;
    }
    else if(!strcmp("d", argv[i])){   // Déclarations
      flags[1]++;
    }
    else if(!strcmp("t", argv[i])){   // Types
      flags[2]++;
    }
    else if(!strcmp("r", argv[i])){   // Régions
      flags[3]++;
    }
    else if(!strcmp("a", argv[i])){   // Arbres
      flags[4]++;
    }
    else if(!strcmp("o", argv[i])){   // Output
      if(argv[i+2] == NULL){
        fprintf(stderr, "\nOption o mais pas de fichier output précisé\n");
        usage(argv[0]);
      }
      fic = i+1;

      // On essaye d'ouvir le fichier d'ouput pour vérification
      if((fopen(argv[i+1], "r")) != NULL){
        fprintf(stderr, "\n%s existe déjà\n", argv[i+1]);
        usage(argv[0]);
      }
      // Vérification du nombre de fichier output
      if(nb_output != 0){
        fprintf(stderr, "\nNombre de fichier output précisé > 1\n");
        usage(argv[0]);
      }

      // On incrémente la vérification du nombre d'appel à o
      nb_output++;
      i++;
    }
    else{
      fprintf(stderr, "\nOptions inconnue : %s\n", argv[i]);
      usage(argv[0]);
    }
    i++;
  }

  return fic;
}

// Fonction permettant de déterminer combien et quels formats simples se
// trouvent dans une chaine de caractère
void format(char *str){
  char *ptr = str;

  tab_format[0] = 0;

  while(*ptr != '\0'){
    if(*ptr == '%'){
      if(*(ptr+1) == 'd'
      || *(ptr+1) == 'f'
      || *(ptr+1) == 'b'
      || *(ptr+1) == 'c'
      || *(ptr+1) == 's'
      ){
        if(tab_format[0] == MAX_FORMAT){  // Vérification du max de formats
          //err_sem
          fprintf(stderr, "Erreur, trop de formats.\n");
          exit(-1);
        }
        tab_format[0]++;
        switch(*(ptr+1)){   // On rempli le tableau de format avec les formats
          case 'd':
            tab_format[tab_format[0]] = 0;
            break;
          case 'f':
            tab_format[tab_format[0]] = 1;
            break;
          case 'b':
            tab_format[tab_format[0]] = 2;
            break;
          case 'c':
            tab_format[tab_format[0]] = 3;
            break;
          case 's':
            tab_format[tab_format[0]] = 4;
            break;
          default :
            fprintf(stderr, "Erreur format...");
            exit(-1);
        }
      }
    }
    ptr++;
  }
}
