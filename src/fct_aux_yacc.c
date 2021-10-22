// Fonctions auxiliaires utilisées dans le programme YACC

#include <stdlib.h>
#include <stdio.h>
#include "../inc/fct_aux_yacc.h"
#include "../TabDecla/inc/TabDecla.h"
#include "../TabRepresentation/inc/TabRepresentation.h"

// Fonction d'usage du compilateur
void usage(char *s){
  fprintf(
    stderr,
    "\n%s [aff_lex] [aff_decl] [aff_type] [aff_arbres] < <prog_cpyrr>\n",
    s
  );
  fprintf(
    stderr,
    "     * [aff_lex]    1 : afficher table lexico\n"
  );
  fprintf(
    stderr,
    "     * [aff_decl]   1 : afficher table decla\n"
  );
  fprintf(
    stderr,
    "     * [aff_types]  1 : afficher table types\n"
  );
  fprintf(stderr, "     * [aff_arbres] 1 : afficher arbres\n");
  fprintf(stderr, "     * <prog_cpyrr> : programme cpyrr\n\n");
  exit(-1);
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

// Initialise la pile de région
void init_pile_region(){
  pile_region[0] = 1; // Une région dans la pile pour le moment
  pile_region[1] = 0; // Region 0
}

// Empile une region
void empiler_pile_region(int region){
  if(pile_region[0] == MAX_REGION){ // Vérification du nombre de régions
    fprintf(stderr, "Erreur, trop de formats.\n");
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
    fprintf(
      stderr,
      "\nErreur l:%d -> Opérateur arithmétique impossible sur un booleen.\n",
      nb_ligne
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
    fprintf(
      stderr,
      "\nErreur l:%d -> Opérandes de l'expression de types différents.\n",
      nb_ligne
    );
    return -1;
  }
}

// Vérification de la cohérence des types pour une expression renvoyant un
// booleen
int verif_type_expr_bool(int type_g, int type_d, int nb_ligne){
  // L'une des composantes est réelle
  if(type_g == TYPE_FLOAT || type_d == TYPE_FLOAT){
    fprintf(
      stderr,
      "\nErreur l:%d -> Opérateur booleen impossible sur un reel.\n",
      nb_ligne
    );
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
      indice = valeur_description_tab_decla(num_decla)+1;
  }else{
    indice = valeur_description_tab_decla(num_decla)+3;
  }
  nb_arg = valeur_tab_representation(indice);

  /*On vérifie que le nombre d'argument est le même que le nombre de parametre*/
  if(nb_arg == tab_arg_appel[0]){
    for(i=1; i<nb_arg+1; i++){
      indice += 2;
      /*On vérifie que le type de chaque argument correspond au type du parametre*/
      if(tab_arg_appel[i] != valeur_tab_representation(indice)){
        printf("Erreur sémantique ligne %d : paramètre de mauvais type dans l'appel\n",nb_ligne);
        return -1;
      }
    }
  }else{
    printf("Erreur sémantique ligne %d : nombre de paramètre de l'appel incorrect\n",nb_ligne);
    return -1;
  }
  return 0;
}
